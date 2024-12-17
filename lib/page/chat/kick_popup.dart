import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/overlay.dart';
import '../../model/chat.dart';
import '../../service/chat_service.dart';

kickPopup(BuildContext context, WidgetRef ref, ChatUserInfo kickedUser) {
  OverlayComponent.showOverlay(
      context: context,
      child: Stack(children: [
        GestureDetector(
          onTap: () {
            OverlayComponent.hideOverlay();
          },
          child: Container(color: Colors.black.withOpacity(0.6)),
        ),
        Center(
            child: Container(
                width: 274.w,
                height: 177.h,
                padding: EdgeInsets.only(top: 30.h, bottom: 20.h),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(14.r), color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("'${kickedUser.name}'님을\n내보내시겠습니까?",
                        style: TextStyle(
                            color: const Color(0xFF4A4A4A),
                            fontWeight: FontWeight.w500,
                            fontSize: 16.r,
                            height: 1.6),
                        textAlign: TextAlign.center),
                    const Spacer(),
                    GestureDetector(
                        onTap: () {
                          ChatService().kickUser(ref, kickedUser.id);
                          OverlayComponent.hideOverlay();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFF7A4DFF),
                              borderRadius: BorderRadius.circular(6.r)),
                          padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 40.w),
                          child: Text('btn_confirm'.tr(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.r,
                                  fontWeight: FontWeight.w500)),
                        ))
                  ],
                )))
      ]));
}
