import 'package:anychat/page/router.dart';
import 'package:anychat/state/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/auth.dart';

class ProfilePage extends HookConsumerWidget {
  static const String routeName = '/profile';

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = useState<bool>(false);
    final user = ref.watch(userProvider)!;

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
                          print(auth!.accessToken);
                          isEditMode.value = false;
                        } else {
                          router.pop();
                        }
                      },
                      child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          child: Icon(Icons.close, color: Colors.white, size: 24.r))),
                  const Spacer(),
                  GestureDetector(
                      onTap: () {},
                      child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                          child: SvgPicture.asset('assets/images/star.svg', width: 24.r))),
                  GestureDetector(
                      onTap: () {},
                      child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                          child: SvgPicture.asset('assets/images/more.svg', width: 24.r))),
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
                            child: SvgPicture.asset('assets/images/camera.svg', width: 24.r)))
                  ],
                ),
              const Spacer(),
              Stack(
                children: [
                  ClipOval(
                    child: Image.asset('assets/images/default_profile.png', height: 140.r),
                  ),
                  if (isEditMode.value)
                    Positioned(
                        right: 4.r,
                        bottom: 4.r,
                        child: SvgPicture.asset('assets/images/camera.svg', width: 24.w))
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
                        height: 18.r,
                      ),
                      Text(
                        user.name,
                        style: TextStyle(
                            fontSize: 16.r,
                            color: const Color(0xFFF5F5F5),
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                          width: 38.w,
                          height: 18.r,
                          alignment: Alignment.centerRight,
                          child: isEditMode.value
                              ? SvgPicture.asset('assets/images/pen.svg', height: 18.r)
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
                    user.userInfo.message ?? '여기에 상태메세지를 입력해주세요',
                    style: TextStyle(
                        fontSize: 12.r,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF5F5F5)),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                      width: 38.w,
                      height: 18.r,
                      alignment: Alignment.centerRight,
                      child: isEditMode.value
                          ? SvgPicture.asset('assets/images/pen.svg', height: 18.r)
                          : null)
                ],
              ),
              SizedBox(height: 28.h),
              const Divider(color: Color(0xFFE0E2E4), thickness: 1),
              SizedBox(height: 10.h),
              SizedBox(
                  height: 74.r + 32.h,
                  child: isEditMode.value
                      ? null
                      : Column(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  isEditMode.value = true;
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                    child: SvgPicture.asset('assets/images/pen_circle.svg',
                                        width: 60.r))),
                            const Spacer(),
                            Text(
                              '프로필편집',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.r,
                                  color: const Color(0xFFF5F5F5)),
                            )
                          ],
                        )),
              SizedBox(height: 60.h)
            ],
          )),
        ));
  }
}
