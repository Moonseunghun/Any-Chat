import 'package:anychat/common/toast.dart';
import 'package:anychat/model/language.dart';
import 'package:anychat/model/user.dart';
import 'package:anychat/page/login/consent_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../router.dart';

String? email;
String? password;

class RegisterPage extends HookConsumerWidget {
  static const String routeName = '/register';

  const RegisterPage(this.language, {super.key});

  final Language language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();
    final TextEditingController passwordAgainController = useTextEditingController();

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
            title: Text('login_anychat'.tr(),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
            centerTitle: false),
        body: SingleChildScrollView(
            child: Column(children: [
          SizedBox(width: double.infinity, height: 70.h),
          Image.asset('assets/images/logo.png', width: 230.w),
          SizedBox(height: 22.h),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  _textField(context, emailController, 'enter_email'.tr()),
                  SizedBox(height: 18.h),
                  _textField(context, passwordController, 'enter_pw'.tr()),
                  SizedBox(height: 18.h),
                  _textField(context, passwordAgainController, 'enter_pw_again'.tr()),
                  SizedBox(height: 21.h),
                  GestureDetector(
                      onTap: () {
                        if (!isValidEmail(emailController.value.text)) {
                          errorToast(message: 'email_default'.tr());
                          return;
                        }

                        if (!isValidPassword(passwordController.value.text)) {
                          errorToast(message: 'profile_id_warn'.tr());
                          return;
                        }
                        if (passwordController.value.text != passwordAgainController.value.text) {
                          errorToast(message: 'enter_pw_again'.tr());
                          return;
                        }

                        email = emailController.value.text;
                        password = passwordController.value.text;
                        router.push(ConsentPage.routeName, extra: language);
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color(0xFF7C4DFF),
                            borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        alignment: Alignment.center,
                        child: Text('join_member'.tr(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ))
                ],
              ))
        ])));
  }

  Widget _textField(BuildContext context, TextEditingController controller, String hintText) =>
      TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        obscureText: hintText == 'enter_pw'.tr() || hintText == 'enter_pw_again'.tr(),
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
