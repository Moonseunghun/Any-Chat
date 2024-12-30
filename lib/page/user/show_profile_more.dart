import 'package:anychat/model/chat.dart';
import 'package:anychat/model/friend.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/friend_service.dart';
import 'package:anychat/state/friend_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/overlay.dart';

showProfileMore(BuildContext context, WidgetRef ref, Friend? friend, ChatUserInfo? chatUser) {
  OverlayComponent.showOverlay(
      context: context,
      child: Stack(children: [
        GestureDetector(
            onTap: () {
              OverlayComponent.hideOverlay();
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            )),
        Positioned(
            top: 104.h,
            right: 22.w,
            child: Container(
                width: 151.w,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0x40000000),
                          offset: Offset(2.w, 2.h),
                          blurRadius: 10.r,
                          spreadRadius: 0)
                    ]),
                child: Column(children: [
                  if (ref.read(friendsProvider).contains(friend) ||
                      ref
                          .read(friendsProvider)
                          .map((e) => e.friend.userId)
                          .contains(chatUser?.id)) ...[
                    _menuItem('친구 숨김', () {
                      if (friend != null) {
                        FriendService().hideFriend(ref, friend.id);
                      } else {
                        FriendService().hideFriend(
                            ref,
                            ref
                                .read(friendsProvider)
                                .firstWhere((e) => e.friend.userId == chatUser!.id)
                                .id);
                      }
                    }),
                    const Divider(color: Color(0xFFE0E2E4), height: 1, thickness: 1),
                    const Divider(color: Color(0xFFE0E2E4), height: 1, thickness: 1),
                    _menuItem('친구 차단', () {
                      if (friend != null) {
                        FriendService().blockFriend(ref, friend.id).then((_) {
                          router.pop();
                        });
                      } else {
                        FriendService().blockFriend(
                            ref,
                            ref
                                .read(friendsProvider)
                                .firstWhere((e) => e.friend.userId == chatUser!.id)
                                .id);
                      }
                    })
                  ],
                  if (ref.read(hiddenFriendsProvider).contains(friend) ||
                      ref
                          .read(hiddenFriendsProvider)
                          .map((e) => e.friend.userId)
                          .contains(chatUser?.id)) ...[
                    _menuItem('친구 숨김 해제', () {
                      if (friend != null) {
                        FriendService().unHideFriend(ref, friend.id);
                      } else {
                        FriendService().unHideFriend(
                            ref,
                            ref
                                .read(hiddenFriendsProvider)
                                .firstWhere((e) => e.friend.userId == chatUser!.id)
                                .id);
                      }
                    }),
                    const Divider(color: Color(0xFFE0E2E4), height: 1, thickness: 1),
                    _menuItem('친구 차단', () {
                      if (friend != null) {
                        FriendService().blockFriend(ref, friend.id).then((_) {
                          router.pop();
                        });
                      } else {
                        FriendService().blockFriend(
                            ref,
                            ref
                                .read(hiddenFriendsProvider)
                                .firstWhere((e) => e.friend.userId == chatUser!.id)
                                .id);
                      }
                    })
                  ],
                  if (!ref
                          .read(friendsProvider)
                          .map((e) => e.friend.userId)
                          .contains(chatUser?.id) &&
                      !ref
                          .read(hiddenFriendsProvider)
                          .map((e) => e.friend.userId)
                          .contains(chatUser?.id) &&
                      !ref
                          .read(blockFriendsProvider)
                          .map((e) => e.friend.userId)
                          .contains(chatUser?.id)) ...[
                    _menuItem('친구 추가', () {
                      if (chatUser?.profileId != null) {
                        FriendService().addFriend(ref, chatUser!.profileId!);
                      }
                    })
                  ],
                ])))
      ]));
}

Widget _menuItem(String title, Function onTap) {
  return GestureDetector(
      onTap: () {
        OverlayComponent.hideOverlay();
        onTap();
      },
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 9.h),
          color: Colors.transparent,
          child: DefaultTextStyle(
              style: TextStyle(
                  fontSize: 16.r,
                  color: const Color(0xFF3B3B3B),
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis),
              child: Text(title))));
}
