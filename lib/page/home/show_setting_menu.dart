import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/overlay.dart';

showSettingMenu(BuildContext context) {
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
              color: Colors.transparent,
            )),
        Positioned(
            top: 97.h,
            right: 36.w,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0x40000000),
                          offset: Offset(2.w, 2.h),
                          blurRadius: 10.r,
                          spreadRadius: 0)
                    ]),
                child: Column(
                  children: [
                    _menuItem('숨김 친구 관리', () {}),
                    _menuItem('차단 친구 관리', () {}),
                    _menuItem('친구 목록 편집', () {}, showBorder: false),
                  ],
                )))
      ]));
}

Widget _menuItem(String title, Function onTap, {bool showBorder = true}) {
  return GestureDetector(
      onTap: () {
        OverlayComponent.hideOverlay();
        onTap();
      },
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 9.h),
          decoration: BoxDecoration(
              color: Colors.transparent,
              border: showBorder
                  ? const Border(bottom: BorderSide(color: Color(0xFFE0E2E4), width: 1))
                  : null),
          child: DefaultTextStyle(
              style: TextStyle(
                  fontSize: 16.r, color: const Color(0xFF3B3B3B), fontWeight: FontWeight.w500),
              child: Text(title))));
}
