import '../main.dart';

Auth? auth;

class Auth {
  final String accessToken;
  final String refreshToken;

  Auth({
    required this.accessToken,
    required this.refreshToken,
  }) {
    prefs.setString('access_token', accessToken);
    prefs.setString('refresh_token', refreshToken);
  }

  Auth copyWith({
    String? accessToken,
    String? refreshToken,
  }) {
    return Auth(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  static clear() async {
    auth = null;
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('totalCount');
    await prefs.remove('uuid');
  }
}
