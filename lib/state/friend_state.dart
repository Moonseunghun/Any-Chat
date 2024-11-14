import 'package:anychat/model/friend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsNotifier extends StateNotifier<List<Friend>> {
  FriendsNotifier(super.state);

  void setFriends(List<Friend> friends) {
    state = friends;
  }

  void addFriend(Friend friend) {
    state = [...state, friend]..sort((a, b) {
        final koreanRegex = RegExp(r'^[가-힣]');

        final isAKorean = koreanRegex.hasMatch(a.nickname);
        final isBKorean = koreanRegex.hasMatch(b.nickname);

        if (isAKorean && !isBKorean) return -1;
        if (!isAKorean && isBKorean) return 1;

        return a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase());
      });
  }

  void pinned(int id) {
    state = state.map((e) {
      if (e.id == id) {
        return e.copyWith(isPinned: true);
      }
      return e;
    }).toList();
  }

  void unpinned(int id) {
    state = state.map((e) {
      if (e.id == id) {
        return e.copyWith(isPinned: false);
      }
      return e;
    }).toList();
  }
}

final friendsProvider = StateNotifierProvider<FriendsNotifier, List<Friend>>((ref) {
  return FriendsNotifier([]);
});
