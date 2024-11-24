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
    get(
        path: basePath,
        queryParams: {if (prefs.getBool('isInitialSync') ?? true) 'isInitialSync': true},
        converter: (result) => result['data']).run(null, (result) async {
      List<ChatRoomInfo> chatRoomInfos = [];

      for (final Map<String, dynamic> chatRoomInfo in List<dynamic>.from(result['data'])) {
        await DatabaseService.insert('ChatRoomInfo', ChatRoomInfo.toMap(ref, chatRoomInfo));
      }

      final List<Map<String, dynamic>> savedInfo = await DatabaseService.search('ChatRoomInfo');

      for (final Map<String, dynamic> chatRoomInfo in savedInfo) {
        chatRoomInfos.add(await ChatRoomInfo.fromJson(chatRoomInfo));
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

  Future<void> getMessages(ValueNotifier<List<Message>> messages, String chatRoomId) async {
    get(path: '$basePath/$chatRoomId/messages', converter: (result) => result['data']).run(null,
        (result) {
      messages.value = List<dynamic>.from(result['newMessages'])
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();

      if (messages.value.isNotEmpty) {
        readMessage(messages.value.last.id);
      }
    }, errorHandler: (_) {});
  }

  /// FIXME: 참가자 조회 500에러
  Future<int> getParticipants(String chatRoomId) async {
    return get(path: '$basePath/$chatRoomId/participants', converter: (result) => result['data'])
        .run(null, (data) {
      return 2;
    }, errorHandler: (_) {});
  }

  void connectSocket() {
    socket = IO.io(
        HttpConfig.webSocketUrl,
        IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders(
            {'authorization': auth!.accessToken}).build());

    socket!.connect();
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

  void leaveRoom() {
    socket!.emit('C_LEAVE_ROOM');
    socket!.off('S_SEND_MESSAGE');
    socket!.off('S_MESSAGE_READ');
  }

  void sendMessage(String message) {
    socket!.emit('C_SEND_MESSAGE', {'message': message});
  }

  void onMessageReceived(ValueNotifier<List<Message>> messages) {
    socket!.on('S_SEND_MESSAGE', (result) {
      messages.value = [...messages.value, Message.fromJson(result)];

      readMessage(messages.value.last.id);
    });
  }

  void readMessage(String messageId) {
    socket!.emit('C_MESSAGE_READ', {'lastMessageId': messageId});
  }

  /// FIXME: 메세지 읽음 수신 동작 안함
  void onMessageRead(ValueNotifier<List<Message>> messages) {
    socket!.on('S_MESSAGE_READ', (data) {
      final List<Map<String, dynamic>> updatedMessages = List<dynamic>.from(data['updatedMessages'])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      messages.value = messages.value.map((message) {
        final updateMessage =
            updatedMessages.where((e) => int.parse(e['seqId']) == message.seqId).firstOrNull;

        if (updateMessage != null) {
          return message.copyWith(readCount: updateMessage['readCount'] as int);
        } else {
          return message;
        }
      }).toList();
    });
  }
}
