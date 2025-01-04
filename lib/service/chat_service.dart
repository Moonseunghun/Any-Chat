import 'dart:convert';
import 'dart:io';

import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:anychat/common/toast.dart';
import 'package:anychat/main.dart';
import 'package:anychat/model/chat.dart';
import 'package:anychat/service/database_service.dart';
import 'package:anychat/service/translate_service.dart';
import 'package:anychat/service/user_service.dart';
import 'package:anychat/state/chat_state.dart';
import 'package:anychat/state/user_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../common/config.dart';
import '../model/auth.dart';
import '../model/message.dart';
import '../page/chat/chat_page.dart';
import '../page/router.dart';

class ChatService extends SecuredHttpClient {
  final String basePath = '/chat/api';

  Future<void> getRooms(WidgetRef ref) async {
    await get(path: basePath, converter: (result) => result['data']).run(null, (result) async {
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
    }, errorHandler: (_) {});
  }

  Future<ChatRoomHeader> makeRoom(WidgetRef ref, List<String> friends) async {
    return await post(
        path: basePath,
        queryParams: {'targetUserIds': friends},
        converter: (result) => result['data']).run(ref, (result) {
      return ChatRoomHeader(
          chatRoomId: result['chatRoomId'] as String, chatRoomName: result['name']);
    }, errorMessage: '채팅방을 생성하는데 실패했습니다.');
  }

  Future<String?> getMessages(WidgetRef ref, ValueNotifier<List<ChatUserInfo>> participants,
      ValueNotifier<List<Message>> messages, String chatRoomId, String? cursor) async {
    return await get(
        path: '$basePath/$chatRoomId/messages',
        queryParams: {'limit': 40, 'cursor': cursor},
        converter: (result) => result['data']).run(null, (result) async {
      final List<Message> tmp = [];
      final List<Message> tmp2 = [];

      for (final Map<String, dynamic> message
          in List<Map<String, dynamic>>.from(result['newMessages'])) {
        tmp.add(await Message.fromJson(ref, participants.value, message));
      }

      messages.value = <Message>{...messages.value, ...tmp}.toList()
        ..sort((a, b) => b.seqId.compareTo(a.seqId));

      for (final Message message in messages.value) {
        if (message.messageType == MessageType.text) {
          tmp2.add(await translateService.translate(message));
        } else {
          tmp2.add(message);
        }
      }
      messages.value = tmp2;

      DatabaseService.batchInsert('Message', tmp2.map((e) => Message.toMap(e)).toList());

      if (messages.value.isNotEmpty) {
        readMessage(ref, messages.value.first.seqId);
      }

      return result['nextCursor'];
    }, errorHandler: (_) {});
  }

  Future<void> getParticipants(
      String chatRoomId, ValueNotifier<List<ChatUserInfo>> participants) async {
    return await get(
        path: '$basePath/$chatRoomId/participants',
        converter: (result) => result['data']).run(null, (data) async {
      final List<ChatUserInfo> chatUserInfos = [];

      for (final Map<String, dynamic> participant
          in List<Map<String, dynamic>>.from(data['participants'])) {
        chatUserInfos.add(await ChatUserInfo.fromJson(participant['user']));
      }

      DatabaseService.batchInsert(
          'ChatUserInfo',
          List<Map<String, dynamic>>.from(data['participants'])
              .map((e) => ChatUserInfo.toMap(chatRoomId, e['user']))
              .toList());

      participants.value = chatUserInfos;
    }, errorHandler: (_) {});
  }

  Future<void> connectSocket(WidgetRef ref, {Function? callback, String? accessToken}) async {
    if (!socketConnected) {
      socket = IO.io(
          HttpConfig.webSocketUrl,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .setExtraHeaders({'authorization': accessToken ?? auth!.accessToken})
              .enableForceNew()
              .build());

      catchError(ref);

      socket!.connect();

      socket!.on('S_CONNECTION', (data) {
        socketConnected = true;
        onChatRoomInfo(ref);
        onInviteUsers();
        callback?.call();
      });

      socket!.onDisconnect((_) {
        socketConnected = false;
        outRoom(ref);
        socket?.off('S_ERROR');
        socket?.off('S_CONNECTION');
      });
    }
  }

  void disposeSocket() {
    socket?.disconnect();
  }

