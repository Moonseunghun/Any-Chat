import 'dart:convert';
import 'dart:io';

import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:anychat/model/language.dart';
import 'package:anychat/model/user.dart';
import 'package:anychat/page/login/register_page.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

import '../common/config.dart';
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
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
              serverClientId:
                  '763579885192-epakl69dn21vroig9bplttg03rdbnmul.apps.googleusercontent.com')
          .signIn();

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleUser == null || googleAuth == null) return false;

      await prefs.setString('login_type', 'google.com');
      await prefs.setString('id_token', googleAuth.idToken!);

      result = true;
    } catch (error) {
      errorToast(message: "fail_login_google".tr());
      result = false;
    } finally {
      ref.read(loadingProvider.notifier).off();
    }

    return result;
  }

  Future<bool> signInWithApple(WidgetRef ref) async {
    late final bool result;
    ref.read(loadingProvider.notifier).on();
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      if (credential.idToken == null) return false;
      await prefs.setString('login_type', 'apple.com');
      await prefs.setString('id_token', credential.idToken!);

      result = true;
    } catch (error) {
      errorToast(message: "fail_login_apple".tr());
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

  Future<void> register(WidgetRef ref, Language language, String profileId) async {
    final params = {
      'idToken': prefs.getString('id_token'),
      'providerTypeId': LoginType.getByProviderId(prefs.getString('login_type')!).value,
      'profileId': profileId,
      'lang': language.code,
      'fcmToken': 'tmp',
      'deviceId': await _getDeviceId(),
      'deviceUUID': _getUUID()
    };

    await post(
        path: '$basePath/register/social',
        queryParams: params,
        converter: (result) => result['data']).run(ref, (data) {
      auth = Auth(accessToken: data['accessToken'], refreshToken: data['refreshToken']);
    }, errorHandler: (error) {
      if (error.statusCode == 403) {
        errorToast(message: '중복된 ID입니다');
      } else {
        errorToast(message: '회원가입에 실패했습니다');
      }
    });
  }

  Future<void> registerWithEmail(
      WidgetRef ref, Language language, String profileId, String nickname) async {
    final params = {
      'email': email,
      'password': password,
      'name': nickname,
      'profileId': profileId,
      'lang': language.code,
      'fcmToken': 'tmp',
      'deviceId': await _getDeviceId(),
      'deviceUUID': _getUUID()
    };

    await post(
        path: '$basePath/register/email',
        queryParams: params,
        converter: (result) => result['data']).run(ref, (data) {
      auth = Auth(accessToken: data['accessToken'], refreshToken: data['refreshToken']);
    }, errorHandler: (error) {
      if (error.statusCode == 403) {
        errorToast(message: '중복된 ID입니다');
      } else {
        errorToast(message: '회원가입에 실패했습니다');
      }
    });
  }

  Future<void> login(WidgetRef ref) async {
    final LoginType loginType = LoginType.getByProviderId(prefs.getString('login_type')!);

    final params = {
      'idToken': prefs.getString('id_token'),
      'providerTypeId': loginType.value,
      'fcmToken': 'tmp',
      'deviceId': await _getDeviceId(),
      'deviceUUID': _getUUID()
    };

    await post(
        path: '$basePath/login/social',
        queryParams: params,
        converter: (result) => result['data']).run(
      ref,
      (data) {
        auth = Auth(accessToken: data['accessToken'], refreshToken: data['refreshToken']);
      },
      errorMessage: loginType == LoginType.apple
          ? 'fail_login_apple'.tr()
          : loginType == LoginType.google
              ? 'fail_login_google'.tr()
              : 'fail_login_anychat'.tr(),
    );
  }

  Future<void> loginWithEmail(WidgetRef ref, String email, String password) async {
    final params = {'fcmToken': 'tmp', 'deviceId': await _getDeviceId(), 'deviceUUID': _getUUID()};

    final String credentials = "$email:$password";

    final String encodedCredentials = base64Encode(utf8.encode(credentials));

    await Dio()
        .post('${HttpConfig.url}$basePath/login/email',
            data: params,
            options: Options(headers: {
              'Authorization': 'Basic $encodedCredentials',
              'Content-Type': 'application/json'
            }))
        .then((result) async {
      final data = result.data['data'];
      auth = Auth(accessToken: data['accessToken'], refreshToken: data['refreshToken']);
    }).catchError((error) {
      print(error);
      errorToast(message: 'fail_anychatlogin'.tr());
    });
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

  String _getUUID() {
    late final String uuid;

    if (prefs.getString('uuid') != null) {
      uuid = prefs.getString('uuid')!;
    } else {
      uuid = const Uuid().v4();
      prefs.setString('uuid', uuid);
    }

    return uuid;
  }
}
