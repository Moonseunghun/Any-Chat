import 'package:anychat/common/toast.dart';
import 'package:anychat/model/language.dart';
import 'package:anychat/page/login/privacy_page.dart';
import 'package:anychat/page/login/set_profile_id_page.dart';
import 'package:anychat/page/login/terms_page.dart';
import 'package:anychat/page/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ConsentPage extends HookConsumerWidget {
  static const String routeName = '/consent';

  const ConsentPage(this.language, {super.key});

  final Language language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstCheck = useState<bool>(false);
    final secondCheck = useState<bool>(false);

    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 153.h),
      Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text('agree_title'.tr(),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF)))),
      SizedBox(height: 10.h),
      const Divider(color: Color(0xFFBABABA), thickness: 1),
      SizedBox(height: 70.h),
      _buildCheckBox(content: 'agree_privacy'.tr(), check: firstCheck, url: TermsPage.routeName),
      _buildCheckBox(content: 'agree_terms'.tr(), check: secondCheck, url: PrivacyPage.routeName),
      const Spacer(),
      GestureDetector(
        onTap: () {
          if (!firstCheck.value || !secondCheck.value) {
            errorToast(message: 'agree_warning'.tr());
            return;
          }

          router.go(SetProfileIdPage.routeName, extra: language);
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
    ]));
  }

  Widget _buildCheckBox(
          {required String content, required ValueNotifier<bool> check, required String url}) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 10.w),
          SizedBox(
              width: 44.r,
              height: 44.r,
              child: FittedBox(
                  child: Checkbox(
                      value: check.value,
                      activeColor: const Color(0xFF7C4DFF),
                      onChanged: (value) {
                        check.value = value!;
                      }))),
          SizedBox(width: 2.w),
          Text(content,
              style:
                  const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500)),
          const Spacer(),
          GestureDetector(
              onTap: () {
                router.push(url);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF7C4DFF)),
                    borderRadius: BorderRadius.circular(2)),
                child: Text('agree_detail'.tr(),
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
              )),
          SizedBox(width: 20.w)
        ],
      );
}
