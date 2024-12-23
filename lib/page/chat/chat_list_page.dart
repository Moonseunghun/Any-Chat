import 'package:anychat/common/datetime_extension.dart';
import 'package:anychat/model/chat.dart';
import 'package:anychat/model/message.dart';
import 'package:anychat/page/chat/chat_page.dart';
import 'package:anychat/page/chat/show_sort_menu.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/state/chat_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'invite_friend_page.dart';

class ChatListPage extends HookConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newChat = useState<bool>(false);
    final searchController = useTextEditingController();
    final isSearching = useState<bool>(false);

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(children: [
          Column(children: [
            Container(
                height: 50,
                alignment: Alignment.center,
                child: Row(
                  children: [
                    SizedBox(width: 20.w),
                    Text('btn_chat'.tr(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3B3B3B))),
                    const Spacer(),
                    GestureDetector(
                        onTap: () {
                          isSearching.value = true;
                        },
                        child: SvgPicture.asset('assets/images/search.svg', width: 24)),
                    SizedBox(width: 7.w),
                    GestureDetector(
                        onTap: () {
                          newChat.value = true;
                        },
                        child: SvgPicture.asset('assets/images/chat_plus.svg', width: 24)),
                    SizedBox(width: 7.w),
                    GestureDetector(
                        onTap: () {
                          showSortMenu(context, ref);
                        },
                        child: SvgPicture.asset('assets/images/settings.svg', width: 24)),
                    SizedBox(width: 20.w),
                  ],
                )),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 16.h),
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        ...ref.watch(chatRoomInfoProvider).map((chatRoomInfo) {
                          return _chatHeader(ref, chatRoomInfo, newChat);
                        }),
                        SizedBox(height: 100.h),
                      ],
                    ))))
          ]),
          if (newChat.value) _newChat(newChat),
          if (isSearching.value) _searchWidget(ref, isSearching, searchController)
        ]));
  }

  Widget _chatHeader(WidgetRef ref, ChatRoomInfo chatRoomInfo, ValueNotifier<bool> newChat) {
    return InkWell(
        onTap: () {
          newChat.value = false;
          router.push(ChatPage.routeName,
              extra: ChatRoomHeader(chatRoomId: chatRoomInfo.id, chatRoomName: chatRoomInfo.name));
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
                        child: chatRoomInfo.profileImg != null
                            ? Image.file(chatRoomInfo.profileImg!,
                                width: 140, height: 140, fit: BoxFit.fill)
                            : Image.asset('assets/images/default_profile.png', fit: BoxFit.cover))),
                SizedBox(width: 10.w),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chatRoomInfo.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF3B3B3B))),
                    SizedBox(height: 5.h),
                    Text(
                        chatRoomInfo.messageType == MessageType.file
                            ? '파일'
                            : chatRoomInfo.messageType == MessageType.image
                                ? '이미지'
                                : chatRoomInfo.messageType == MessageType.video
                                    ? '비디오'
                                    : chatRoomInfo.lastMessage,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF3B3B3B)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                )),
                SizedBox(
                    width: 70,
                    child: Row(
                      children: [
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(chatRoomInfo.lastMessageUpdatedAt.toCustomDateFormat(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF3B3B3B),
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            if (chatRoomInfo.unreadCount > 0)
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF56971),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                    chatRoomInfo.unreadCount > 999
                                        ? '999+'
                                        : chatRoomInfo.unreadCount.toString(),
                                    style: const TextStyle(
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

  Widget _newChat(ValueNotifier<bool> newChat) => Container(
      height: 164,
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
              width: 393.w,
              height: 50,
              child: Stack(
                children: [
                  InkWell(
                      onTap: () {
                        newChat.value = false;
                      },
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 13),
                        child: const Icon(Icons.close, color: Color(0xFF3B3B3B), size: 24),
                      )),
                  Positioned.fill(
                      child: Align(
                    alignment: Alignment.center,
                    child: Text('new_chat_title'.tr(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3B3B3B))),
                  ))
                ],
              )),
          const Expanded(flex: 23, child: SizedBox()),
          GestureDetector(
              onTap: () {
                newChat.value = false;
                router.push(InviteFriendPage.routeName);
              },
              child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10),
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/images/chat_unselected.svg', width: 36),
                      const SizedBox(height: 5),
                      Text('btn_normal_chat'.tr(),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF3B3B3B), fontWeight: FontWeight.w500))
                    ],
                  ))),
          const Expanded(flex: 25, child: SizedBox()),
        ],
      ));

  Widget _searchWidget(
          WidgetRef ref, ValueNotifier<bool> isSearching, TextEditingController searchController) =>
      Container(
          color: Colors.white,
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              SvgPicture.asset('assets/images/search.svg', width: 24),
              SizedBox(width: 28.w),
              Expanded(
                  child: TextField(
                controller: searchController,
                style: const TextStyle(
                    fontSize: 20, color: Color(0xFF3B3B3B), fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'search_title'.tr(),
                  hintStyle: TextStyle(
                      fontSize: 20,
                      color: const Color(0xFF3B3B3B).withOpacity(0.5),
                      fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                ),
                onEditingComplete: () {
                  isSearching.value = false;
                  ref.read(chatRoomInfoProvider.notifier).search(searchController.text.trim());
                },
              ))
            ],
          ));
}
