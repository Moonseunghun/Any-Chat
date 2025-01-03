import 'package:anychat/page/login/consent_page.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/login_service.dart';
import 'package:anychat/service/user_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/language.dart';
import '../main_layout.dart';
import 'login_with_email_page.dart';

class LoginPage extends HookConsumerWidget {
  static const String routeName = '/login';

  const LoginPage(this.language, {super.key});

  final Language language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(flex: 168, child: SizedBox(width: double.infinity)),
        Image.asset('assets/images/logo.png', width: 230.w),
        const Expanded(flex: 81, child: SizedBox()),
        InkWell(
            onTap: () {
              final LoginService loginService = LoginService();

              loginService.signInWithGoogle(ref).then((value) {
                if (value) {
                  loginService.registerCheck(ref).then((result) {
                    if (result) {
                      loginService.login(ref).then((_) async {
                        await UserService().getMe(ref).then((_) async {
                          await UserService().setLanguage(ref, language, callbackPop: false);
                          router.go(MainLayout.routeName);
                        });
                      });
                    } else {
                      router.go(ConsentPage.routeName, extra: language);
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
                    Positioned.fill(
                        child: Align(
                            alignment: Alignment.center,
                            child: Text('login_google'.tr(),
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w600)))),
                  ],
                ))),
        const Expanded(flex: 18, child: SizedBox()),
        InkWell(
            onTap: () {
              final LoginService loginService = LoginService();

              loginService.signInWithApple(ref).then((value) {
                if (value) {
                  loginService.registerCheck(ref).then((result) {
                    if (result) {
                      loginService.login(ref).then((_) async {
                        await UserService().getMe(ref).then((_) async {
                          await UserService().setLanguage(ref, language, callbackPop: false);
                          router.go(MainLayout.routeName);
                        });
                      });
                    } else {
                      router.go(ConsentPage.routeName, extra: language);
                    }
                  });
                }
              });
            },
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
                    Positioned.fill(
                        child: Align(
                            alignment: Alignment.center,
                            child: Text('login_apple'.tr(),
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)))),
                  ],
                ))),
        const Expanded(flex: 18, child: SizedBox()),
        InkWell(
            onTap: () {
              router.push(LoginWithEmailPage.routeName, extra: language);
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
                        left: 16.w,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset('assets/images/anychat_icon.png', width: 34.r))),
                    Positioned.fill(
                        child: Align(
                            alignment: Alignment.center,
                            child: Text('login_anychat'.tr(),
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.bold)))),
                  ],
                ))),
        const Expanded(flex: 171, child: SizedBox()),
      ],
    ));
  }
}
