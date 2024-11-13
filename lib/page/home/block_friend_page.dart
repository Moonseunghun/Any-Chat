import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/overlay.dart';
import '../../model/friend.dart';
import '../../state/friend_state.dart';
import '../router.dart';

class BlockFriendPage extends HookConsumerWidget {
  static const String routeName = '/block';

  const BlockFriendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 48,
            leading: IconButton(
                onPressed: () {
                  router.pop();
                },
                icon: const Icon(Icons.close, color: Color(0xFF3B3B3B), size: 24)),
            title: const Text('차단 친구 관리',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            centerTitle: true),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(children: [
                  ...ref.watch(friendsProvider).map((friend) {
                    return _manageContainer(ref, context, friend);
                  }),
                  SizedBox(height: 20.h)
                ]))));
  }

  Widget _manageContainer(WidgetRef ref, BuildContext context, Friend friend) {
    return InkWell(
        onTap: () {},
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(
              children: [
                Image.asset('assets/images/default_profile.png', width: 44.r),
                SizedBox(width: 11.w),
                Text(friend.nickname,
                    style: TextStyle(
                        fontSize: 16.r,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3B3B3B))),
                const Spacer(),
                InkWell(
                    onTap: () {
                      _showPopup(context: context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFC74DFF)),
                      ),
                      child: Text('관리',
                          style: TextStyle(fontSize: 12.r, color: const Color(0xFFC74DFF))),
                    ))
              ],
            )));
  }

  void _showPopup({required BuildContext context}) {
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
              bottom: 50.h,
              child: Container(
                width: 353.w,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                alignment: Alignment.center,
                child: GestureDetector(
                    onTap: () {},
                    child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const DefaultTextStyle(
                            style: TextStyle(
                                color: Color(0xFF3B3B3B),
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                            child: Text('차단 해제')))),
              ))
        ]));
  }
}
