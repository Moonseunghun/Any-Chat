import 'dart:convert';
import 'dart:io';

import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:anychat/common/toast.dart';
import 'package:anychat/main.dart';
import 'package:anychat/model/chat.dart';
import 'package:anychat/page/main_layout.dart';
import 'package:anychat/service/database_service.dart';
import 'package:anychat/service/translate_service.dart';
import 'package:anychat/service/user_service.dart';
import 'package:anychat/state/chat_state.dart';
import 'package:anychat/state/user_state.dart';
import 'package:anychat/state/util_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../common/config.dart';
import '../model/auth.dart';
import '../model/message.dart';
import '../page/chat/chat_page.dart';
import '../page/router.dart';

late ChatService chatService;
Function? _callback;

class ChatService extends SecuredHttpClient {
  final WidgetRef ref;
  final String basePath = '/chat/api';

  ChatService(this.ref);

  Future<void> getRooms() async {
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

  Future<void> makeRoom(List<String> friends) async {
    return await post(
        path: basePath,
        queryParams: {'targetUserIds': friends},
        converter: (result) => result['data']).run(ref, (result) {
      router.go(MainLayout.routeName);
      joinRoom(result['chatRoomId'], result['name']);
    }, errorMessage: '채팅방을 생성하는데 실패했습니다.');
  }

  Future<String?> getMessages(ValueNotifier<List<ChatUserInfo>> participants,
      ValueNotifier<List<Message>> messages, String chatRoomId) async {
    return await get(
        path: '$basePath/$chatRoomId/messages',
        queryParams: {'limit': 40, 'cursor': messageCursor},
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
        readMessage(messages.value.first.seqId);
      }

      return result['nextCursor'];
    }, errorHandler: (_) {});
  }

  Future<List<ChatUserInfo>> getParticipants(String chatRoomId) async {
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

      return chatUserInfos;
    }, errorMessage: '참가자 정보를 불러오는 중 오류가 발생했습니다');
  }

  Future<void> connectSocket({Function? callback, String? accessToken}) async {
    if (socket?.connected != true) {
      _callback = callback;
      socket = IO.io(
          HttpConfig.webSocketUrl,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .setExtraHeaders({'authorization': accessToken ?? auth!.accessToken})
              .enableForceNew()
              .build());

      catchError();

      socket!.connect();

      socket!.on('S_CONNECTION', (data) {
        onChatRoomInfo();
        onInviteUsers();
        callback?.call();
      });

      socket!.onDisconnect((_) {
        outRoom();
        socket?.off('S_ERROR');
        socket?.off('S_CONNECTION');
      });
    } else {
      callback?.call();
    }
  }

  void disposeSocket() {
    socket?.disconnect();
  }

  Future<void> joinRoom(
    String chatRoomId,
    String chatRoomName, {
    ValueNotifier<ChatUserInfo?>? ownerValue,
    ValueNotifier<List<ChatUserInfo>>? participantsValue,
    ValueNotifier<List<Message>>? messagesValue,
  }) async {
    if (participantsValue == null && messagesValue == null && ownerValue == null) {
      messageCursor = null;
    }

    final internet = await Connectivity().checkConnectivity();

    if (!internet.contains(ConnectivityResult.mobile) &&
        !internet.contains(ConnectivityResult.wifi)) {
      if (participantsValue == null && messagesValue == null && ownerValue == null) {
        router.push(ChatPage.routeName,
            extra: ChatRoomHeader(
                chatRoomId: chatRoomId,
                chatRoomName: chatRoomName,
                messages: [],
                chatUserInfos: [],
                owner: null));
      }
      return;
    }

    late final List<ChatUserInfo> participants;
    late final ChatUserInfo? owner;
    List<Message> messages = [];

    await getParticipants(chatRoomId).then((chatUserInfos) async {
      participants = chatUserInfos;
      await getRoomInfo(chatRoomId).then((value) {
        owner = participants.where((e) => e.id == value).firstOrNull;
      });
    });

    ref.read(loadingProvider.notifier).on();

    connectSocket(callback: () {
      socket!.emit('C_JOIN_ROOM', {'chatRoomId': chatRoomId});
      socket!.on('S_JOIN_ROOM', (data) async {
        final result = jsonDecode(data);

        final List<Message> tmp = [];
        final List<Message> tmp2 = [];

        for (final Map<String, dynamic> message
            in List<Map<String, dynamic>>.from(result['messages'])) {
          tmp.add(await Message.fromJson(ref, participants, message));
        }

        messages = tmp..sort((a, b) => b.seqId.compareTo(a.seqId));

        messageCursor = result['nextCursor'];

        for (final Message message in messages) {
          if (message.messageType == MessageType.text) {
            tmp2.add(await translateService.translate(message));
          } else {
            tmp2.add(message);
          }
        }
        messages = tmp2;

        DatabaseService.batchInsert('Message', tmp2.map((e) => Message.toMap(e)).toList());

        if (messages.isNotEmpty) {
          readMessage(messages.first.seqId);
        }

        ref.read(loadingProvider.notifier).off();

        if (participantsValue == null && messagesValue == null && ownerValue == null) {
          router.push(ChatPage.routeName,
              extra: ChatRoomHeader(
                  chatRoomId: chatRoomId,
                  chatRoomName: chatRoomName,
                  messages: messages,
                  chatUserInfos: participants,
                  owner: owner));
        } else {
          participantsValue?.value = participants;
          messagesValue?.value = messages;
          ownerValue?.value = owner;
        }
      });
    });
  }

  void onFileProgress(ValueNotifier<List<LoadingMessage>> loadingMessages) {
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
  }

  void outRoom() {
    if (socket?.connected == true) {
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

  void sendMessage(String message) {
    socket!.emit('C_SEND_MESSAGE', {'message': message});
  }

  Future<String?> getRoomInfo(String chatRoomId) async {
    return await get(path: '$basePath/$chatRoomId', converter: (result) => result['data']).run(null,
        (data) {
      return data['ownerId'] as String?;
    }, errorMessage: '방 정보를 불러오는 중 오류가 발생했습니다');
  }

  void sendFile(File file, String uuid) {
    socket!.emit('C_SEND_FILE', {
      'fileBuffer': file.readAsBytesSync(),
      'fileName': file.path.split('/').last,
      'uuid': uuid
    });
  }

  void onMessageReceived(
      String chatRoomId,
      ValueNotifier<List<Message>> messages,
      ValueNotifier<List<ChatUserInfo>> participants,
      ValueNotifier<List<LoadingMessage>> loadingMessages) {
    socket!.on('S_SEND_MESSAGE', (result) async {
      if (result['messageType'] == MessageType.invite.value) {
        await getParticipants(chatRoomId).then((chatUserInfos) {
          participants.value = chatUserInfos;
        });
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
        readMessage(messages.value.first.seqId);
      }
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

  void onChatRoomInfo() {
    socket!.on('S_CHAT_ROOM_UPDATE', (data) {
      DatabaseService.insert('ChatRoomInfo', ChatRoomInfo.toMap(ref, data as Map<String, dynamic>));

      ChatRoomInfo.fromJson(ref, data).then((chatRoomInfo) {
        ref.read(chatRoomInfoProvider.notifier).update(chatRoomInfo);
      });
    });
  }

  Future<void> leaveRoom(String chatRoomId) async {
    await post(path: '$basePath/exit', queryParams: {'chatRoomId': chatRoomId}).run(ref, (_) {
      DatabaseService.delete('ChatRoomInfo', where: 'id = ?', whereArgs: [chatRoomId]);
      DatabaseService.delete('Message', where: 'chatRoomId = ?', whereArgs: [chatRoomId]);
      DatabaseService.delete('ChatUserInfo', where: 'chatRoomId = ?', whereArgs: [chatRoomId]);
      ref.read(chatRoomInfoProvider.notifier).remove(chatRoomId);
    }, errorMessage: 'exit_err01'.tr());
  }

  void inviteUsers(List<String> ids) {
    socket!.emit('C_INVITE_USER', {'inviteeIds': ids});
  }

  void onInviteUsers() {
    socket!.on('S_CREATE_GROUP_CHAT_ROOM', (data) {
      router.go(MainLayout.routeName);
      ref.read(loadingProvider.notifier).on();
      socket!.on('S_LEAVE_ROOM', (_) {
        socket!.off('S_LEAVE_ROOM');

        joinRoom(data['chatRoomId'], data['chatRoomName']);
      });
    });
  }

  void onUpdatedMessages(ValueNotifier<List<Message>> messages) {
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

  void kickUser(String userId) {
    socket!.emit('C_KICK_USER', {'targetUserId': userId});
  }

  void onKickUser() {
    socket!.on('S_KICKED', (_) {
      router.pop();
      errorToast(message: '강퇴되었습니다.');
    });
  }

  void catchError() {
    socket!.on('S_ERROR', (data) {
      print('에러: $data');
      ref.read(loadingProvider.notifier).off();
      if (data is Map && data['status'] == 401) {
        UserService.refreshAccessToken().then((token) {
          connectSocket(callback: _callback, accessToken: token);
        });
      }
    });
  }
}
