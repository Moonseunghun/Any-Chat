import 'package:anychat/common/toast.dart';
import 'package:anychat/page/main_layout.dart';
import 'package:anychat/page/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ConsentPage extends HookConsumerWidget {
  static const String routeName = '/consent';

  const ConsentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstCheck = useState<bool>(false);
    final secondCheck = useState<bool>(false);

    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 153.h),
      Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text('개인정보 동의',
              style: TextStyle(
                  fontSize: 20.r, fontWeight: FontWeight.bold, color: const Color(0xFF7C4DFF)))),
      SizedBox(height: 10.h),
      const Divider(color: Color(0xFFBABABA), thickness: 1),
      SizedBox(height: 70.h),
      _buildCheckBox(content: '개인정보처리방침 (필수)', check: firstCheck, url: ''),
      _buildCheckBox(content: '서비스 이용약관 동의 (필수)', check: secondCheck, url: ''),
      const Spacer(),
      InkWell(
        onTap: () {
          if (!firstCheck.value || !secondCheck.value) {
            errorToast(message: '필수 항목에 동의해주세요');
            return;
          }

          router.go(MainLayout.routeName);
        },
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF), borderRadius: BorderRadius.circular(10.r)),
            child: Center(
                child: Text('확인',
                    style: TextStyle(
                        fontSize: 20.r, color: Colors.white, fontWeight: FontWeight.w600)))),
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
              style: TextStyle(fontSize: 16.r, color: Colors.black, fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF7C4DFF)),
                borderRadius: BorderRadius.circular(2.r)),
            child: Text('내용보기',
                style: TextStyle(
                    fontSize: 10.r, color: const Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 20.w)
        ],
      );
}
