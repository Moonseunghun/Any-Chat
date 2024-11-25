import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:anychat/main.dart';
import 'package:anychat/model/chat.dart';
import 'package:anychat/service/database_service.dart';
import 'package:anychat/state/chat_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../common/config.dart';
import '../model/auth.dart';
import '../model/friend.dart';
import '../model/message.dart';

class ChatService extends SecuredHttpClient {
  final String basePath = '/chat/api';

  Future<void> getRooms(WidgetRef ref) async {
    await get(
        path: basePath,
        queryParams: {if (prefs.getBool('isInitialSync') ?? true) 'isInitialSync': true},
        converter: (result) => result['data']).run(null, (result) async {
      List<ChatRoomInfo> chatRoomInfos = [];

      await DatabaseService.batchInsert(
          'ChatRoomInfo',
          List<dynamic>.from(result['data'])
              .map((e) => ChatRoomInfo.toMap(ref, e as Map<String, dynamic>))
              .toList());

      final List<Map<String, dynamic>> savedInfo = await DatabaseService.search('ChatRoomInfo');

      for (final Map<String, dynamic> chatRoomInfo in savedInfo) {
        chatRoomInfos.add(await ChatRoomInfo.fromJson(ref, chatRoomInfo));
      }

      ref.read(chatRoomInfoProvider.notifier).set(chatRoomInfos);
    }, errorMessage: '채팅방 목록을 불러오는데 실패했습니다.');
  }

  Future<ChatRoomHeader> makeRoom(WidgetRef ref, List<Friend> friends) async {
    final String chatRoomName = friends.length > 6
        ? "${friends.map((e) => e.nickname).take(6).join(', ')}..."
        : friends.map((e) => e.nickname).join(', ');

    return await post(
        path: basePath,
        queryParams: {
          'targetUserIds': friends.map((e) => e.friend.id).toList(),
          'chatRoomName': chatRoomName
        },
        converter: (result) => result['data']).run(ref, (result) {
      return ChatRoomHeader(chatRoomId: result['chatRoomId'] as String, chatRoomName: chatRoomName);
    }, errorMessage: '채팅방을 생성하는데 실패했습니다.');
  }

  Future<String?> getMessages(
      ValueNotifier<List<Message>> messages, String chatRoomId, String? cursor,
      {bool isInit = false}) async {
    return await get(
        path: '$basePath/$chatRoomId/messages',
        queryParams: {'limit': 40, 'cursor': cursor},
        converter: (result) => result['data']).run(null, (result) async {
      if (isInit) {
        messages.value = List<Map<String, dynamic>>.from(result['newMessages'])
            .map((e) => Message.fromJson(e))
            .toList()
          ..sort((a, b) => b.seqId.compareTo(a.seqId));
      } else {
        messages.value = <Message>{
          ...messages.value,
          ...List<Map<String, dynamic>>.from(result['newMessages']).map((e) => Message.fromJson(e))
        }.toList()
          ..sort((a, b) => b.seqId.compareTo(a.seqId));
      }

      await DatabaseService.batchInsert(
          'Message',
          List<dynamic>.from(result['newMessages'])
              .map((e) => Message.toMap(e as Map<String, dynamic>))
              .toList());

      if (messages.value.isNotEmpty) {
        readMessage(messages.value.last.seqId);
      }

      return result['nextCursor'];
    }, errorHandler: (_) {});
  }

  Future<void> getParticipants(
      String chatRoomId, ValueNotifier<List<ChatUserInfo>> participants) async {
    return get(path: '$basePath/$chatRoomId/participants', converter: (result) => result['data'])
        .run(null, (data) async {
      final List<ChatUserInfo> chatUserInfos = [];

      for (final Map<String, dynamic> participant
          in List<Map<String, dynamic>>.from(data['participants'])) {
        chatUserInfos.add(await ChatUserInfo.fromJson(participant['user']));
      }

      participants.value = chatUserInfos;
    }, errorHandler: (_) {});
  }

  void connectSocket(WidgetRef ref) {
    socket = IO.io(
        HttpConfig.webSocketUrl,
        IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders(
            {'authorization': auth!.accessToken}).build());

    socket!.connect();

    socket!.on('S_JOIN_ROOM', (data) {
      socketConnected = true;
      onChatRoomInfo(ref);
    });
  }

  void disposeSocket() {
    socket!.disconnect();

    socket!.onDisconnect((_) {
      socket = null;
    });
  }

  void joinRoom(String chatRoomId) {
    socket!.emit('C_JOIN_ROOM', {'chatRoomId': chatRoomId});
  }

  void outRoom() {
    socket!.emit('C_LEAVE_ROOM');
    socket!.off('S_SEND_MESSAGE');
    socket!.off('S_MESSAGE_READ');
  }

  void sendMessage(String message) {
    socket!.emit('C_SEND_MESSAGE', {'message': message});
  }

  void onMessageReceived(ValueNotifier<List<Message>> messages) {
    socket!.on('S_SEND_MESSAGE', (result) {
      messages.value = [Message.fromJson(result), ...messages.value];

      DatabaseService.insert('Message', Message.toMap(result));

      readMessage(messages.value.last.seqId);
    });
  }

  void readMessage(int seqId) {
    socket!.emit('C_MESSAGE_READ', {'lastSeqId': seqId});
  }

  void onMessageRead(ValueNotifier<List<Message>> messages) {
    socket!.on('S_MESSAGE_READ', (data) {
      final List<Map<String, dynamic>> updatedMessages = List<dynamic>.from(data['updatedMessages'])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      messages.value = messages.value.map((message) {
        final updateMessage = updatedMessages.where((e) => e['seqId'] == message.seqId).firstOrNull;

        if (updateMessage != null) {
          DatabaseService.update('Message', {'readCount': updateMessage['readCount'] as int},
              'seqId = ?', [message.seqId]);

          return message.copyWith(readCount: updateMessage['readCount'] as int);
        } else {
          return message;
        }
      }).toList();

      socket!.emit('C_READ_SYNC', {'lastSeqId': messages.value.last.seqId});
    });
  }

  void onChatRoomInfo(WidgetRef ref) {
    socket!.on('S_CHAT_ROOM_UPDATE', (data) {
      DatabaseService.insert('ChatRoomInfo', ChatRoomInfo.toMap(ref, data as Map<String, dynamic>));

      ChatRoomInfo.fromJson(ref, data).then((chatRoomInfo) {
        ref.read(chatRoomInfoProvider.notifier).update(chatRoomInfo);
      });
    });
  }

  Future<void> leaveRoom(WidgetRef ref, String chatRoomId) async {
    await patch(path: '$basePath/$chatRoomId/leave').run(ref, (_) {
      DatabaseService.delete('ChatRoomInfo', 'id = ?', [chatRoomId]);
      ref.read(chatRoomInfoProvider.notifier).remove(chatRoomId);
    }, errorMessage: '채팅방을 나가는데 실패했습니다.');
  }
}