  Future<void> joinRoom(
      WidgetRef ref,
      ValueNotifier<List<ChatUserInfo>> participants,
      String chatRoomId,
      ValueNotifier<List<Message>> messages,
      ValueNotifier<List<LoadingMessage>> loadingMessages,
      ValueNotifier<String?> cursor) async {
    socket!.emit('C_JOIN_ROOM', {'chatRoomId': chatRoomId});
    socket!.on('S_JOIN_ROOM', (data) async {
      socket!.on('S_FILE_OPTIMIZATION_PROCESSING', (data) {
        loadingMessages.value = loadingMessages.value.map((e) {
          if (e.uuid == data['uuid']) {
            return e.copyWith(progress: data['progress'] / 1.5);
          } else {
            return e;
          }
        }).toList();
      });

      socket!.on('S_FILE_UPLOAD_PROGRESS', (data) {
        loadingMessages.value = loadingMessages.value.map((e) {
          if (e.uuid == data['uuid']) {
            return e.copyWith(progress: data['progress'] / 3.3 + 67);
          } else {
            return e;
          }
        }).toList();
      });

      final result = jsonDecode(data);

      final List<Message> tmp = [];
      final List<Message> tmp2 = [];

      for (final Map<String, dynamic> message
          in List<Map<String, dynamic>>.from(result['messages'])) {
        tmp.add(await Message.fromJson(ref, participants.value, message));
      }

      messages.value = tmp..sort((a, b) => b.seqId.compareTo(a.seqId));

      cursor.value = result['nextCursor'];

      for (final Message message in messages.value) {
        if (message.messageType == MessageType.text) {
          tmp2.add(await translateService.translate(message));
        } else {
          tmp2.add(message);
        }
      }
      messages.value = tmp2;

      DatabaseService.batchInsert('Message', tmp2.map((e) => Message.toMap(e)).toList());

      if (messages.value.isNotEmpty) {
        readMessage(ref, messages.value.first.seqId);
      }
    });
  }

  void outRoom(WidgetRef ref) {
    if (socketConnected) {
      socket?.emit('C_LEAVE_ROOM');
    }

    socket?.off('S_JOIN_ROOM');
    socket?.off('S_SEND_MESSAGE');
    socket?.off('S_MESSAGE_READ');
    socket?.off('S_KICKED');
    socket?.off('S_UPDATED_MESSAGES');
    socket?.off('S_FILE_OPTIMIZATION_PROCESSING');
    socket?.off('S_FILE_UPLOAD_PROGRESS');
  }

  void sendMessage(WidgetRef ref, String message) {
    socket!.emit('C_SEND_MESSAGE', {'message': message});
  }

  Future<String?> getRoomInfo(String chatRoomId) async {
    return await get(path: '$basePath/$chatRoomId', converter: (result) => result['data']).run(null,
        (data) {
      return data['ownerId'] as String?;
    }, errorHandler: (_) {});
  }

  void sendFile(WidgetRef ref, File file, String uuid) {
    socket!.emit('C_SEND_FILE', {
      'fileBuffer': file.readAsBytesSync(),
      'fileName': file.path.split('/').last,
      'uuid': uuid
    });
  }

  void onMessageReceived(
      WidgetRef ref,
      String chatRoomId,
      ValueNotifier<List<Message>> messages,
      ValueNotifier<List<ChatUserInfo>> participants,
      ValueNotifier<List<LoadingMessage>> loadingMessages) {
    socket!.on('S_SEND_MESSAGE', (result) async {
      if (result['messageType'] == MessageType.invite.value) {
        await getParticipants(chatRoomId, participants);
      } else if (result['messageType'] == MessageType.kick.value) {
        participants.value = participants.value
            .where((e) => e.id != (result['content'] as Map<String, dynamic>)['kickedOutId'])
            .toList();
      } else if (result['messageType'] == MessageType.leave.value) {
        participants.value = participants.value
            .where((e) => e.id != (result['content'] as Map<String, dynamic>)['exitUserId'])
            .toList();
      }

      final Message message = await Message.fromJson(ref, participants.value, result);

      final List<LoadingMessage> tmp = List.from(loadingMessages.value);
      final index = tmp.indexWhere((e) =>
          e.messageType == message.messageType &&
          e.status == MessageStatus.loading &&
          (e.messageType == MessageType.text
              ? e.content == message.content
              : e.messageType == MessageType.video
                  ? p.basename(e.content['file'].path) == message.content['fileName']
                  : p.basename(e.content.path) == message.content['fileName']));

      if (index != -1) {
        tmp.removeAt(index);
        loadingMessages.value = tmp;
      }

      late final Message translatedMessage;
      if (message.messageType == MessageType.text) {
        translatedMessage = await translateService.translate(message);
      } else {
        translatedMessage = message;
      }

      messages.value = [translatedMessage, ...messages.value];

      DatabaseService.insert('Message', Message.toMap(translatedMessage));

      if (messages.value.first.senderId != ref.read(userProvider)!.id) {
        readMessage(ref, messages.value.first.seqId);
      }
    });
  }

