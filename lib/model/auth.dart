import '../main.dart';

Auth? auth;

class Auth {
  final String accessToken;
  final String refreshToken;

  Auth({
    required this.accessToken,
    required this.refreshToken,
  }) {
    prefs.setString('auth_token', accessToken);
    prefs.setString('refresh_token', refreshToken);
  }
}
