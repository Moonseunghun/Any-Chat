import 'package:anychat/page/router.dart';
import 'package:anychat/service/friend_service.dart';
import 'package:anychat/state/friend_state.dart';
import 'package:anychat/state/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/friend.dart';

class ProfilePage extends HookConsumerWidget {
  static const String routeName = '/profile';

  const ProfilePage({this.friend, super.key});

  final Friend? friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = useState<bool>(false);
    final user = ref.watch(userProvider)!;
    final Friend? friend =
        ref.watch(friendsProvider).where((element) => element == this.friend).firstOrNull;

    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage('assets/images/default_profile_background.png')),
        ),
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.6),
          body: SafeArea(
              child: Column(
            children: [
              SizedBox(height: 10.h),
              Row(
                children: [
                  SizedBox(width: 10.w),
                  GestureDetector(
                      onTap: () {
                        if (isEditMode.value) {
                          isEditMode.value = false;
                        } else {
                          router.pop();
                        }
                      },
                      child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          child: const Icon(Icons.close, color: Colors.white, size: 24))),
                  const Spacer(),
                  if (friend != null)
                    GestureDetector(
                        onTap: () {
                          if (friend.isPinned) {
                            FriendService().unpinFriend(ref, friend.id);
                          } else {
                            FriendService().pinFriend(ref, friend.id);
                          }
                        },
                        child: Container(
                            color: Colors.transparent,
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                            child: SvgPicture.asset(
                              'assets/images/star.svg',
                              width: 24,
                              colorFilter: friend.isPinned
                                  ? const ColorFilter.mode(Colors.yellow, BlendMode.srcIn)
                                  : null,
                            ))),
                  GestureDetector(
                      onTap: () {},
                      child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                          child: SvgPicture.asset('assets/images/more.svg', width: 24))),
                  SizedBox(width: 10.w)
                ],
              ),
              if (isEditMode.value)
                Row(
                  children: [
                    SizedBox(width: 10.w),
                    GestureDetector(
                        onTap: () {},
                        child: Container(
                            color: Colors.transparent,
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                            child: SvgPicture.asset('assets/images/camera.svg', width: 24)))
                  ],
                ),
              const Spacer(),
              Stack(
                children: [
                  ClipOval(
                    child: Image.asset('assets/images/default_profile.png', height: 140),
                  ),
                  if (isEditMode.value)
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: SvgPicture.asset('assets/images/camera.svg', width: 24))
                ],
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                  onTap: () {
                    if (isEditMode.value) {}
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 38.w,
                        height: 18,
                      ),
                      Text(
                        friend?.nickname ?? user.name,
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFFF5F5F5), fontWeight: FontWeight.bold),
                      ),
                      Container(
                          width: 38.w,
                          height: 18,
                          alignment: Alignment.centerRight,
                          child: isEditMode.value
                              ? SvgPicture.asset('assets/images/pen.svg', height: 18)
                              : null)
                    ],
                  )),
              SizedBox(height: 12.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 38.w),
                  Text(
                    (friend?.friend.message ?? user.userInfo.message) ?? '여기에 상태메세지를 입력해주세요',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFF5F5F5)),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                      width: 38.w,
                      height: 18,
                      alignment: Alignment.centerRight,
                      child: isEditMode.value
                          ? SvgPicture.asset('assets/images/pen.svg', height: 18)
                          : null)
                ],
              ),
              SizedBox(height: 28.h),
              const Divider(color: Color(0xFFE0E2E4), thickness: 1),
              SizedBox(height: 10.h),
              SizedBox(
                  height: 74 + 32.h,
                  child: isEditMode.value
                      ? null
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(width: 20.w),
                            if (friend == null)
                              Column(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        isEditMode.value = true;
                                      },
                                      child: Container(
                                          color: Colors.transparent,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 10.h),
                                          child: SvgPicture.asset('assets/images/pen_circle.svg',
                                              width: 60))),
                                  const Spacer(),
                                  const Text(
                                    '프로필편집',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: Color(0xFFF5F5F5)),
                                  )
                                ],
                              ),
                            if (friend != null) ...[
                              Column(
                                children: [
                                  GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                          color: Colors.transparent,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 10.h),
                                          child: SvgPicture.asset('assets/images/chat.svg',
                                              width: 60))),
                                  const Spacer(),
                                  const Text(
                                    '채팅하기',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: Color(0xFFF5F5F5)),
                                  ),
                                  SizedBox(height: 9.h)
                                ],
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                          color: Colors.transparent,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 10.h),
                                          child: SvgPicture.asset('assets/images/voice_call.svg',
                                              width: 60))),
                                  const Spacer(),
                                  const Text(
                                    '음성채팅',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: Color(0xFFF5F5F5)),
                                  ),
                                  SizedBox(height: 9.h)
                                ],
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                          color: Colors.transparent,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 10.h),
                                          child: SvgPicture.asset('assets/images/face_call.svg',
                                              width: 60))),
                                  const Spacer(),
                                  const Text(
                                    '영상채팅',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: Color(0xFFF5F5F5)),
                                  ),
                                  SizedBox(height: 9.h)
                                ],
                              )
                            ],
                            SizedBox(width: 20.w)
                          ],
                        )),
              SizedBox(height: 60.h)
            ],
          )),
        ));
  }
}
