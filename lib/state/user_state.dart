import 'dart:io';

import 'package:anychat/model/language.dart';
import 'package:anychat/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/cache_manager.dart';
import '../main.dart';

class UserNotifier extends StateNotifier<User?> {
  UserNotifier(super.state) {
    if (prefs.getString('profileImg') != null) {
      CacheManager.getCachedFile(prefs.getString('profileImg')!).then((cachedImage) {
        state = state!.copyWith(userInfo: state!.userInfo.copyWith(profileImg: cachedImage));
      });
    }

    if (prefs.getString('backgroundImg') != null) {
      CacheManager.getCachedFile(prefs.getString('backgroundImg')!).then((cachedImage) {
        state = state!.copyWith(userInfo: state!.userInfo.copyWith(backgroundImg: cachedImage));
      });
    }
  }

  void clear() {
    state = null;
  }

  void setUser(User user) {
    state = user;
  }

  void setProfileId(String profileId) {
    state = state!.copyWith(userInfo: state!.userInfo.copyWith(profileId: profileId));
  }

  void setLanguage(Language language) {
    state = state!.copyWith(userInfo: state!.userInfo.copyWith(lang: language.code));
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
