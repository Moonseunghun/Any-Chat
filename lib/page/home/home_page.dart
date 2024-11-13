import 'package:anychat/model/friend.dart';
import 'package:anychat/page/home/show_setting_menu.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/friend_service.dart';
import 'package:anychat/state/friend_state.dart';
import 'package:anychat/state/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../user/profile_page.dart';
import 'add_freind.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldFavorites = useState<bool>(false);
    final foldFriends = useState<bool>(false);

    return Column(
      children: [
        Container(
            height: 50,
            alignment: Alignment.center,
            child: Row(
              children: [
                SizedBox(width: 20.w),
                const Text('친구',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3B3B3B))),
                const Spacer(),
                InkWell(
                    onTap: () {
                      addFriendPopup(context, ref);
                    },
                    child: SvgPicture.asset('assets/images/friend_add.svg', width: 24)),
                SizedBox(width: 7.w),
                InkWell(
                    onTap: () {
                      showSettingMenu(context);
                    },
                    child: SvgPicture.asset('assets/images/settings.svg', width: 24)),
                SizedBox(width: 20.w),
              ],
            )),
        Expanded(
            child: SingleChildScrollView(
                child: Column(children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFC74DFF).withOpacity(0.1),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Text('프로필', style: TextStyle(fontSize: 12.r, color: const Color(0xFF3B3B3B))),
          ),
          SizedBox(height: 8.h),
          Padding(padding: EdgeInsets.symmetric(horizontal: 20.w), child: _profileWidget(ref)),
          SizedBox(height: 8.h),
          InkWell(
              onTap: () {
                foldFavorites.value = !foldFavorites.value;
              },
              child: Container(
                  width: double.infinity,
                  color: const Color(0xFFC74DFF).withOpacity(0.1),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Text('즐겨찾기',
                          style: TextStyle(fontSize: 12.r, color: const Color(0xFF3B3B3B))),
                      const Spacer(),
                      Icon(
                          foldFavorites.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 12.r,
                          color: const Color(0xFF3B3B3B))
                    ],
                  ))),
          if (!foldFavorites.value &&
              ref.watch(friendsProvider).where((e) => e.isPinned).isNotEmpty)
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(children: [
                  SizedBox(height: 8.h),
                  ...ref
                      .watch(friendsProvider)
                      .where((e) => e.isPinned)
                      .map((friend) => _profileWidget(ref, friend: friend)),
                  SizedBox(height: 8.h)
                ])),
          InkWell(
              onTap: () {
                foldFriends.value = !foldFriends.value;
              },
              child: Container(
                  width: double.infinity,
                  color: const Color(0xFFC74DFF).withOpacity(0.1),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Text('친구 ${ref.watch(friendsProvider).length}명',
                          style: TextStyle(fontSize: 12.r, color: const Color(0xFF3B3B3B))),
                      const Spacer(),
                      Icon(foldFriends.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 12.r, color: const Color(0xFF3B3B3B))
                    ],
                  ))),
          if (!foldFriends.value && ref.watch(friendsProvider).isNotEmpty)
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(children: [
                  SizedBox(height: 8.h),
                  ...ref.watch(friendsProvider).map((friend) => _profileWidget(ref, friend: friend))
                ])),
          SizedBox(height: 100.h),
        ])))
      ],
    );
  }

  Widget _profileWidget(WidgetRef ref, {Friend? friend}) {
    return InkWell(
        onTap: () {
          if (friend != null) {
            FriendService().getFriendInfo(ref, friend.id).then((detail) {
              router.push(ProfilePage.routeName, extra: friend);
            });
          } else {
            router.push(ProfilePage.routeName);
          }
        },
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              children: [
                Image.asset('assets/images/default_profile.png', width: 44.r),
                SizedBox(width: 11.w),
                Text(friend?.nickname ?? ref.watch(userProvider)!.name,
                    style: TextStyle(
                        fontSize: 16.r,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3B3B3B)))
              ],
            )));
  }
}
