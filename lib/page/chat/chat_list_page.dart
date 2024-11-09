import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatListPage extends HookConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
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
      )
    ]);
  }
}
