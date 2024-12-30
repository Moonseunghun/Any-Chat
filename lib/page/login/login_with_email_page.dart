import 'package:anychat/common/toast.dart';
import 'package:anychat/model/language.dart';
import 'package:anychat/page/login/register_page.dart';
import 'package:anychat/service/login_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../service/user_service.dart';
import '../main_layout.dart';
import '../router.dart';

class LoginWithEmailPage extends HookConsumerWidget {
  static const String routeName = '/login_with_email';

  const LoginWithEmailPage(this.language, {super.key});

  final Language language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();

    return Scaffold(
        appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 20,
            leading: IconButton(
                onPressed: () {
                  router.pop();
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24)),
            title: Text('btn_login'.tr(),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
            centerTitle: false),
        body: SingleChildScrollView(
            child: Column(children: [
          SizedBox(width: double.infinity, height: 70.h),
          Image.asset('assets/images/logo.png', width: 230.w),
          SizedBox(height: 27.h),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  _textField(context, emailController, 'email_enter'.tr()),
                  SizedBox(height: 18.h),
                  _textField(context, passwordController, 'enter_pw'.tr()),
                  SizedBox(height: 21.h),
                  GestureDetector(
                      onTap: () {
                        if (emailController.value.text.isEmpty ||
                            passwordController.value.text.isEmpty) {
                          errorToast(message: 'fail_anychatlogin'.tr());
                          return;
                        }

                        LoginService()
                            .loginWithEmail(
                                ref, emailController.value.text, passwordController.value.text)
                            .then((_) async {
                          await UserService().getMe(ref).then((_) async {
                            await UserService().setLanguage(ref, language, callbackPop: false);
                            router.go(MainLayout.routeName);
                          });
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color(0xFF7C4DFF),
                            borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        alignment: Alignment.center,
                        child: Text('login_anychat'.tr(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      )),
                  SizedBox(height: 48.h),
                  TextButton(
                      onPressed: () {
                        router.push(RegisterPage.routeName, extra: language);
                      },
                      child: Text(
                        'join_member'.tr(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          color: Color(0xFF7A4DFF),
                        ),
                      )),
                  SizedBox(height: 20.h),
                ],
              ))
        ])));
  }

  Widget _textField(BuildContext context, TextEditingController controller, String hintText) =>
      TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        obscureText: hintText == 'enter_pw'.tr(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              const TextStyle(fontSize: 16, color: Color(0xFF909090), fontWeight: FontWeight.bold),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: const BorderSide(color: Color(0xFFD4D4D4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: const BorderSide(color: Color(0xFF7C4DFF)),
          ),
        ),
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
        },
      );
}
