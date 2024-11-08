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

  User({required this.id, required this.name, required this.userInfo, required this.phoneNumbers});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      userInfo: UserInfo.fromJson(json['userInfo']),
      phoneNumbers: List<String>.from(json['phoneNumbers']),
    );
  }
}

class UserInfo {
  final String userId;
  final String? profileId;
  final String lang;
  final String? profileImg;
  final String? backgroundImg;
  final String? message;

  UserInfo(
      {required this.userId,
      required this.profileId,
      required this.lang,
      required this.profileImg,
      required this.backgroundImg,
      required this.message});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'],
      profileId: json['profileId'],
      lang: json['lang'],
      profileImg: json['profileImg'],
      backgroundImg: json['backgroundImg'],
      message: json['message'],
    );
  }
}
