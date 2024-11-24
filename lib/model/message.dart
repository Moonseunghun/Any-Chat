enum MessageType {
  text(1000);

  final int value;

  const MessageType(this.value);
}

class Message {
  final String id;
  final String chatRoomId;
  final int seqId;
  final String senderId;
  final String content;
  final MessageType messageType;
  final int readCount;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.seqId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.readCount,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String? ?? json['messageId'] as String,
      chatRoomId: json['chatRoomId'] as String,
      seqId: json['seqId'] as int,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      messageType: MessageType.values.firstWhere((e) => e.value == json['messageType'] as int),
      readCount: json['readCount'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static Map<String, dynamic> toMap(Map<String, dynamic> json) {
    return {
      'id': json['id'] as String? ?? json['messageId'] as String,
      'chatRoomId': json['chatRoomId'],
      'seqId': json['seqId'],
      'senderId': json['senderId'],
      'content': json['content'],
      'messageType': json['messageType'],
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
        readCount: readCount ?? this.readCount,
        createdAt: createdAt);
  }
}
