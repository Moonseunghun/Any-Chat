import 'package:anychat/common/toast.dart';
import 'package:anychat/model/language.dart';
import 'package:anychat/page/login/login_page.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/user_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../state/user_state.dart';

class LanguageSelectPage extends HookConsumerWidget {
  static const String routeName = '/language';

  const LanguageSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = useState<Language?>(ref.read(userProvider) == null
        ? null
        : Language.fromCode(ref.read(userProvider)!.userInfo.lang));

    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 36.h),
                  Text(
                    ref.read(userProvider) == null ? 'langset'.tr() : 'set_language'.tr(),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 38.h),
                  Text('langset_subj'.tr(),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF16C1AF)),
                      textAlign: TextAlign.center),
                  SizedBox(height: 70.h),
                  Expanded(
                      child: GridView.builder(
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: Language.values.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 1,
                              crossAxisSpacing: 6.w,
                              mainAxisSpacing: 4.h),
                          itemBuilder: (context, index) {
                            final key = Language.values.map((e) => e.name).elementAt(index);
                            final value = Language.values.where((e) => e.name == key).first.value;
                            return GestureDetector(
                                onTap: () {
                                  selectedLanguage.value =
                                      Language.values.where((e) => e.name == key).first;
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      children: [
                                        Container(
                                            width: 44,
                                            height: 44,
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Image.asset('assets/images/$key.png'),
                                                ),
                                                if (selectedLanguage.value?.name == key)
                                                  Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: const Color(0xFF7A4DFF)
                                                            .withOpacity(0.7)),
                                                    child: const Icon(Icons.check,
                                                        color: Colors.white, size: 24),
                                                  )
                                              ],
                                            )),
                                        const SizedBox(height: 5),
                                        Text(value,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                            textAlign: TextAlign.center),
                                      ],
                                    )));
                          })),
                  SizedBox(height: 20.h),
                  GestureDetector(
                      onTap: () {
                        if (selectedLanguage.value == null) {
                          errorToast(message: '언어를 선택해주세요');
                          return;
                        }

                        context.setLocale(selectedLanguage.value!.locale);

                        if (ref.read(userProvider) == null) {
                          router.go(LoginPage.routeName, extra: selectedLanguage.value);
                        } else {
                          UserService().setLanguage(ref, selectedLanguage.value!);
                        }
                      },
                      child: Container(
                        width: 240.w,
                        height: 54.h,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                            color: const Color(0xFF7A4DFF),
                            borderRadius: BorderRadius.circular(27)),
                        child: Text('langset_btn'.tr(),
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis)),
                      )),
                  SizedBox(height: 30.h),
                ],
              ))),
    );
  }
}
