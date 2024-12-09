import 'package:anychat/main.dart';
import 'package:anychat/page/chat/chat_list_page.dart';
import 'package:anychat/page/home/home_page.dart';
import 'package:anychat/page/setting/setting_page.dart';
import 'package:anychat/service/chat_service.dart';
import 'package:anychat/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/chat.dart';
import '../model/friend.dart';
import '../service/database_service.dart';
import '../service/friend_service.dart';
import '../state/chat_state.dart';
import '../state/friend_state.dart';
import '../state/util_state.dart';

String? friendsCursor;

class MainLayout extends HookConsumerWidget {
  static const String routeName = '/';

  MainLayout({super.key});

  final List<Widget> pages = [const HomePage(), const ChatListPage(), const SettingPage()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UserService().getMe(ref);
        DatabaseService.search('Friends', where: 'isPinned = ?', whereArgs: [0])
            .then((value) async {
          List<Friend> friends = [];

          for (final friend in value) {
            friends.add(await Friend.fromMap(friend));
          }

          ref.read(friendsProvider.notifier).setFriends(friends);
        });

        DatabaseService.search('Friends', where: 'isPinned = ?', whereArgs: [1])
            .then((value) async {
          List<Friend> friends = [];

          for (final friend in value) {
            friends.add(await Friend.fromMap(friend));
          }

          ref.read(friendCountProvider.notifier).state = prefs.getInt('totalCount') ?? 0;
          ref.read(friendsProvider.notifier).setFriends(friends);
        });

        DatabaseService.search('ChatRoomInfo').then((savedInfo) async {
          List<ChatRoomInfo> chatRoomInfos = [];
          for (final Map<String, dynamic> chatRoomInfo in savedInfo) {
            chatRoomInfos.add(await ChatRoomInfo.fromJson(ref, chatRoomInfo));
          }

          ref.read(chatRoomInfoProvider.notifier).set(chatRoomInfos);
        });

        FriendService().getFriends(ref, isInit: true).then((value) {
          friendsCursor = value;
        });
        FriendService().getPinned(ref);
        ChatService().getRooms(ref).then((_) {
          prefs.setBool('isInitialSync', false);
        });
      });

      return () {};
    }, []);

    return Scaffold(
      body: SafeArea(child: pages[ref.watch(indexProvider)]),
      bottomSheet: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(2, -4),
                  blurRadius: 20,
                  spreadRadius: 0),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 4.w),
              navigationBarIcon(
                  ref: ref, index: 0, name: '홈', iconUrl: 'assets/images/home', iconSize: 24.r),
              navigationBarIcon(
                  ref: ref, index: 1, name: '채팅', iconUrl: 'assets/images/chat', iconSize: 24.r),
              Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  child: Image.asset('assets/images/anychat.png', height: 61.r)),
              navigationBarIcon(
                  ref: ref,
                  index: 2,
                  name: '설정',
                  iconUrl: 'assets/images/setting',
                  iconSize: 25.6.r),
              SizedBox(width: 4.w),
            ],
          )),
    );
  }

  Widget navigationBarIcon(
      {required WidgetRef ref,
      required int index,
      required String name,
      required String iconUrl,
      required iconSize}) {
    final bool isSelected = ref.watch(indexProvider) == index;
    return InkWell(
        onTap: () {
          ref.read(indexProvider.notifier).state = index;
        },
        child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: SizedBox(
                width: 40.w,
                height: 47.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 32.r,
                        height: 32.r,
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                            '${iconUrl}_${isSelected ? "selected" : "unselected"}.svg',
                            width: iconSize)),
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 10.r,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? const Color(0xFF7C4DFF) : const Color(0xFF3B3B3B)),
                    )
                  ],
                ))));
  }
}
