import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/friend.dart';
import '../../service/friend_service.dart';
import '../../state/friend_state.dart';
import '../../state/user_state.dart';
import '../main_layout.dart';
import '../router.dart';
import '../user/profile_page.dart';

class EditFriendPage extends HookConsumerWidget {
  static const String routeName = '/edit';

  const EditFriendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leadingWidth: 72,
                leading: GestureDetector(
                    onTap: () {
                      router.pop();
                    },
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: const Text('완료',
                          style: TextStyle(
                              fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                    )),
                title: const Text('편집',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                centerTitle: true)),
        body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification && notification.metrics.extentAfter == 0) {
                FriendService().getFriends(ref).then((value) {
                  friendsCursor = value;
                });
              }

              return false;
            },
            child: SingleChildScrollView(
                child: Column(children: [
              Container(
                width: double.infinity,
                color: const Color(0xFFC74DFF).withOpacity(0.1),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child:
                    Text('프로필', style: TextStyle(fontSize: 12.r, color: const Color(0xFF3B3B3B))),
              ),
              SizedBox(height: 8.h),
              _profileWidget(ref),
              SizedBox(height: 8.h),
              Container(
                  width: double.infinity,
                  color: const Color(0xFFC74DFF).withOpacity(0.1),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Text('즐겨찾기',
                          style: TextStyle(fontSize: 12.r, color: const Color(0xFF3B3B3B))),
                      const Spacer(),
                    ],
                  )),
              Column(children: [
                if (ref.watch(pinnedFriendsProvider).isNotEmpty) SizedBox(height: 8.h),
                ...ref
                    .watch(pinnedFriendsProvider)
                    .map((friend) => _profileWidget(ref, friend: friend)),
                if (ref.watch(pinnedFriendsProvider).isNotEmpty) SizedBox(height: 8.h)
              ]),
              Container(
                  width: double.infinity,
                  color: const Color(0xFFC74DFF).withOpacity(0.1),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Text('친구 ${ref.watch(friendCountProvider)}명',
                          style: TextStyle(fontSize: 12.r, color: const Color(0xFF3B3B3B))),
                      const Spacer(),
                    ],
                  )),
              Column(children: [
                SizedBox(height: 8.h),
                ...ref.watch(friendsProvider).map((friend) => _profileWidget(ref, friend: friend))
              ]),
              SizedBox(height: 100.h),
            ]))));
  }

  Widget _profileWidget(WidgetRef ref, {Friend? friend}) {
    return InkWell(
        onTap: () {
          if (friend != null) {
            FriendService().getFriendInfo(ref, friend.id).then((detail) {
              router.push(ProfilePage.routeName, extra: detail);
            });
          } else {
            router.push(ProfilePage.routeName);
          }
        },
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
            child: Row(
              children: [
                ClipOval(
                    child: (friend == null
                            ? ref.watch(userProvider)!.userInfo.profileImg == null
                                ? null
                                : Image.file(ref.watch(userProvider)!.userInfo.profileImg!,
                                    width: 44.r, height: 44.r, fit: BoxFit.fill)
                            : friend.friend.profileImg == null
                                ? null
                                : Image.file(friend.friend.profileImg!,
                                    width: 44.r, height: 44.r, fit: BoxFit.fill)) ??
                        Image.asset('assets/images/default_profile.png', width: 44.r)),
                SizedBox(width: 11.w),
                Text(friend?.nickname ?? ref.watch(userProvider)!.name,
                    style: TextStyle(
                        fontSize: 16.r,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3B3B3B))),
                const Spacer(),
                if (friend != null)
                  GestureDetector(
                      onTap: () {
                        FriendService().hideFriend(ref, friend.id);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xFFC74DFF)),
                        ),
                        child: Text('숨김',
                            style: TextStyle(fontSize: 12.r, color: const Color(0xFFC74DFF))),
                      ))
              ],
            )));
  }
}