  void readMessage(WidgetRef ref, int seqId) {
    socket!.emit('C_MESSAGE_READ', {'lastSeqId': seqId});
  }

  void onMessageRead(WidgetRef ref, ValueNotifier<List<Message>> messages) {
    socket!.on('S_MESSAGE_READ', (data) {
      final List<Map<String, dynamic>> updatedMessages = List<dynamic>.from(data['updatedMessages'])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      messages.value = messages.value.map((message) {
        final updateMessage = updatedMessages.where((e) => e['seqId'] == message.seqId).firstOrNull;

        if (updateMessage != null) {
          if (updateMessage['readCount'] != null) {
            DatabaseService.update('Message', {'readCount': updateMessage['readCount'] as int},
                'seqId = ?', [message.seqId]);

            return message.copyWith(readCount: updateMessage['readCount'] as int);
          } else {
            return message;
          }
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
    await post(path: '$basePath/exit', queryParams: {'chatRoomId': chatRoomId}).run(ref, (_) {
      DatabaseService.delete('ChatRoomInfo', where: 'id = ?', whereArgs: [chatRoomId]);
      DatabaseService.delete('Message', where: 'chatRoomId = ?', whereArgs: [chatRoomId]);
      DatabaseService.delete('ChatUserInfo', where: 'chatRoomId = ?', whereArgs: [chatRoomId]);
      ref.read(chatRoomInfoProvider.notifier).remove(chatRoomId);
    }, errorMessage: '채팅방을 나가는데 실패했습니다.');
  }

  void inviteUsers(WidgetRef ref, List<String> ids) {
    socket!.emit('C_INVITE_USER', {'inviteeIds': ids});
  }

  void onInviteUsers() {
    socket!.on('S_CREATE_GROUP_CHAT_ROOM', (data) {
      router.pop();
      socket!.on('S_LEAVE_ROOM', (_) {
        socket!.off('S_LEAVE_ROOM');
        router.push(ChatPage.routeName,
            extra:
                ChatRoomHeader(chatRoomId: data['chatRoomId'], chatRoomName: data['chatRoomName']));
      });
    });
  }

  void onUpdatedMessages(WidgetRef ref, ValueNotifier<List<Message>> messages) {
    socket!.on('S_UPDATED_MESSAGES', (data) {
      final List<Map<String, dynamic>> updatedMessages = List<dynamic>.from(data['updatedMessages'])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      messages.value = messages.value.map((message) {
        final updateMessage = updatedMessages.where((e) => e['seqId'] == message.seqId).firstOrNull;

        if (updateMessage != null) {
          if (updateMessage['readCount'] != null) {
            DatabaseService.update(
                'Message',
                {
                  'readCount': updateMessage['readCount'] as int,
                  'totalParticipants': updateMessage['totalParticipants'] as int
                },
                'seqId = ?',
                [message.seqId]);

            return message.copyWith(
                readCount: updateMessage['readCount'] as int,
                totalParticipants: updateMessage['totalParticipants'] as int);
          } else {
            return message;
          }
        } else {
          return message;
        }
      }).toList();
    });
  }

  void kickUser(WidgetRef ref, String userId) {
    socket!.emit('C_KICK_USER', {'targetUserId': userId});
  }

  void onKickUser(WidgetRef ref) {
    socket!.on('S_KICKED', (_) {
      router.pop();
      errorToast(message: '강퇴되었습니다.');
    });
  }

  void catchError(WidgetRef ref) {
    socket!.on('S_ERROR', (data) {
      print('에러: $data');
      if (data is Map && data['status'] == 401) {
        UserService.refreshAccessToken().then((token) {
          connectSocket(ref, accessToken: token);
        });
      }
    });
  }
}
