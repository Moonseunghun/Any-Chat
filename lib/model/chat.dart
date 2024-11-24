import 'dart:io';

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

class ChatRoomInfo {
  final String id;
  final String name;
  final String lastMessage;
  final File? profileImg;
  final DateTime updatedAt;
  final int unreadCount;

  ChatRoomInfo({
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

  static Future<ChatRoomInfo> fromJson(Map<String, dynamic> json) async {
    File? profileImg;

    if (json['profileImg'] != null && json['profileImg'] != null) {
      final File? cachedImage = await CacheManager.getCachedImage(json['profileImg']);
      if (cachedImage != null) {
        profileImg = cachedImage;
      } else {
        profileImg = await CacheManager.downloadAndCacheImage(json['profileImg']);
      }
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
}
