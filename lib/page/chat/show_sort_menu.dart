import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/overlay.dart';

showSortMenu(BuildContext context) {
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
            top: 111.h,
            right: 6.w,
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
                    _menuItem('최신 메세지 순', () {}),
                    _menuItem('안 읽은 메세지 순', () {}),
                    _menuItem('즐겨찾기 순', () {}, showBorder: false),
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
