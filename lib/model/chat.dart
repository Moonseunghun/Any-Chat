import 'dart:io';

import 'package:anychat/model/message.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/cache_manager.dart';
import '../state/user_state.dart';

class ChatRoomHeader {
  final String chatRoomId;
  final String chatRoomName;

  ChatRoomHeader({
    required this.chatRoomId,
    required this.chatRoomName,
  });
}

class ChatRoomInfo extends Equatable {
  final String id;
  final String name;
  final String lastMessage;
  final File? profileImg;
  final MessageType messageType;
  final DateTime lastMessageUpdatedAt;
  final int unreadCount;

  const ChatRoomInfo({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.messageType,
    required this.lastMessageUpdatedAt,
    required this.unreadCount,
    this.profileImg,
  });

  static Map<String, dynamic> toMap(WidgetRef ref, Map<String, dynamic> json) {
    final opponent = List<dynamic>.from(json['profileImages'])
        .where((e) => e['userId'] != ref.read(userProvider)!.id)
        .firstOrNull;

    return {
      'id': json['id'],
      'name': json['name'],
      'lastMessage': json['lastMessage'] is String ? json['lastMessage'] : '파일',
      'profileImg': opponent != null ? opponent['profileImg'] : null,
      'messageType': json['messageType'] as int,
      'lastMessageUpdatedAt': json['lastMessageUpdatedAt'],
      'unreadCount': json['unreadCount'],
    };
  }

  static Future<ChatRoomInfo> fromJson(WidgetRef ref, Map<String, dynamic> json) async {
    File? profileImg;

    if (json['profileImages'] != null) {
      final opponent = List<dynamic>.from(json['profileImages'])
          .where((e) => e['userId'] != ref.read(userProvider)!.id)
          .firstOrNull;

      json['profileImg'] = opponent != null ? opponent['profileImg'] : null;
    }

    if (json['profileImg'] != null) {
      profileImg = await CacheManager.getCachedFile(json['profileImg']);
    }

    return ChatRoomInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      lastMessage: json['lastMessage'] is String ? json['lastMessage'] : '파일',
      lastMessageUpdatedAt: DateTime.parse(json['lastMessageUpdatedAt'] as String).toLocal(),
      messageType: MessageType.fromValue(json['messageType'] as int),
      unreadCount: json['unreadCount'] as int,
      profileImg: profileImg,
    );
  }

  ChatRoomInfo copyWith({
    String? id,
    String? name,
    String? lastMessage,
    File? profileImg,
    MessageType? messageType,
    DateTime? lastMessageUpdatedAt,
    int? unreadCount,
  }) {
    return ChatRoomInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      profileImg: profileImg ?? this.profileImg,
      messageType: messageType ?? this.messageType,
      lastMessageUpdatedAt: lastMessageUpdatedAt ?? this.lastMessageUpdatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [id];
}

class ChatUserInfo {
  final String id;
  final String name;
  final File? profileImg;
  final File? backgroundImg;
  final String? profileId;
  final String? stateMessage;

  ChatUserInfo({
    required this.id,
    required this.name,
    this.profileImg,
    this.backgroundImg,
    this.profileId,
    this.stateMessage,
  });

  static Map<String, dynamic> toMap(String chatRoomId, Map<String, dynamic> json) {
    return {
      'chatRoomId': chatRoomId,
      'userId': json['userId'],
      'name': json['name'],
      'profileImg': json['userInfo']['profileImg'],
    };
  }

  static Future<ChatUserInfo> fromJson(Map<String, dynamic> json) async {
    File? profileImg;
    File? backgroundImg;

    if (json['profileImg'] != null) {
      profileImg = await CacheManager.getCachedFile(json['profileImg']);
    }
    if (json['userInfo'] != null && json['userInfo']['profileImg'] != null) {
      profileImg = await CacheManager.getCachedFile(json['userInfo']['profileImg']);
    }
    if (json['userInfo'] != null && json['userInfo']['backgroundImg'] != null) {
      backgroundImg = await CacheManager.getCachedFile(json['userInfo']['backgroundImg']);
    }

    return ChatUserInfo(
        id: json['userId'] ?? json['id'],
        name: json['name'],
        profileImg: profileImg,
        backgroundImg: backgroundImg,
        profileId: json['userInfo'] == null ? null : json['userInfo']['profileId'],
        stateMessage: json['userInfo'] == null ? null : json['userInfo']['stateMessage']);
  }
}
