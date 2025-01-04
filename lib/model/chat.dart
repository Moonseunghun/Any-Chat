import 'dart:convert';
import 'dart:io';

import 'package:anychat/model/language.dart';
import 'package:anychat/model/message.dart';
import 'package:anychat/service/translate_service.dart';
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
  final String targetLastMessage;
  final List<File?> profileImages;
  final MessageType messageType;
  final DateTime lastMessageUpdatedAt;
  final int unreadCount;
  final Language? language;

  const ChatRoomInfo({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.targetLastMessage,
    required this.messageType,
    required this.lastMessageUpdatedAt,
    required this.unreadCount,
    required this.profileImages,
    this.language,
  });

  static Map<String, dynamic> toMap(WidgetRef ref, Map<String, dynamic> json) {
    final opponents = List<dynamic>.from(json['profileImages'])
        .where((e) => e['userId'] != ref.read(userProvider)!.id)
        .toList();

    if (opponents.length > 4) {
      opponents.removeRange(4, opponents.length);
    }

    return {
      'id': json['id'],
      'name': json['name'],
      'lastMessage': json['lastMessage'] is String ? json['lastMessage'] : '파일',
      'profileImages':
          jsonEncode({'profileImages': opponents.map((e) => e['profileImg']).toList()}),
      'messageType': json['messageType'] as int,
      'lastMessageUpdatedAt': json['lastMessageUpdatedAt'],
      'unreadCount': json['unreadCount'],
      'lang': json['lang'],
    };
  }

  static Future<ChatRoomInfo> fromJson(WidgetRef ref, Map<String, dynamic> json) async {
    final List<File?> profileImages = [];

    final opponentsProfileImage = json['profileImages'] is String
        ? jsonDecode(json['profileImages'])['profileImages']
        : List<dynamic>.from(json['profileImages'])
            .where((e) => e['userId'] != ref.read(userProvider)!.id)
            .map((e) => e['profileImg'])
            .toList();

    if (opponentsProfileImage.length > 4) {
      opponentsProfileImage.removeRange(4, opponentsProfileImage.length);
    }

    for (final opponentProfileImage in opponentsProfileImage) {
      if (opponentProfileImage != null) {
        profileImages.add(await CacheManager.getCachedFile(opponentProfileImage));
      } else {
        profileImages.add(null);
      }
    }

    final MessageType messageType = MessageType.fromValue(json['messageType'] as int);
    final Language? language =
        json['lang'] == null || json['lang'] == '' ? null : Language.fromCode(json['lang']);

    final String targetLastMessage = messageType == MessageType.text
        ? json['lang'] == null || json['lang'] == ''
            ? json['lastMessage']
            : await translateService.translateLastMessage(json['lastMessage'], language!)
        : '';

    final String lastMessage = messageType == MessageType.text ? json['lastMessage'] : '';

    return ChatRoomInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        lastMessage: lastMessage,
        targetLastMessage: targetLastMessage,
        lastMessageUpdatedAt: DateTime.parse(json['lastMessageUpdatedAt'] as String).toLocal(),
        messageType: MessageType.fromValue(json['messageType'] as int),
        unreadCount: json['unreadCount'] as int,
        profileImages: profileImages,
        language: language);
  }

  ChatRoomInfo copyWith({
    String? id,
    String? name,
    String? lastMessage,
    String? targetLastMessage,
    List<File>? profileImages,
    MessageType? messageType,
    DateTime? lastMessageUpdatedAt,
    int? unreadCount,
    Language? lang,
  }) {
    return ChatRoomInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      targetLastMessage: targetLastMessage ?? this.targetLastMessage,
      profileImages: profileImages ?? this.profileImages,
      messageType: messageType ?? this.messageType,
      lastMessageUpdatedAt: lastMessageUpdatedAt ?? this.lastMessageUpdatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      language: lang ?? language,
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
