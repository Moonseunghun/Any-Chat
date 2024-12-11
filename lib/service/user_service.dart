import 'dart:io';

import 'package:anychat/common/cache_manager.dart';
import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:anychat/model/language.dart';
import 'package:anychat/model/user.dart';
import 'package:anychat/page/login/login_page.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/database_service.dart';
import 'package:anychat/state/friend_state.dart';
import 'package:anychat/state/user_state.dart';
import 'package:anychat/state/util_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/toast.dart';
import '../model/auth.dart';
import '../model/friend.dart';

class UserService extends SecuredHttpClient {
  final String basePath = '/account/api/users';

  Future<void> getMe(WidgetRef ref) async {
    await get(path: '$basePath/get-me', converter: (result) => result['data']).run(
      ref,
      (data) async {
        ref.read(userProvider.notifier).setUser(await User.fromJson(data));
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
        if (profileImage != null) 'profileImg': await MultipartFile.fromFile(profileImage.path),
        if (backgroundImage != null)
          'backgroundImg': await MultipartFile.fromFile(backgroundImage.path),
      }),
      converter: (result) => result['data'],
    ).run(ref, (data) async {
      File? profileImg;
      File? backgroundImg;
      if (profileImage != null) {
        profileImg = await CacheManager.getCachedFile(data['profileImg']);
      }

      if (backgroundImage != null) {
        backgroundImg = await CacheManager.getCachedFile(data['backgroundImg']);
      }

      ref.read(userProvider.notifier).updateProfile(
          name: name,
          stateMessage: stateMessage,
          profileImage: profileImg,
          backgroundImage: backgroundImg);
    }, errorMessage: '프로필 수정에 실패했습니다');
  }

  Future<void> setLanguage(WidgetRef ref, Language language) async {
    await put(path: '$basePath/language', queryParams: {'lang': language.code}).run(ref, (_) {
      ref.read(userProvider.notifier).setLanguage(language);
      router.pop();
      errorToast(message: '언어 설정이 완료되었습니다');
    }, errorMessage: '언어 설정에 실패했습니다');
  }

  Future<String> getUserName(WidgetRef ref, String userId) async {
    final Friend? friend =
        ref.read(friendsProvider).where((e) => e.friend.userId == userId).firstOrNull;

    if (friend != null) {
      return friend.nickname;
    }

    return await get(
        path: '$basePath/user-id',
        queryParams: {'userId': userId},
        converter: (result) => result['data']).run(null, (data) {
      return data['name'];
    });
  }

  Future<void> logOut(WidgetRef ref) async {
    await Auth.clear();
    router.go(LoginPage.routeName);
    DatabaseService.delete('ChatRoomInfo');
    DatabaseService.delete('Message');
    DatabaseService.delete('Friends');
    DatabaseService.delete('ChatUserInfo');
    ref.read(userProvider.notifier).clear();
    ref.read(indexProvider.notifier).state = 0;
    CacheManager.clear();
  }
}
