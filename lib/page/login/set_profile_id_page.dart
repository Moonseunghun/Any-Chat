import 'package:anychat/model/language.dart';
import 'package:anychat/model/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/toast.dart';
import '../../service/login_service.dart';
import '../../service/user_service.dart';
import '../main_layout.dart';
import '../router.dart';

class SetProfileIdPage extends HookConsumerWidget {
  static const String routeName = '/set-profile-id';

  const SetProfileIdPage(this.language, {super.key});

  final Language language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idController = useTextEditingController();

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 153.h),
              Padding(
                  padding: EdgeInsets.only(left: 20.w),
                  child: Text('profile_id_title'.tr(),
                      style: const TextStyle(fontSize: 20, color: Color(0xFF7C4DFF)))),
              SizedBox(height: 10.h),
              const Divider(color: Color(0xFFBABABA), thickness: 1),
              SizedBox(height: 50.h),
              Padding(
                  padding: EdgeInsets.only(left: 20.w, right: 40.w),
                  child: TextField(
                      controller: idController,
                      decoration: InputDecoration(
                          hintText: 'profile_id'.tr(),
                          hintStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.black.withOpacity(0.5),
                              fontWeight: FontWeight.w500),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                          border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 1))))),
              SizedBox(height: 80.h),
              Padding(
                  padding: EdgeInsets.only(left: 20.w, right: 104.w),
                  child: Text('profile_id_ex'.tr(),
                      style: const TextStyle(fontSize: 12, color: Colors.black))),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (!isValidProfileId(idController.text.trim())) {
                    errorToast(message: 'profile_id_warn'.tr());
                    return;
                  }

                  loginService.register(language, idController.text.trim()).then((_) async {
                    await userService.getMe().then((_) => router.go(MainLayout.routeName));
                  });
                },
                child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                        color: const Color(0xFF7C4DFF), borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text('btn_confirm'.tr(),
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)))),
              ),
              SizedBox(height: 57.h)
            ])));
  }
}
