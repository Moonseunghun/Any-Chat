import 'dart:io';

import 'package:anychat/page/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

showImagePicker(
    {required WidgetRef ref,
    required BuildContext context,
    required void Function(File file) onSelected}) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
            height: 157,
            margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              children: [
                Expanded(
                    child: InkWell(
                        onTap: () async {
                          await ImagePicker()
                              .pickImage(source: ImageSource.gallery, imageQuality: 10)
                              .then((value) {
                            router.pop();
                            if (value != null) {
                              onSelected(File(value.path));
                            }
                          });
                        },
                        child: Container(
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: const Text(
                              '앨범에서 사진 선택',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF3B3B3B)),
                            )))),
                Divider(
                    thickness: 1,
                    height: 1,
                    color: const Color(0xFFE0E2E4),
                    indent: 20.w,
                    endIndent: 20.w),
                Expanded(
                    child: InkWell(
                        onTap: () {
                          router.pop();
                        },
                        child: Container(
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFFF0000)),
                            )))),
              ],
            ));
      });
}
