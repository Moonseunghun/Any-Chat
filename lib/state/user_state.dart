import 'package:anychat/model/language.dart';
import 'package:anychat/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserNotifier extends StateNotifier<User?> {
  UserNotifier(super.state);

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
      {String? name, String? stateMessage, String? profileImage, String? backgroundImage}) {
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

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) => UserNotifier(null));
