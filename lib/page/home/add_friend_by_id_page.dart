import 'package:anychat/common/toast.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/friend_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AddFriendByIdPage extends HookConsumerWidget {
  static const String routeName = '/friend/add/id';

  const AddFriendByIdPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idController = useTextEditingController();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          body: SafeArea(
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
                            router.pop();
                          },
                          child: Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                              child:
                                  Icon(Icons.close, color: const Color(0xFF3B3B3B), size: 24.r)))),
                  Positioned.fill(
                      child: Align(
                          alignment: Alignment.center,
                          child: DefaultTextStyle(
                              style: TextStyle(
                                  fontSize: 16.r, fontWeight: FontWeight.bold, color: Colors.black),
                              child: const Text('ID로 추가'))))
                ],
              )),
          SizedBox(height: 30.h),
          Padding(
              padding: EdgeInsets.only(left: 20.w, right: 44.w),
              child: TextField(
                controller: idController,
                style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.w500, color: Colors.black),
                decoration: InputDecoration(
                    hintText: '친구 ID',
                    hintStyle: TextStyle(
                        fontSize: 20.r,
                        color: Colors.black.withOpacity(0.5),
                        fontWeight: FontWeight.w500),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
                    border:
                        const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black))),
              )),
          const Spacer(),
          GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();

                if (idController.text.trim().isEmpty) {
                  errorToast(message: '친구 ID를 입력해주세요');
                  return;
                }

                FriendService().addFriend(ref, idController.text.trim()).then((_) {
                  idController.clear();
                });
              },
              child: Container(
                width: double.infinity,
                height: 50.h,
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: const Color(0xFFC74DFF),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFC74DFF).withOpacity(0.5),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                          spreadRadius: 0)
                    ]),
                child: Text('추가',
                    style: TextStyle(
                        fontSize: 16.r, color: Colors.white, fontWeight: FontWeight.bold)),
              )),
          SizedBox(height: 28.h),
        ],
      ))),
    );
  }
}
