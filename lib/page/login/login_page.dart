import 'package:anychat/page/login/language_select_page.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/login_service.dart';
import 'package:anychat/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../service/chat_service.dart';
import '../main_layout.dart';

class LoginPage extends HookConsumerWidget {
  static const String routeName = '/login';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: double.infinity, height: 168.h),
        Image.asset('assets/images/logo.png', width: 230.w),
        SizedBox(height: 81.h),
        InkWell(
            onTap: () {
              final LoginService loginService = LoginService();

              loginService.signInWithGoogle(ref).then((value) {
                if (value) {
                  loginService.registerCheck(ref).then((result) {
                    if (result) {
                      loginService.login(ref).then((_) async {
                        ChatService().connectSocket();
                        await UserService().getMe(ref).then((_) => router.go(MainLayout.routeName));
                      });
                    } else {
                      router.go(LanguageSelectPage.routeName, extra: true);
                    }
                  });
                }
              });
            },
            child: Container(
                width: 358.w,
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD4D4D4)),
                    borderRadius: BorderRadius.circular(6.r)),
                child: Stack(
                  children: [
                    Positioned.fill(
                        left: 24.w,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: SvgPicture.asset('assets/images/google.svg', width: 22.r))),
                    const Positioned.fill(
                        child: Align(
                            alignment: Alignment.center,
                            child: Text('Google로 로그인',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w600)))),
                  ],
                ))),
        SizedBox(height: 18.h),
        InkWell(
            onTap: () {},
            child: Container(
                width: 358.w,
                height: 50,
                decoration: BoxDecoration(
                    color: const Color(0xFF303030), borderRadius: BorderRadius.circular(6.r)),
                child: Stack(
                  children: [
                    Positioned.fill(
                        left: 24.w,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: SvgPicture.asset('assets/images/apple.svg', width: 22.r))),
                    const Positioned.fill(
                        child: Align(
                            alignment: Alignment.center,
                            child: Text('Apple로 로그인',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)))),
                  ],
                )))
      ],
    ));
  }
}
