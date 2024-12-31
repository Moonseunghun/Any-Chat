import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/overlay.dart';
import '../../service/user_service.dart';
import '../../state/user_state.dart';

deletePopup(BuildContext context, WidgetRef ref) {
  final user = ref.watch(userProvider)!;

  OverlayComponent.showOverlay(
      context: context,
      child: Stack(children: [
        GestureDetector(
            onTap: () {
              OverlayComponent.hideOverlay();
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.3),
            )),
        Center(
            child: Container(
                width: 350.w,
                height: 249.h,
                decoration:
                    BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  children: [
                    const Expanded(child: SizedBox(height: 30)),
                    Text(
                        'popup_del_acc_title'
                            .tr(namedArgs: {'profile_id': user.userInfo.profileId!}),
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.r,
                            overflow: TextOverflow.ellipsis)),
                    const Expanded(child: SizedBox(height: 12)),
                    Text('popup_del_acc_desc01'.tr(),
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12.r,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis),
                        textAlign: TextAlign.center),
                    const Expanded(child: SizedBox(height: 12)),
                    Text('popup_del_acc_desc02'.tr(),
                        style: TextStyle(
                            color: Colors.red, fontSize: 14.r, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center),
                    const Expanded(child: SizedBox(height: 22)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: () {
                              OverlayComponent.hideOverlay();
                              UserService().deleteAccount(ref, context);
                            },
                            child: Container(
                                width: 114.w,
                                height: 38.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFFF0004),
                                    borderRadius: BorderRadius.circular(6.r)),
                                child: Text('btn_confirm'.tr(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 15,
                                        overflow: TextOverflow.ellipsis)))),
                        SizedBox(width: 9.w),
                        GestureDetector(
                            onTap: () {
                              OverlayComponent.hideOverlay();
                            },
                            child: Container(
                                width: 114.w,
                                height: 38.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFAFAFAF),
                                    borderRadius: BorderRadius.circular(6.r)),
                                child: Text('cancel'.tr(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 15,
                                        overflow: TextOverflow.ellipsis))))
                      ],
                    ),
                    const Expanded(child: SizedBox(height: 12)),
                  ],
                )))
      ]));
}
