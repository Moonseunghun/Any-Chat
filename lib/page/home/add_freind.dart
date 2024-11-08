import 'dart:ui';

import 'package:anychat/common/overlay.dart';
import 'package:anychat/state/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../router.dart';
import 'add_friend_by_id_page.dart';

addFriendPopup(BuildContext context, WidgetRef ref) {
  final user = ref.watch(userProvider)!;

  OverlayComponent.showOverlay(
      context: context,
      child: Stack(
        children: [
          GestureDetector(
              onTap: () {
                OverlayComponent.hideOverlay();
              },
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.w, sigmaY: 3.h), // 블러 강도 조절
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withOpacity(0.6),
                  ))),
          Container(
              width: double.infinity,
              height: 234.h,
              color: Colors.white,
              child: SafeArea(
                  child: Column(
                children: [
                  SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 10.w,
                              child: GestureDetector(
                                  onTap: () {
                                    OverlayComponent.hideOverlay();
                                  },
                                  child: Container(
                                      color: Colors.transparent,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                      child: Icon(Icons.close,
                                          color: const Color(0xFF3B3B3B), size: 24.r)))),
                          Positioned.fill(
                              child: Align(
                                  alignment: Alignment.center,
                                  child: DefaultTextStyle(
                                      style: TextStyle(
                                          fontSize: 16.r,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF3B3B3B)),
                                      child: const Text('친구 추가'))))
                        ],
                      )),
                  const Expanded(flex: 14, child: SizedBox()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: () {},
                          child: Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset('assets/images/qr_code.svg', width: 48.w),
                                  SizedBox(height: 7.h),
                                  DefaultTextStyle(
                                      style: TextStyle(
                                          fontSize: 12.r,
                                          color: const Color(0xFF3B3B3B),
                                          fontWeight: FontWeight.w500),
                                      child: const Text('QR 코드'))
                                ],
                              ))),
                      SizedBox(width: 25.w),
                      GestureDetector(
                          onTap: () {
                            OverlayComponent.hideOverlay();
                            router.push(AddFriendByIdPage.routeName);
                          },
                          child: Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset('assets/images/face_id.svg', width: 48.w),
                                  SizedBox(height: 7.h),
                                  DefaultTextStyle(
                                      style: TextStyle(
                                          fontSize: 12.r,
                                          color: const Color(0xFF3B3B3B),
                                          fontWeight: FontWeight.w500),
                                      child: const Text('ID'))
                                ],
                              )))
                    ],
                  ),
                  const Expanded(flex: 10, child: SizedBox())
                ],
              ))),
          Positioned.fill(
              top: 294.h,
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Container(
                          width: 196.w,
                          height: 220.h,
                          decoration: BoxDecoration(
                              color: const Color(0xFF7C4DFF),
                              borderRadius: BorderRadius.circular(20.r)),
                          child: Column(
                            children: [
                              const Expanded(flex: 25, child: SizedBox()),
                              DefaultTextStyle(
                                  style: TextStyle(
                                      fontSize: 16.r,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                  child: Text(user.name)),
                              const Expanded(flex: 10, child: SizedBox()),
                              Container(
                                  padding: EdgeInsets.all(5.r),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(11.r)),
                                  child: user.userInfo.profileId == null
                                      ? Container(
                                          width: 130.r,
                                          height: 130.r,
                                          alignment: Alignment.center,
                                          child: DefaultTextStyle(
                                              style: TextStyle(
                                                  fontSize: 12.r,
                                                  color: const Color(0xFF3B3B3B),
                                                  fontWeight: FontWeight.w500),
                                              child: const Text('Profile ID 없음')))
                                      : QrImageView(
                                          data: user.userInfo.profileId ?? 'no',
                                          size: 130.r,
                                        )),
                              const Expanded(flex: 26, child: SizedBox()),
                            ],
                          )),
                      SizedBox(height: 12.h),
                      SvgPicture.asset('assets/images/share.svg', width: 36.w)
                    ],
                  )))
        ],
      ));
}
