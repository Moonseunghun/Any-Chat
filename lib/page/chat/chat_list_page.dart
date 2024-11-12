import 'package:anychat/page/chat/chat_page.dart';
import 'package:anychat/page/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatListPage extends HookConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      SizedBox(height: 10.h),
      Row(
        children: [
          SizedBox(width: 20.w),
          Text('채팅',
              style: TextStyle(
                  fontSize: 20.r, fontWeight: FontWeight.bold, color: const Color(0xFF3B3B3B))),
          const Spacer(),
          InkWell(onTap: () {}, child: SvgPicture.asset('assets/images/search.svg', width: 24.r)),
          SizedBox(width: 7.w),
          InkWell(
              onTap: () {}, child: SvgPicture.asset('assets/images/chat_plus.svg', width: 24.r)),
          SizedBox(width: 7.w),
          InkWell(onTap: () {}, child: SvgPicture.asset('assets/images/settings.svg', width: 24.r)),
          SizedBox(width: 20.w),
        ],
      ),
      Expanded(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 16.h),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref),
                  _chatHeader(ref)
                ],
              ))))
    ]);
  }

  Widget _chatHeader(WidgetRef ref) {
    return InkWell(
        onTap: () {
          router.push(ChatPage.routeName);
        },
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(width: 1, color: Color(0xFFE0E2E4)))),
            child: Row(
              children: [
                SizedBox(
                    width: 44,
                    height: 44,
                    child: ClipOval(
                        child:
                            Image.asset('assets/images/default_profile.png', fit: BoxFit.cover))),
                SizedBox(width: 10.w),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('시원스쿨랩',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF3B3B3B))),
                    SizedBox(height: 5.h),
                    const Text('[시원스쿨] 홍길동님 수강중인 시원스쿨 토픽 수강기간이 30일 남았습니다. 동해물과 백두산이 마르고 닳도록...',
                        style: TextStyle(fontSize: 10, color: Color(0xFF3B3B3B)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                )),
                SizedBox(
                    width: 40,
                    child: Row(
                      children: [
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('12:24',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF3B3B3B),
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF56971),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: const Text('20',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFFF5F5F5),
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        )
                      ],
                    )),
              ],
            )));
  }
}
