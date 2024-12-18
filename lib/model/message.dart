import 'dart:convert';
import 'dart:io';

import 'package:anychat/common/cache_manager.dart';
import 'package:anychat/model/chat.dart';
import 'package:anychat/service/user_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_compress/video_compress.dart';

enum MessageStatus { loading, fail }

enum MessageType {
  text(1000),
  image(1002),
  video(1003),
  file(1006),
  invite(2000),
  leave(2001),
  kick(2002);

  final int value;

  const MessageType(this.value);

  static MessageType fromValue(int value) {
    return MessageType.values.firstWhere((e) => e.value == value);
  }
}

class LoadingMessage {
  final dynamic content;
  final String senderId;
  final MessageType messageType;
  final MessageStatus status;
  final DateTime createdAt;

  LoadingMessage({
    required this.content,
    required this.senderId,
    required this.messageType,
    required this.status,
    required this.createdAt,
  });

  dynamic showMessage({List<ChatUserInfo>? participants}) {
    switch (messageType) {
      case MessageType.text:
        return content as String;
      case MessageType.image:
        return content as File;
      case MessageType.video:
        return content as File;
      case MessageType.file:
        return content as File;
      default:
        return '';
    }
  }
}

class Message extends Equatable {
  final String id;
  final String chatRoomId;
  final int seqId;
  final String senderId;
  final dynamic content;
  final MessageType messageType;
  final int? totalParticipants;
  final int? readCount;
  final DateTime createdAt;
  final String lang;

  const Message(
      {required this.id,
      required this.chatRoomId,
      required this.seqId,
      required this.senderId,
      required this.content,
      required this.messageType,
      this.totalParticipants,
      this.readCount,
      required this.createdAt,
      required this.lang});

  dynamic showMessage({List<ChatUserInfo>? participants}) {
    switch (messageType) {
      case MessageType.text:
        return content as String;
      case MessageType.image:
        return content as Map<String, dynamic>;
      case MessageType.video:
        return content as Map<String, dynamic>;
      case MessageType.file:
        return content as Map<String, dynamic>;
      case MessageType.invite:
        return '${(content as Map<String, dynamic>)['inviterName']}님께서 ${(content as Map<String, dynamic>)['inviteeNames'].join(', ')}님을 초대했습니다.';
      case MessageType.leave:
        return '${(content as Map<String, dynamic>)['exitUserName']}님께서 퇴장하였습니다.';
      case MessageType.kick:
        return '${(content as Map<String, dynamic>)['kickerName']}님께서 ${(content as Map<String, dynamic>)['kickedName']}님을 강퇴했습니다.';
    }
  }

  static Future<Message> fromJson(
      WidgetRef ref, List<ChatUserInfo>? participants, Map<String, dynamic> json) async {
    final MessageType messageType = MessageType.fromValue(json['messageType'] as int);

    late final dynamic content;

    if (messageType == MessageType.text) {
      content = json['content'] as String;
    } else if (messageType == MessageType.invite) {
      final map = (json['content'] is String ? jsonDecode(json['content']) : json['content'])
          as Map<String, dynamic>;

      final ChatUserInfo? inviter =
          participants!.where((e) => e.id == map['inviterId']).firstOrNull;

      final List<String> inviteeNames = [];

      for (final String id in map['inviteeIds']) {
        final ChatUserInfo? invitee = participants.where((e) => e.id == id).firstOrNull;
        if (invitee != null) {
          inviteeNames.add(invitee.name);
        } else {
          inviteeNames.add(await UserService().getUserName(ref, id));
        }
      }
      late final String inviterName;

      if (inviter == null) {
        inviterName = await UserService().getUserName(ref, map['inviterId']);
      } else {
        inviterName = inviter.name;
      }

      content = {'inviterName': inviterName, 'inviteeNames': inviteeNames};
    } else if (messageType == MessageType.kick) {
      final map = (json['content'] is String ? jsonDecode(json['content']) : json['content'])
          as Map<String, dynamic>;

      final ChatUserInfo? kicker =
          participants!.where((e) => e.id == map['kickedById']).firstOrNull;
      final ChatUserInfo? kicked =
          participants.where((e) => map['kickedOutId'] == e.id).firstOrNull;

      late final String kickerName;
      late final String kickedName;

      if (kicker == null) {
        kickerName = await UserService().getUserName(ref, map['kickedById']);
      } else {
        kickerName = kicker.name;
      }

      if (kicked == null) {
        kickedName = await UserService().getUserName(ref, map['kickedOutId']);
      } else {
        kickedName = kicked.name;
      }

      content = {'kickerName': kickerName, 'kickedName': kickedName};
    } else if (messageType == MessageType.leave) {
      final map = (json['content'] is String ? jsonDecode(json['content']) : json['content'])
          as Map<String, dynamic>;

      final ChatUserInfo? exitUser =
          participants!.where((e) => e.id == map['exitUserId']).firstOrNull;

      late final String exitUserName;

      if (exitUser == null) {
        exitUserName = await UserService().getUserName(ref, map['exitUserId']);
      } else {
        exitUserName = exitUser.name;
      }

      content = {'exitUserName': exitUserName};
    } else if (messageType == MessageType.image || messageType == MessageType.file) {
      final Map<String, dynamic> map =
          (json['content'] is String ? jsonDecode(json['content']) : json['content']);

      content = {
        'file': await CacheManager.getCachedFile(map['fileUrl']),
        'fileName': map['fileName']
      };
    } else if (messageType == MessageType.video) {
      final Map<String, dynamic> map =
          (json['content'] is String ? jsonDecode(json['content']) : json['content']);

      final File file = await CacheManager.getCachedFile(map['fileUrl']);
      final File thumbnail = await VideoCompress.getFileThumbnail(file.path, quality: 50);
      content = {'file': file, 'thumbnail': thumbnail, 'fileName': map['fileName']};
    }

    return Message(
        id: json['id'] as String? ?? json['messageId'] as String,
        chatRoomId: json['chatRoomId'] as String,
        seqId: json['seqId'] as int,
        senderId: json['senderId'] as String,
        content: content,
        messageType: messageType,
        totalParticipants:
            json['totalParticipants'] == null ? null : json['totalParticipants'] as int,
        readCount: json['readCount'] == null ? 1 : json['readCount'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        lang: json['lang'] as String);
  }

  static Map<String, dynamic> toMap(Map<String, dynamic> json) {
    return {
      'id': json['id'] as String? ?? json['messageId'] as String,
      'chatRoomId': json['chatRoomId'],
      'seqId': json['seqId'],
      'senderId': json['senderId'],
      'content': json['content'] is String ? json['content'] : jsonEncode(json['content']),
      'messageType': json['messageType'],
      'totalParticipants': json['totalParticipants'],
      'readCount': json['readCount'],
      'createdAt': json['createdAt'],
      'lang': json['lang']
    };
  }

  Message copyWith({int? readCount, int? totalParticipants}) {
    return Message(
        id: id,
        chatRoomId: chatRoomId,
        seqId: seqId,
        senderId: senderId,
        content: content,
        messageType: messageType,
        totalParticipants: totalParticipants ?? this.totalParticipants,
        readCount: readCount ?? this.readCount,
        createdAt: createdAt,
        lang: lang);
  }

  @override
  List<Object?> get props => [id];
}
