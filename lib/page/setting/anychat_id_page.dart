import 'package:anychat/page/setting/set_anychat_id_page.dart';
import 'package:anychat/state/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../router.dart';

class AnychatIdPage extends ConsumerWidget {
  static const String routeName = '/setting/id';

  const AnychatIdPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
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
          title: const Text('애니챗 ID',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3B3B3B))),
          centerTitle: true),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ID',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF3B3B3B))),
                  const SizedBox(height: 10),
                  Text(ref.watch(userProvider)!.userInfo.profileId ?? 'ID를 만들어주세요',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF3B3B3B)))
                ],
              ),
              const Spacer(),
              GestureDetector(
                  onTap: () {
                    router.push(SetAnychatIdPage.routeName);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFC74DFF)),
                    ),
                    child:
                        const Text('변경', style: TextStyle(fontSize: 12, color: Color(0xFFC74DFF))),
                  ))
            ],
          )),
    );
  }
}
