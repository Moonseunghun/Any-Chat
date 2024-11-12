import 'package:anychat/model/friend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsNotifier extends StateNotifier<List<Friend>> {
  FriendsNotifier(super.state);

  void setFriends(List<Friend> friends) {
    state = friends;
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
