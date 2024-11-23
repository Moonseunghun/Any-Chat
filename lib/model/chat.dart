import 'dart:io';

import 'package:anychat/state/user_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/cache_manager.dart';

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

  static Future<ChatRoomInfo> fromJson(WidgetRef ref, Map<String, dynamic> json) async {
    File? profileImg;
    final opponent = List<dynamic>.from(json['profileImages'])
        .where((e) => e['userId'] != ref.read(userProvider)!.id)
        .firstOrNull;

    if (opponent != null && opponent['profileImg'] != null) {
      final File? cachedImage = await CacheManager.getCachedImage(opponent['profileImg']);
      if (cachedImage != null) {
        profileImg = cachedImage;
      } else {
        profileImg = await CacheManager.downloadAndCacheImage(opponent['profileImg']);
      }
    }

    return ChatRoomInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      lastMessage: json['lastMessage'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      unreadCount: json['unreadCount'] as int,
      profileImg: profileImg,
    );
  }
}
