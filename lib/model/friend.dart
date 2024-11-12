import 'package:equatable/equatable.dart';

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

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        id: json['id'],
        nickname: json['nickname'],
        originName: json['originName'],
        friendTypeId: json['friendTypeId'],
        isPinned: json['isPinned'],
        friend: ProfileInfo.fromJson(json['friend']),
      );

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
  final String? profileImg;
  final String? backgroundImg;
  final String? message;

  ProfileInfo({required this.id, required this.profileImg, this.backgroundImg, this.message});

  factory ProfileInfo.fromJson(Map<String, dynamic> json) => ProfileInfo(
      id: json['id'],
      profileImg: json['profileImg'],
      backgroundImg: json['backgroundImg'],
      message: json['message']);
}
