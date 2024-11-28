import 'dart:io';

import 'package:equatable/equatable.dart';

import '../common/cache_manager.dart';

class Friend extends Equatable {
  final int id;
  final String nickname;
  final String originName;
  final int friendTypeId;
  final bool isPinned;
  final ProfileInfo friend;

  const Friend(
      {required this.id,
      required this.nickname,
      required this.originName,
      required this.friendTypeId,
      required this.isPinned,
      required this.friend});

  static Future<Friend> fromJson(Map<String, dynamic> json) async {
    return Friend(
      id: json['id'],
      nickname: json['nickname'],
      originName: json['originName'],
      friendTypeId: json['friendTypeId'],
      isPinned: json['isPinned'],
      friend: await ProfileInfo.fromJson(json['friend']),
    );
  }

  static Future<Friend> fromMap(Map<String, dynamic> json) async {
    final profileInfo = {'id': json['stringId'], 'profileImg': json['profileImg']};

    return Friend(
      id: json['id'],
      nickname: json['nickName'],
      originName: json['originName'],
      friendTypeId: json['friendTypeId'],
      isPinned: (json['isPinned'] as int) == 1 ? true : false,
      friend: await ProfileInfo.fromJson(profileInfo),
    );
  }

  static Map<String, dynamic> toMap(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'stringId': json['friend']['id'],
      'nickName': json['nickname'],
      'originName': json['originName'],
      'friendTypeId': json['friendTypeId'],
      'isPinned': json['isPinned'] as bool ? 1 : 0,
      'profileImg': json['friend']['profileImg'],
    };
  }

  Friend copyWith(
      {int? id,
      String? nickname,
      String? originName,
      int? friendTypeId,
      bool? isPinned,
      ProfileInfo? friend}) {
    return Friend(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      originName: originName ?? this.originName,
      friendTypeId: friendTypeId ?? this.friendTypeId,
      isPinned: isPinned ?? this.isPinned,
      friend: friend ?? this.friend,
    );
  }

  @override
  List<Object?> get props => [id];
}

class ProfileInfo {
  final String id;
  final File? profileImg;
  final File? backgroundImg;
  final String? stateMessage;

  ProfileInfo({required this.id, required this.profileImg, this.backgroundImg, this.stateMessage});

  static Future<ProfileInfo> fromJson(Map<String, dynamic> json) async {
    File? profileImg;
    File? backgroundImg;
    if (json['profileImg'] != null) {
      profileImg = await CacheManager.getCachedImage(json['profileImg']);
    }

    if (json['backgroundImg'] != null) {
      backgroundImg = await CacheManager.getCachedImage(json['backgroundImg']);
    }

    return ProfileInfo(
        id: json['id'],
        profileImg: profileImg,
        backgroundImg: backgroundImg,
        stateMessage: json['stateMessage']);
  }
}

extension FriendsExtension on List<Friend> {
  List<Friend> sortByName() {
    final koreanRegex = RegExp(r'^[가-힣]');

    return this
      ..sort((a, b) {
        final isAKorean = koreanRegex.hasMatch(a.nickname);
        final isBKorean = koreanRegex.hasMatch(b.nickname);

        if (isAKorean && !isBKorean) return -1;
        if (!isAKorean && isBKorean) return 1;

        return a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase());
      });
  }
}
