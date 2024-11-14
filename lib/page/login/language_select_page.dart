import 'package:anychat/common/toast.dart';
import 'package:anychat/model/language.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'consent_page.dart';

class LanguageSelectPage extends HookConsumerWidget {
  static const String routeName = '/language';

  const LanguageSelectPage({this.isCreate = false, super.key});

  final bool isCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = useState<Language?>(null);

    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 36.h),
                  Text(isCreate ? '사용언어 설정' : '언어 설정',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                  SizedBox(height: 38.h),
                  const Text('ANYCHAT 서비스 이용을 위해 언어 설정이 필요합니다.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF16C1AF))),
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
                                                fontWeight: FontWeight.w500)),
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

                        if (isCreate) {
                          router.go(ConsentPage.routeName, extra: selectedLanguage.value);
                        } else {
                          UserService().setLanguage(ref, selectedLanguage.value!);
                        }
                      },
                      child: Container(
                        width: 208.w,
                        height: 54.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: const Color(0xFF7A4DFF),
                            borderRadius: BorderRadius.circular(27)),
                        child: const Text('사용언어 설정하기',
                            style: TextStyle(
                                fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
                      )),
                  SizedBox(height: 30.h),
                ],
              ))),
    );
  }
}
