import 'package:anychat/model/friend.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/state/friend_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InviteFriendPage extends HookConsumerWidget {
  static const String routeName = '/chat/invite';

  const InviteFriendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFriends = useState<List<Friend>>([]);

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onPanStart: (details) {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            body: SafeArea(
                child: Column(
          children: [
            SizedBox(
                width: 393.w,
                height: 50,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        GestureDetector(
                            onTap: () {},
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10),
                                child: SvgPicture.asset('assets/images/qr_code.svg', width: 24))),
                        SizedBox(width: 4.w),
                        GestureDetector(
                            onTap: () {},
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10),
                                child: const Text('확인',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)))),
                        SizedBox(width: 10.w)
                      ],
                    ),
                    Positioned(
                        left: 10.w,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                                onTap: () {
                                  router.pop();
                                },
                                child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10),
                                    color: Colors.transparent,
                                    child: const Icon(Icons.close,
                                        color: Color(0xFF3B3B3B), size: 24))))),
                    const Positioned(
                        child: Align(
                      alignment: Alignment.center,
                      child: Text('대화상대초대',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    )),
                  ],
                )),
            SizedBox(
                width: 393.w,
                height: 50,
                child: TextField(
                  decoration: InputDecoration(
                      hintText: '검색',
                      hintStyle: TextStyle(
                          color: const Color(0xFF3B3B3B).withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                      contentPadding: EdgeInsets.symmetric(horizontal: 19.w),
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1)),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1))),
                )),
            const SizedBox(height: 18),
            Expanded(
                child: SingleChildScrollView(
                    child: Column(
              children: ref
                  .watch(friendsProvider)
                  .map((friend) => _profileWidget(selectedFriends, friend))
                  .toList(),
            )))
          ],
        ))));
  }

  Widget _profileWidget(ValueNotifier<List<Friend>> selectedFriends, Friend friend) => InkWell(
      onTap: () {
        if (selectedFriends.value.contains(friend)) {
          selectedFriends.value =
              selectedFriends.value.where((element) => element != friend).toList();
        } else {
          selectedFriends.value = [...selectedFriends.value, friend];
        }
      },
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: EdgeInsets.only(left: 19.w, right: 21.w),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE0E2E4), width: 1),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                  width: 44,
                  height: 44,
                  child: ClipOval(child: Image.asset('assets/images/default_profile.png'))),
              SizedBox(width: 11.w),
              Expanded(
                  child: Text(friend.nickname,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF3B3B3B)),
                      overflow: TextOverflow.ellipsis)),
              Container(
                width: 24 + 40.w,
                alignment: Alignment.center,
                child: selectedFriends.value.contains(friend)
                    ? SvgPicture.asset('assets/images/selected.svg', width: 24)
                    : const SizedBox(),
              )
            ],
          )));
}
