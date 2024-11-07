import 'package:anychat/page/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'consent_page.dart';

class LanguageSelectPage extends StatelessWidget {
  static const String routeName = '/language';

  LanguageSelectPage({super.key});

  final List<String> languages = [
    "한국어",
    "English",
    "日本語",
    "bahasa Indonesia",
    "แบบไทย",
    "简体中文",
    "繁体中文",
    "español",
    "français",
    "Deutsch",
    "Tiếng Việt",
    "Русский язык",
    "اللغة العربية",
    "Tagalog",
    "Қазақ тілі",
    "Монгол хэл",
    "Bahasa Malaysia",
    "Português",
    "Türkçe",
    "o'zbek"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Text('언어 선택',
                  style:
                      TextStyle(fontSize: 20.r, fontWeight: FontWeight.w500, color: Colors.black))),
          SizedBox(height: 24.h),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
            children: languages
                .map((e) => ListTile(
                      onTap: () {
                        router.go(ConsentPage.routeName);
                      },
                      title: Text(e, style: TextStyle(fontSize: 16.r, color: Colors.black)),
                      contentPadding: EdgeInsets.only(left: 20.w),
                    ))
                .toList(),
          ))),
          SizedBox(height: 20.h),
        ],
      )),
    );
  }
}
