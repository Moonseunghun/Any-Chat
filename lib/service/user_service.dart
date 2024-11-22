import 'dart:io';

import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:anychat/model/language.dart';
import 'package:anychat/model/user.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/state/user_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/toast.dart';

class UserService extends SecuredHttpClient {
  final String basePath = '/account/api/users';

  Future<void> getMe(WidgetRef ref) async {
    await get(path: '$basePath/get-me', converter: (result) => result['data']).run(
      ref,
      (data) {
        ref.read(userProvider.notifier).setUser(User.fromJson(data));
      },
      errorMessage: '내 정보를 불러오는데 실패했습니다',
    );
  }

  Future<void> setProfileId(WidgetRef ref, String profileId) async {
    await put(
        path: '$basePath/profile-id',
        queryParams: {'profileId': profileId},
        converter: (result) => result).run(ref, (_) {
      ref.read(userProvider.notifier).setProfileId(profileId);
      router.pop();
      errorToast(message: 'ID 설정이 완료되었습니다');
    }, errorHandler: (error) {
      if (error.statusCode == 409) {
        errorToast(message: '이미 사용중인 ID입니다');
      } else {
        errorToast(message: 'ID 설정에 실패했습니다');
      }
    });
  }

  Future<void> updateProfile(WidgetRef ref,
      {String? name, String? stateMessage, File? profileImage, File? backgroundImage}) async {
    await put(
      path: '$basePath/profile',
      isMultipart: true,
      queryParams: FormData.fromMap({
        if (name != null) 'name': name,
        if (stateMessage != null) 'stateMessage': stateMessage,
        if (profileImage != null) 'profileImage': await MultipartFile.fromFile(profileImage.path),
        if (backgroundImage != null)
          'backgroundImage': await MultipartFile.fromFile(backgroundImage.path),
      }),
      converter: (result) => result['data'],
    ).run(ref, (data) {
      ref.read(userProvider.notifier).updateProfile(
          name: name,
          stateMessage: stateMessage,
          profileImage: data['profileImg'],
          backgroundImage: data['backgroundImg']);
    }, errorMessage: '프로필 수정에 실패했습니다');
  }

  Future<void> setLanguage(WidgetRef ref, Language language) async {
    await put(path: '$basePath/language', queryParams: {'lang': language.code}).run(ref, (_) {
      ref.read(userProvider.notifier).setLanguage(language);
      router.pop();
      errorToast(message: '언어 설정이 완료되었습니다');
    }, errorMessage: '언어 설정에 실패했습니다');
  }
}
