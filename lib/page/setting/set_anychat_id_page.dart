import 'package:anychat/common/toast.dart';
import 'package:anychat/model/user.dart';
import 'package:anychat/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../router.dart';

class SetAnychatIdPage extends HookConsumerWidget {
  static const String routeName = '/setting/id/set';

  const SetAnychatIdPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idController = useTextEditingController();

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leadingWidth: 48,
              leading: IconButton(
                  onPressed: () {
                    router.pop();
                  },
                  icon: const Icon(Icons.close, color: Color(0xFF3B3B3B), size: 24)),
              title: const Text('ID 등록',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3B3B3B))),
              actions: [
                GestureDetector(
                    onTap: () {
                      if (!isValidProfileId(idController.text.trim())) {
                        errorToast(message: '영문 + 숫자 조합 8자로 적어주세요');
                        return;
                      }

                      UserService().setProfileId(ref, idController.text.trim());
                    },
                    child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6),
                        child: const Text('확인',
                            style: TextStyle(
                                fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)))),
                SizedBox(width: 10.w)
              ],
              centerTitle: true),
          body: Padding(
              padding: EdgeInsets.only(left: 20.w, right: 44.w, top: 30),
              child: TextField(
                  controller: idController,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                      hintText: '애니챗 ID를 입력해주세요',
                      hintStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.black.withOpacity(0.5),
                          fontWeight: FontWeight.w500),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2)),
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1))))),
        ));
  }
}
