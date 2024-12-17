import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../router.dart';

class PrivacyPage extends StatelessWidget {
  static const String routeName = '/privacy';

  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 48,
            leading: IconButton(
                onPressed: () {
                  router.pop();
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24)),
            title: Text('priv_policy'.tr(),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            centerTitle: false),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 36.h),
            child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(children: [
                  Text('priv_policy_desc'.tr(),
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF999999), fontWeight: FontWeight.w500))
                ]))));
  }
}
