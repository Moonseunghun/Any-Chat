import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

errorToast({String? message}) {
  toastification.show(
    style: ToastificationStyle.simple,
    closeOnClick: true,
    dragToClose: false,
    alignment: const Alignment(0, -1),
    borderRadius: BorderRadius.circular(10.r),
    borderSide: BorderSide.none,
    closeButtonShowType: CloseButtonShowType.none,
    backgroundColor: Colors.black.withOpacity(0.7),
    title: Text(message ?? '알 수 없는 오류가 발생했습니다',
        style: TextStyle(color: Colors.white, fontSize: 16.r, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
        maxLines: 40),
    autoCloseDuration: const Duration(milliseconds: 2000),
  );
}
