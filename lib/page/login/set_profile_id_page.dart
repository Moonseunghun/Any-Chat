import 'package:anychat/model/language.dart';
import 'package:anychat/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/toast.dart';
import '../../service/chat_service.dart';
import '../../service/login_service.dart';
import '../../service/user_service.dart';
import '../main_layout.dart';
import '../router.dart';

class SetProfileIdPage extends HookConsumerWidget {
  static const String routeName = '/set-profile-id';

  const SetProfileIdPage(this.language, {super.key});

  final Language language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idController = useTextEditingController();

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 153.h),
              Padding(
                  padding: EdgeInsets.only(left: 20.w),
                  child: const Text('프로필 ID 생성',
                      style: TextStyle(fontSize: 20, color: Color(0xFF7C4DFF)))),
              SizedBox(height: 10.h),
              const Divider(color: Color(0xFFBABABA), thickness: 1),
              SizedBox(height: 50.h),
              Padding(
                  padding: EdgeInsets.only(left: 20.w, right: 40.w),
                  child: TextField(
                      controller: idController,
                      decoration: InputDecoration(
                          hintText: '애니챗 ID',
                          hintStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.black.withOpacity(0.5),
                              fontWeight: FontWeight.w500),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                          border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 1))))),
              SizedBox(height: 80.h),
              Padding(
                  padding: EdgeInsets.only(left: 20.w, right: 104.w),
                  child: const Text(
                      '프로필 ID는 영문 + 숫자 조합 8자로 적어주세요.\n프로필 ID는 친구를 추가하거나 찾을때 사용하는 고유 식별자 입니다.',
                      style: TextStyle(fontSize: 12, color: Colors.black))),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (!isValidProfileId(idController.text.trim())) {
                    errorToast(message: '영문 + 숫자 조합 8자로 적어주세요');
                    return;
                  }

                  LoginService().register(ref, language, idController.text.trim()).then((_) async {
                    ChatService().connectSocket();
                    await UserService().getMe(ref).then((_) => router.go(MainLayout.routeName));
                  });
                },
                child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                        color: const Color(0xFF7C4DFF), borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                        child: Text('확인',
                            style: TextStyle(
                                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)))),
              ),
              SizedBox(height: 57.h)
            ])));
  }
}
