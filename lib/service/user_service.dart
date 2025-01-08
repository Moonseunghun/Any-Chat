import 'dart:io';
import 'dart:ui';

import 'package:anychat/common/cache_manager.dart';
import 'package:anychat/common/config.dart';
import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:anychat/model/chat.dart';
import 'package:anychat/model/language.dart';
import 'package:anychat/model/user.dart';
import 'package:anychat/page/login/language_select_page.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/database_service.dart';
import 'package:anychat/state/chat_state.dart';
import 'package:anychat/state/friend_state.dart';
import 'package:anychat/state/user_state.dart';
import 'package:anychat/state/util_state.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/toast.dart';
import '../model/auth.dart';
import '../model/friend.dart';
import '../page/login/register_page.dart';

late UserService userService;

class UserService extends SecuredHttpClient {
  final String basePath = '/account/api/users';

  final WidgetRef ref;

  UserService(this.ref);

  Future<void> getMe() async {
    await get(path: '$basePath/get-me', converter: (result) => result['data']).run(
      ref,
      (data) async {
        ref.read(userProvider.notifier).setUser(await User.fromJson(data));
      },
      errorMessage: '내 정보를 불러오는데 실패했습니다',
    );
  }

  Future<void> setProfileId(String profileId) async {
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

  Future<void> updateProfile(
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

  Future<void> setLanguage(Language language, {bool callbackPop = true}) async {
    await put(path: '$basePath/language', queryParams: {'lang': language.code}).run(ref, (_) {
      ref.read(userProvider.notifier).setLanguage(language);
      if (callbackPop) {
        ref.read(chatRoomInfoProvider.notifier).updateLanguage();
        router.pop();
        errorToast(message: 'chage_lang_suc'.tr());
      }
    }, errorMessage: '언어 설정에 실패했습니다');
  }

  Future<String> getUserName(String userId) async {
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

  Future<ChatUserInfo> getChatUserInfo(String userId) async {
    return await get(
        path: '$basePath/user-id',
        queryParams: {'userId': userId},
        converter: (result) => result['data']).run(ref, (data) {
      return ChatUserInfo.fromJson(data);
    });
  }

  Future<void> logOut() async {
    email = null;
    password = null;
    await Auth.clear();
    router.go(LanguageSelectPage.routeName);
    DatabaseService.delete('ChatRoomInfo');
    DatabaseService.delete('Message');
    DatabaseService.delete('Friends');
    DatabaseService.delete('ChatUserInfo');
    ref.read(userProvider.notifier).clear();
    ref.read(indexProvider.notifier).state = 0;
    CacheManager.clear();
  }

  Future<void> deleteAccount(BuildContext context) async {
    await delete(path: '/account/api/auth/cancel-account').run(ref, (_) {
      context.setLocale((Language.values
                  .where(
                      (e) => e.name.toUpperCase() == PlatformDispatcher.instance.locale.countryCode)
                  .firstOrNull ??
              Language.us)
          .locale);

      logOut();
      errorToast(message: 'del_account_suc'.tr());
    }, errorMessage: '계정 삭제에 실패했습니다');
  }

  static Future<String> refreshAccessToken() async {
    return await Dio()
        .post('${HttpConfig.url}/account/api/auth/access-token',
            options: Options(headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${auth!.refreshToken}'
            }))
        .then((result) async {
      auth = auth!.copyWith(accessToken: result.data['data']['accessToken']);
      return result.data['data']['accessToken'] as String;
    });
  }
}
