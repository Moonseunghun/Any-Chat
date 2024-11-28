import 'dart:convert';

import 'package:anychat/model/chat.dart';
import 'package:equatable/equatable.dart';

enum MessageType {
  text(1000),
  image(1002),
  video(1003),
  audio(1004),
  file(1005),
  invite(2000),
  leave(2001),
  kick(2002);

  final int value;

  const MessageType(this.value);

  static MessageType fromValue(int value) {
    return MessageType.values.firstWhere((e) => e.value == value);
  }
}

class Message<T> extends Equatable {
  final String id;
  final String chatRoomId;
  final int seqId;
  final String senderId;
  final T content;
  final MessageType messageType;
  final int? totalParticipants;
  final int? readCount;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.chatRoomId,
    required this.seqId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.totalParticipants,
    this.readCount,
    required this.createdAt,
  });

  String showMessage({List<ChatUserInfo>? participants}) {
    switch (messageType) {
      case MessageType.text:
        return content as String;
      case MessageType.image:
        return (content as Map<String, dynamic>)['fileUrl'];
      case MessageType.video:
        return 'Video';
      case MessageType.audio:
        return 'Audio';
      case MessageType.file:
        return 'File';
      case MessageType.invite:
        final ChatUserInfo? inviter = participants!
            .where((e) => e.id == (content as Map<String, dynamic>)['inviterId'])
            .firstOrNull;
        final List<ChatUserInfo> invitee = participants
            .where((e) => (content as Map<String, dynamic>)['inviteeIds'].contains(e.id))
            .toList();
        return inviter == null
            ? ''
            : '${inviter.name}님께서 ${invitee.map((e) => e.name).join(', ')}님을 초대했습니다.';
      case MessageType.leave:
        return 'Leave';
      case MessageType.kick:
        return 'Kick';
    }
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    final MessageType messageType = MessageType.fromValue(json['messageType'] as int);

    late final dynamic content;

    if (messageType == MessageType.text) {
      content = json['content'] as String;
    } else {
      content = (json['content'] is String ? jsonDecode(json['content']) : json['content'])
          as Map<String, dynamic>;
    }

    return Message(
      id: json['id'] as String? ?? json['messageId'] as String,
      chatRoomId: json['chatRoomId'] as String,
      seqId: json['seqId'] as int,
      senderId: json['senderId'] as String,
      content: content as T,
      messageType: messageType,
      totalParticipants:
          json['totalParticipants'] == null ? null : json['totalParticipants'] as int,
      readCount: json['readCount'] == null ? 1 : json['readCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
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
    };
  }

  Message copyWith({int? readCount}) {
    return Message(
        id: id,
        chatRoomId: chatRoomId,
        seqId: seqId,
        senderId: senderId,
        content: content,
        messageType: messageType,
        totalParticipants: totalParticipants,
        readCount: readCount ?? this.readCount,
        createdAt: createdAt);
  }

  @override
  List<Object?> get props => [id];
}
