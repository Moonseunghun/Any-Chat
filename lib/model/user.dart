import 'dart:io';

import 'package:anychat/main.dart';

import '../common/cache_manager.dart';

enum LoginType {
  google(2),
  apple(3);

  final int value;

  const LoginType(this.value);

  factory LoginType.getByProviderId(String id) {
    switch (id) {
      case 'google.com':
        return google;
      case 'apple.com':
        return apple;
      default:
        throw Exception('Invalid LoginType value');
    }
  }
}

class User {
  final String id;
  final String name;
  final UserInfo userInfo;
  final List<String> phoneNumbers;
  final bool auto;

  User(
      {required this.id,
      required this.name,
      required this.userInfo,
      required this.phoneNumbers,
      this.auto = false});

  static Future<User> fromJson(Map<String, dynamic> json) async {
    prefs.setString('id', json['id']);
    prefs.setString('name', json['name']);

    return User(
      id: json['id'],
      name: json['name'],
      userInfo: await UserInfo.fromJson(json['userInfo']),
      phoneNumbers: [],
    );
  }

  User copyWith({
    String? name,
    UserInfo? userInfo,
    List<String>? phoneNumbers,
    bool? auto,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      userInfo: userInfo ?? this.userInfo,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      auto: auto ?? this.auto,
    );
  }

  static User? getUser() {
    if (prefs.getString('id') != null) {
      final User user = User(
          id: prefs.getString('id')!,
          name: prefs.getString('name')!,
          userInfo: UserInfo(
            profileId: prefs.getString('profileId'),
            lang: prefs.getString('lang')!,
            profileImg: null,
            backgroundImg: null,
            stateMessage: prefs.getString('stateMessage'),
          ),
          phoneNumbers: prefs.getStringList('phoneNumbers') ?? [],
          auto: true);

      return user;
    } else {
      return null;
    }
  }
}

class UserInfo {
  final String? profileId;
  final String lang;
  final File? profileImg;
  final File? backgroundImg;
  final String? stateMessage;

  UserInfo(
      {required this.profileId,
      required this.lang,
      required this.profileImg,
      required this.backgroundImg,
      required this.stateMessage});

  static Future<UserInfo> fromJson(Map<String, dynamic> json) async {
    File? profileImg;
    File? backgroundImg;
    if (json['profileImg'] != null) {
      profileImg = await CacheManager.getCachedFile(json['profileImg']);
    }

    if (json['backgroundImg'] != null) {
      backgroundImg = await CacheManager.getCachedFile(json['backgroundImg']);
    }

    prefs.setString('profileId', json['profileId']);
    prefs.setString('lang', json['lang']);
    if (json['profileImg'] != null) {
      prefs.setString('profileImg', json['profileImg']);
    }
    if (json['backgroundImg'] != null) {
      prefs.setString('backgroundImg', json['backgroundImg']);
    }
    if (json['stateMessage'] != null) {
      prefs.setString('stateMessage', json['stateMessage']);
    }

    return UserInfo(
      profileId: json['profileId'],
      lang: json['lang'],
      profileImg: profileImg,
      backgroundImg: backgroundImg,
      stateMessage: json['stateMessage'],
    );
  }

  UserInfo copyWith({
    String? profileId,
    String? lang,
    File? profileImg,
    File? backgroundImg,
    String? stateMessage,
  }) {
    return UserInfo(
      profileId: profileId ?? this.profileId,
      lang: lang ?? this.lang,
      profileImg: profileImg ?? this.profileImg,
      backgroundImg: backgroundImg ?? this.backgroundImg,
      stateMessage: stateMessage ?? this.stateMessage,
    );
  }
}

bool isValidProfileId(String profileId) =>
    RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,16}$').hasMatch(profileId);

bool isValidNickname(String nickname) =>
    RegExp(r'^(?:[가-힣]{8,16}|[가-힣\d]{8,16}|[a-zA-Z]{8,16}|[a-zA-Z\d]{8,16})$').hasMatch(nickname);

bool isValidPassword(String password) =>
    RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,16}$').hasMatch(password);

bool isValidEmail(String email) => RegExp(r'^(?=.*@).{8,30}$').hasMatch(email);
