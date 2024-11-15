import 'package:anychat/service/friend_service.dart';
import 'package:anychat/state/friend_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/friend.dart';
import '../router.dart';

class HideFriendPage extends HookConsumerWidget {
  static const String routeName = '/hide';

  const HideFriendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showPopup = useState<Friend?>(null);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FriendService().getHidden(ref);
      });

      return () {};
    }, []);

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
            title: const Text('숨긴 친구 관리',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            centerTitle: true),
        body: Stack(children: [
          SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Column(children: [
                    ...ref.watch(hiddenFriendsProvider).map((friend) {
                      return _manageContainer(ref, context, friend, showPopup);
                    }),
                    SizedBox(height: 20.h)
                  ]))),
          _showPopup(context: context, ref: ref, showPopup: showPopup)
        ]));
  }

  Widget _manageContainer(
      WidgetRef ref, BuildContext context, Friend friend, ValueNotifier<Friend?> showPopup) {
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
                GestureDetector(
                    onTap: () {
                      showPopup.value = friend;
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

  Widget _showPopup(
          {required BuildContext context,
          required WidgetRef ref,
          required ValueNotifier<Friend?> showPopup}) =>
      SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(children: [
            if (showPopup.value != null)
              GestureDetector(
                  onTap: () {
                    showPopup.value = null;
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                  )),
            AnimatedPositioned(
                bottom: showPopup.value == null ? -100 - 200.h : 50.h,
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: 353.w,
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                          onTap: () {
                            if (showPopup.value == null) return;
                            FriendService().unHideFriend(ref, showPopup.value!.id);
                            showPopup.value = null;
                          },
                          child: Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: const DefaultTextStyle(
                                  style: TextStyle(
                                      color: Color(0xFF3B3B3B),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                  child: Text('친구 목록으로 복귀')))),
                      Divider(
                          height: 1,
                          color: const Color(0xFFE0E2E4),
                          thickness: 1,
                          indent: 20.w,
                          endIndent: 37.w),
                      GestureDetector(
                          onTap: () {
                            if (showPopup.value == null) return;
                            FriendService().blockFriend(ref, showPopup.value!.id);
                            showPopup.value = null;
                          },
                          child: Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: const DefaultTextStyle(
                                  style: TextStyle(
                                      color: Color(0xFFFF0000),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                  child: Text('차단'))))
                    ],
                  ),
                ))
          ]));
}
