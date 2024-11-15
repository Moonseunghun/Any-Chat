import 'package:anychat/model/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetProfileIdPage extends HookConsumerWidget {
  static const String routeName = '/set-profile-id';

  const SetProfileIdPage(this.language, {super.key});

  final Language language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 153.h),
      Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: const Text('프로필 ID 생성',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF)))),
      SizedBox(height: 10.h),
      const Divider(color: Color(0xFFBABABA), thickness: 1)
    ]));
  }
}
