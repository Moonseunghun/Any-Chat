import 'dart:io';

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
  final DateTime updatedAt;
  final int unreadCount;

  const ChatRoomInfo({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.updatedAt,
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
      'lastMessage': json['lastMessage'],
      'profileImg': opponent != null ? opponent['profileImg'] : null,
      'updatedAt': json['updatedAt'],
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
      profileImg = await CacheManager.getCachedImage(json['profileImg']);
    }

    return ChatRoomInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      lastMessage: json['lastMessage'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      unreadCount: json['unreadCount'] as int,
      profileImg: profileImg,
    );
  }

  @override
  List<Object?> get props => [id];
}

class ChatUserInfo {
  final String id;
  final String name;
  final File? profileImg;

  ChatUserInfo({
    required this.id,
    required this.name,
    this.profileImg,
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

    if (json['profileImg'] != null) {
      profileImg = await CacheManager.getCachedImage(json['profileImg']);
    }
    if (json['userInfo'] != null && json['userInfo']['profileImg'] != null) {
      profileImg = await CacheManager.getCachedImage(json['userInfo']['profileImg']);
    }

    return ChatUserInfo(id: json['userId'], name: json['name'], profileImg: profileImg);
  }
}
