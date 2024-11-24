import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:anychat/common/toast.dart';
import 'package:anychat/service/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/friend.dart';
import '../state/friend_state.dart';

class FriendService extends SecuredHttpClient {
  final String basePath = '/friend/api';

  Future<void> getFriends(WidgetRef ref) async {
    DatabaseService.search('Friends', where: 'isPinned = ?', whereArgs: [0]).then((value) async {
      List<Friend> friends = [];

      for (final friend in value) {
        friends.add(await Friend.fromMap(friend));
      }

      ref.read(friendsProvider.notifier).setFriends(friends);
    });

    await get(path: '$basePath?take=200', converter: (result) => result['data']).run(ref,
        (data) async {
      List<Friend> friends = [];

      DatabaseService.batchInsert(
          'Friends',
          List<dynamic>.from(data['data'])
              .map((e) => Friend.toMap(e as Map<String, dynamic>))
              .toList());

      for (final friend in List<dynamic>.from(data['data'])) {
        friends.add(await Friend.fromJson(friend as Map<String, dynamic>));
      }

      ref.read(friendsProvider.notifier).setFriends(friends);
    }, errorMessage: '친구 목록을 불러오는 중 오류가 발생했습니다');
  }

  Future<void> getPinned(WidgetRef ref) async {
    DatabaseService.search('Friends', where: 'isPinned = ?', whereArgs: [1]).then((value) async {
      List<Friend> friends = [];

      for (final friend in value) {
        friends.add(await Friend.fromMap(friend));
      }

      ref.read(friendsProvider.notifier).setFriends(friends);
    });

    await get(path: '$basePath/pinned', converter: (result) => result['data']).run(null,
        (data) async {
      List<Friend> friends = [];

      DatabaseService.batchInsert(
          'Friends',
          List<dynamic>.from(data['data'])
              .map((e) => Friend.toMap(e as Map<String, dynamic>))
              .toList());

      for (final friend in List<dynamic>.from(data['data'])) {
        friends.add(await Friend.fromJson(friend as Map<String, dynamic>));
      }

      ref.read(pinnedFriendsProvider.notifier).setPinned(friends);
    }, errorMessage: '친구 목록을 불러오는 중 오류가 발생했습니다');
  }

  Future<void> getHidden(WidgetRef ref) async {
    await get(path: '$basePath/hidden-friends', converter: (result) => result['data']).run(ref,
        (data) async {
      List<Friend> friends = [];

      for (final friend in List<dynamic>.from(data['data'])) {
        friends.add(await Friend.fromJson(friend as Map<String, dynamic>));
      }

      ref.read(hiddenFriendsProvider.notifier).setHidden(friends);
    }, errorMessage: '친구 목록을 불러오는 중 오류가 발생했습니다');
  }

  Future<void> addFriend(WidgetRef ref, String friendId) async {
    await post(path: '$basePath/add-friend/$friendId', converter: (result) => result['data'])
        .run(ref, (data) async {
      ref
          .read(friendsProvider.notifier)
          .addFriend(await Friend.fromJson(data as Map<String, dynamic>));
      errorToast(message: '친구 추가가 완료되었습니다');
    }, errorHandler: (error) {
      if (error.statusCode == 400) {
        errorToast(message: '존재하지 않거나 이미 추가된 사용자입니다');
      } else {
        errorToast(message: '친구 추가에 실패했습니다');
      }
    });
  }

  Future<Friend> getFriendInfo(WidgetRef ref, int indexId) async {
    return await get(path: '$basePath/$indexId', converter: (result) => result['data']).run(
        ref, (data) => Friend.fromJson(data as Map<String, dynamic>),
        errorMessage: '친구 정보를 불러오는 중 오류가 발생했습니다');
  }

  Future<void> pinFriend(WidgetRef ref, int id) async {
    await put(path: '$basePath/pinned/$id', converter: (result) => result).run(null, (data) {
      ref.read(friendsProvider.notifier).pinned(id);
      ref.read(pinnedFriendsProvider.notifier).pinned(ref, id);
    }, errorMessage: '친구를 고정하는 중 오류가 발생했습니다');
  }

  Future<void> unpinFriend(WidgetRef ref, int id) async {
    put(path: '$basePath/unpinned/$id', converter: (result) => result).run(null, (data) {
      ref.read(friendsProvider.notifier).unpinned(id);
      ref.read(pinnedFriendsProvider.notifier).unpinned(id);
    }, errorMessage: '친구 고정을 해제하는 중 오류가 발생했습니다');
  }

  Future<void> hideFriend(WidgetRef ref, int id) async {
    await put(path: '$basePath/hide-friend/$id', converter: (result) => result).run(ref, (data) {
      ref.read(hiddenFriendsProvider.notifier).hide(ref, id);
    }, errorMessage: '친구를 숨기는 중 오류가 발생했습니다');
  }

  Future<void> unHideFriend(WidgetRef ref, int id) async {
    await put(path: '$basePath/unhide-friend/$id', converter: (result) => result).run(ref, (data) {
      ref.read(hiddenFriendsProvider.notifier).unHide(ref, id);
    }, errorMessage: '친구 숨김을 해제하는 중 오류가 발생했습니다');
  }

  Future<void> getBlocked(WidgetRef ref) async {
    await get(path: '$basePath/blocked-friends', converter: (result) => result['data']).run(ref,
        (data) async {
      List<Friend> friends = [];

      for (final friend in List<dynamic>.from(data['data'])) {
        friends.add(await Friend.fromJson(friend as Map<String, dynamic>));
      }

      ref.read(blockFriendsProvider.notifier).setBlocked(friends);
    }, errorMessage: '차단된 친구 목록을 불러오는 중 오류가 발생했습니다');
  }

  Future<void> blockFriend(WidgetRef ref, int id) async {
    await put(path: '$basePath/block-friend/$id', converter: (result) => result).run(ref, (data) {
      ref.read(blockFriendsProvider.notifier).block(ref, id);
    }, errorMessage: '친구를 차단하는 중 오류가 발생했습니다');
  }

  Future<void> unBlockFriend(WidgetRef ref, int id) async {
    await put(path: '$basePath/unblock-friend/$id', converter: (result) => result).run(ref, (data) {
      ref.read(blockFriendsProvider.notifier).unBlock(ref, id);
    }, errorMessage: '친구 차단을 해제하는 중 오류가 발생했습니다');
  }
}
