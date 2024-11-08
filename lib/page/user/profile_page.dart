import 'package:anychat/page/router.dart';
import 'package:anychat/state/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilePage extends HookConsumerWidget {
  static const String routeName = '/profile';

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Row(
                children: [
                  SizedBox(width: 10.w),
                  GestureDetector(
                      onTap: () {
                        router.pop();
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
              const Spacer(),
              SizedBox(
                  width: 140.r,
                  height: 140.r,
                  child: ClipOval(
                    child: FittedBox(child: Image.asset('assets/images/default_profile.png')),
                  )),
              SizedBox(height: 16.h),
              Text(
                user.name,
                style: TextStyle(
                    fontSize: 16.r, color: const Color(0xFFF5F5F5), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    user.userInfo.message ?? '여기에 상태메세지를 입력해주세요',
                    style: TextStyle(
                        fontSize: 12.r,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF5F5F5)),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(height: 28.h),
              const Divider(color: Color(0xFFE0E2E4), thickness: 1),
              SizedBox(height: 10.h),
              GestureDetector(
                  onTap: () {},
                  child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      child: SvgPicture.asset('assets/images/edit.svg', width: 60.r))),
              SizedBox(height: 10.h),
              Text(
                '프로필편집',
                style: TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14.r, color: const Color(0xFFF5F5F5)),
              ),
              SizedBox(height: 60.h)
            ],
          )),
        ));
  }
}
