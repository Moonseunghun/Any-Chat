import 'dart:io';

import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:anychat/model/user.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../common/toast.dart';
import '../main.dart';
import '../model/auth.dart';
import '../state/util_state.dart';

class LoginService extends HttpClient {
  final String basePath = '/account/api/auth';

  Future<bool> signInWithGoogle(WidgetRef ref) async {
    late final bool result;
    ref.read(loadingProvider.notifier).on();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleUser == null || googleAuth == null) return false;

      await prefs.setString('login_type', 'google.com');
      await prefs.setString('id_token', googleAuth.idToken!);

      result = true;
    } catch (error) {
      errorToast(message: "구글 계정 로그인에 실패했습니다");
      result = false;
    } finally {
      ref.read(loadingProvider.notifier).off();
    }

    return result;
  }

  Future<bool> registerCheck(WidgetRef ref) async {
    final params = {
      'idToken': prefs.getString('id_token'),
      'providerTypeId': LoginType.getByProviderId(prefs.getString('login_type')!).value
    };

    return await post(
        path: '$basePath/check', queryParams: params, converter: (result) => result['data']).run(
      ref,
      (result) => result['isRegistered'],
      errorMessage: '회원가입 여부를 확인하는데 실패했습니다',
    );
  }

  Future<void> register(WidgetRef ref) async {
    final params = {
      'idToken': prefs.getString('id_token'),
      'providerTypeId': LoginType.getByProviderId(prefs.getString('login_type')!).value,
      'profileId': "TEST",
      'lang': 'ko',
      'fcmToken': 'tmp',
      'deviceId': await _getDeviceId(),
    };

    await post(
        path: '$basePath/register/social',
        queryParams: params,
        converter: (result) => result['data']).run(
      ref,
      (data) {
        auth = Auth(accessToken: data['accessToken'], refreshToken: data['refreshToken']);
      },
      errorMessage: '회원가입에 실패했습니다',
    );
  }

  Future<void> login(WidgetRef ref) async {
    final params = {
      'idToken': prefs.getString('id_token'),
      'providerTypeId': LoginType.getByProviderId(prefs.getString('login_type')!).value,
      'fcmToken': 'tmp',
      'deviceId': await _getDeviceId(),
    };

    await post(
        path: '$basePath/login/social',
        queryParams: params,
        converter: (result) => result['data']).run(
      ref,
      (data) {
        auth = Auth(accessToken: data['accessToken'], refreshToken: data['refreshToken']);
      },
      errorMessage: '로그인에 실패했습니다',
    );
  }

  Future<String> _getDeviceId() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.id;
    } else {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      return iosInfo.identifierForVendor ?? '';
    }
  }
}
