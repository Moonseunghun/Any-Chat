import 'package:anychat/page/router.dart';
import 'package:anychat/state/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../login/language_select_page.dart';
import 'anychat_id_page.dart';

class SettingPage extends HookConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 50,
                alignment: Alignment.centerLeft,
                child: const Text('설정',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3B3B3B)))),
            SizedBox(height: 20.h),
            _buildListWidget(
                title: '언어 설정',
                onTap: () {
                  router.push(LanguageSelectPage.routeName);
                }),
            _buildListWidget(
                title: '애니챗 ID',
                onTap: () {
                  router.push(AnychatIdPage.routeName);
                },
                optionText: ref.watch(userProvider)!.userInfo.profileId ?? 'ID를 만들어주세요'),
            _buildListWidget(title: '이용약관 보기', onTap: () {}),
            _buildListWidget(title: '개인정보처리방침 보기', onTap: () {}),
            _buildListWidget(title: '앱 버전 1.152.1', onTap: () {}),
            _buildListWidget(title: '오픈소스 라이선스 보기', onTap: () {}),
            _buildListWidget(title: '로그아웃', onTap: () {}),
          ],
        ));
  }

  _buildListWidget({required String title, required Function onTap, String? optionText}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          GestureDetector(
              onTap: () {
                onTap();
              },
              child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.only(left: 20.w, bottom: 10.h, top: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF3B3B3B))),
                      if (optionText != null)
                        Text(optionText,
                            style: const TextStyle(fontSize: 16, color: Color(0xFF3B3B3B))),
                    ],
                  ))),
          SizedBox(height: 10.h),
          const Divider(color: Color(0xFFE0E2E4), thickness: 1, height: 1)
        ],
      );
}
