import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingPage extends HookConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Text('설정',
                style: TextStyle(
                    fontSize: 20.r, fontWeight: FontWeight.bold, color: const Color(0xFF3B3B3B))),
            SizedBox(height: 31.h),
            _buildListWidget(title: '언어 설정', onTap: () {}),
            _buildListWidget(title: '이용약관 보기', onTap: () {}),
            _buildListWidget(title: '개인정보처리방침 보기', onTap: () {}),
            _buildListWidget(title: '앱 버전 1.0.0', onTap: () {}),
            _buildListWidget(title: '오픈소스 라이선스 보기', onTap: () {}),
            _buildListWidget(title: '로그아웃', onTap: () {}),
          ],
        ));
  }

  _buildListWidget({required String title, required Function onTap}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          GestureDetector(
              onTap: () {
                onTap();
              },
              child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.only(left: 20.w, bottom: 10.h, top: 10.h),
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 16.r,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3B3B3B))))),
          SizedBox(height: 8.h),
          const Divider(color: Color(0xFFE0E2E4), thickness: 1)
        ],
      );
}
