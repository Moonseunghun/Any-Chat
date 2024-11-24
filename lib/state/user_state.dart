import 'dart:io';

import 'package:anychat/model/language.dart';
import 'package:anychat/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/cache_manager.dart';
import '../main.dart';

class UserNotifier extends StateNotifier<User?> {
  UserNotifier(super.state) {
    if (prefs.getString('profileImg') != null) {
      CacheManager.getCachedImage(prefs.getString('profileImg')!).then((cachedImage) {
        if (cachedImage != null) {
          state = state!.copyWith(userInfo: state!.userInfo.copyWith(profileImg: cachedImage));
        } else {
          CacheManager.downloadAndCacheImage(prefs.getString('profileImg')!).then((image) {
            state = state!.copyWith(userInfo: state!.userInfo.copyWith(profileImg: image));
          });
        }
      });
    }

    if (prefs.getString('backgroundImg') != null) {
      CacheManager.getCachedImage(prefs.getString('backgroundImg')!).then((cachedImage) {
        if (cachedImage != null) {
          state = state!.copyWith(userInfo: state!.userInfo.copyWith(backgroundImg: cachedImage));
        } else {
          CacheManager.downloadAndCacheImage(prefs.getString('backgroundImg')!).then((image) {
            state = state!.copyWith(userInfo: state!.userInfo.copyWith(backgroundImg: image));
          });
        }
      });
    }
  }

  void setUser(User user) {
    state = user;
  }

  void setProfileId(String profileId) {
    state = state!.copyWith(userInfo: state!.userInfo.copyWith(profileId: profileId));
  }

  void setLanguage(Language language) {
    state = state!.copyWith(userInfo: state!.userInfo.copyWith(lang: language.name));
  }

  void updateProfile(
      {String? name, String? stateMessage, File? profileImage, File? backgroundImage}) {
    state = state!.copyWith(
      name: name ?? state!.name,
      userInfo: state!.userInfo.copyWith(
        stateMessage: stateMessage ?? state!.userInfo.stateMessage,
        profileImg: profileImage ?? state!.userInfo.profileImg,
        backgroundImg: backgroundImage ?? state!.userInfo.backgroundImg,
      ),
    );
  }
}

final userProvider =
    StateNotifierProvider<UserNotifier, User?>((ref) => UserNotifier(User.getUser()));
