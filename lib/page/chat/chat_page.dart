import 'package:anychat/page/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatPage extends HookConsumerWidget {
  static const String routeName = '/chat';

  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
            color: Colors.white,
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, const Color(0xFF7C4DFF).withOpacity(0.2)])),
                child: Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leadingWidth: 48,
                        leading: IconButton(
                            onPressed: () {
                              router.pop();
                            },
                            icon: const Icon(Icons.close, color: Color(0xFF3B3B3B), size: 24)),
                        actions: [
                          GestureDetector(
                              onTap: () {},
                              child: Container(
                                  color: Colors.transparent,
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                                  child: SvgPicture.asset('assets/images/search.svg', width: 24))),
                          GestureDetector(
                              onTap: () {},
                              child: Container(
                                  color: Colors.transparent,
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                                  child:
                                      SvgPicture.asset('assets/images/hamburger.svg', width: 24))),
                          SizedBox(width: 14.w)
                        ],
                        title: const Text('홍길동',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B3B3B))),
                        centerTitle: true),
                    body: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: ListView(
                          children: [_opponentChat(), _opponentChat(), _myChat(), _opponentChat()],
                        )),
                    bottomNavigationBar: AnimatedContainer(
                        duration: const Duration(milliseconds: 40),
                        margin: EdgeInsets.only(bottom: keyboardHeight),
                        child: Container(
                            padding: EdgeInsets.only(
                                bottom: keyboardHeight > 150 ? 10 : 30,
                                top: 10,
                                left: 6.w,
                                right: 10.w),
                            color: Colors.white,
                            child: Row(
                              children: [
                                Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFF5F5F5),
                                    ),
                                    child: const Icon(Icons.add_rounded,
                                        color: Color(0xFF7C4DFF), size: 24)),
                                SizedBox(width: 12.w),
                                Expanded(
                                    child: Container(
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFF5F5F5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                        ),
                                        child: TextField(
                                          keyboardType: TextInputType.multiline,
                                          minLines: 1,
                                          maxLines: keyboardHeight == 0 ? 1 : 4,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 16.w, vertical: 4),
                                              hintText: '메세지를 입력해주세요',
                                              hintStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFFAEAEAE))),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                        ))),
                                SizedBox(width: 5.w),
                                Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 6),
                                    child:
                                        SvgPicture.asset('assets/images/emoticon.svg', width: 22)),
                                Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 6),
                                    child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 5, bottom: 5, top: 7, right: 7),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        child:
                                            SvgPicture.asset('assets/images/send.svg', width: 14)))
                              ],
                            )))))));
  }

  Widget _opponentChat() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(top: 6),
            child: ClipOval(
              child: Image.asset('assets/images/default_profile.png', fit: BoxFit.cover),
            )),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                constraints: BoxConstraints(
                  maxWidth: 243.w,
                ),
                margin: EdgeInsets.only(left: 7.w, top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: ShapeDecoration(
                  color: const Color(0xFF7C4DFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('동해물과 백두산이 마르고 닳도록 하느님이 보우하사 우리 나라만세 무궁화 삼천리 화려강산',
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white),
                    maxLines: 3)),
            SizedBox(width: 4.w),
            Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('원문보기',
                      style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.7))),
                  const SizedBox(height: 2),
                  const Text('09:12',
                      style: TextStyle(
                          fontSize: 10, color: Color(0xFF3B3B3B), fontWeight: FontWeight.w500)),
                ])
          ],
        )
      ],
    );
  }

  Widget _myChat() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('09:12',
            style: TextStyle(fontSize: 10, color: Color(0xFF3B3B3B), fontWeight: FontWeight.w500)),
        SizedBox(width: 4.w),
        Container(
            constraints: BoxConstraints(
              maxWidth: 243.w,
            ),
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: ShapeDecoration(
              color: const Color(0xFFF5F5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('동해물과 백두산이 마르고 닳도록 하느님이 보우하사 우리 나라만세 무궁화 삼천리 화려강산',
                style:
                    TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF3B3B3B)),
                maxLines: 3))
      ],
    );
  }
}
