import 'dart:ui';

import 'package:anychat/common/config.dart';
import 'package:anychat/model/language.dart';
import 'package:anychat/page/login/privacy_page.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/user_service.dart';
import 'package:anychat/state/user_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../login/language_select_page.dart';
import '../login/terms_page.dart';
import 'anychat_id_page.dart';
import 'delete_popup.dart';

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
                child: Text('btn_set'.tr(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3B3B3B)))),
            SizedBox(height: 20.h),
            _buildListWidget(
                title: 'set_language'.tr(),
                onTap: () {
                  router.push(LanguageSelectPage.routeName);
                }),
            _buildListWidget(
                title: 'profile_id'.tr(),
                onTap: () {
                  router.push(AnychatIdPage.routeName);
                },
                optionText: ref.watch(userProvider)?.userInfo.profileId ?? 'ID를 만들어주세요'),
            _buildListWidget(
                title: 'set_show_terms'.tr(),
                onTap: () {
                  router.push(TermsPage.routeName);
                }),
            _buildListWidget(
                title: 'set_show_privacy'.tr(),
                onTap: () {
                  router.push(PrivacyPage.routeName);
                }),
            _buildListWidget(
                title: 'set_appversion'.tr(namedArgs: {'app_version': HttpConfig.appVersion}),
                onTap: () {}),
            // _buildListWidget(title: 'set_license'.tr(), onTap: () {}),
            _buildListWidget(
                title: 'set_logout'.tr(),
                onTap: () {
                  context.setLocale((Language.values
                              .where((e) =>
                                  e.name.toUpperCase() ==
                                  PlatformDispatcher.instance.locale.countryCode)
                              .firstOrNull ??
                          Language.us)
                      .locale);
                  UserService().logOut(ref);
                }),
            _buildListWidget(
                title: 'del_account'.tr(),
                onTap: () {
                  deletePopup(context, ref);
                }),
          ],
        ));
  }

  _buildListWidget({required String title, required Function onTap, String? optionText}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
              onTap: () {
                onTap();
              },
              child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.only(left: 20.w, bottom: 20.h, top: 20.h),
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
          const Divider(color: Color(0xFFE0E2E4), thickness: 1, height: 1)
        ],
      );
}
