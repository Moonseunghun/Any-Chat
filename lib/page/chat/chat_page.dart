import 'package:anychat/common/datetime_extension.dart';
import 'package:anychat/model/chat.dart';
import 'package:anychat/model/friend.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/chat_service.dart';
import 'package:anychat/state/friend_state.dart';
import 'package:anychat/state/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/message.dart';
import '../../service/database_service.dart';
import 'invite_friend_page.dart';

class ChatPage extends HookConsumerWidget {
  static const String routeName = '/chat';

  ChatPage(this.chatRoomHeader, {super.key});

  final Map<String, String> plusMenu = {
    'album': '앨범',
    'camera_circled': '카메라',
    'file': '파일',
    'contact': '연락처',
    'voice_call_circled': '음성통화',
    'face_call_circled': '영상통화'
  };

  final ScrollController _scrollController = ScrollController();
  final int participantsCount = 2;

  final ChatRoomHeader chatRoomHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isShow = useState<bool>(false);
    final showPlusMenu = useState<bool>(false);
    final plusMenuHeight = useState<double>(300.h);
    final focusNode = useFocusNode();
    final messageController = useTextEditingController();

    final messages = useState<List<Message>>([]);
    final cursor = useState<String?>(null);
    final scrollAtBottom = useState<bool>(true);

    useEffect(() {
      if (keyboardHeight > plusMenuHeight.value) {
        plusMenuHeight.value = keyboardHeight;
      }
      return () {};
    }, [keyboardHeight]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ChatService().joinRoom(chatRoomHeader.chatRoomId);

        DatabaseService.search('Message',
                where: 'chatRoomId = ?',
                whereArgs: [chatRoomHeader.chatRoomId],
                orderBy: 'seqId DESC')
            .then((value) {
          messages.value = value.map((e) => Message.fromJson(e)).toList();
        });

        ChatService()
            .getMessages(messages, chatRoomHeader.chatRoomId, cursor.value, isInit: true)
            .then((value) {
          cursor.value = value;
        });
        ChatService().onMessageRead(messages);
        ChatService().onMessageReceived(messages);

        _scrollController.addListener(() {
          if (_scrollController.position.pixels <= _scrollController.position.minScrollExtent) {
            scrollAtBottom.value = true;
          } else {
            scrollAtBottom.value = false;
          }
        });
      });

      return () {
        _scrollController.dispose();
        ChatService().leaveRoom();
      };
    }, []);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollAtBottom.value) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        }
      });

      return () {};
    }, [messages.value]);

    return Stack(children: [
      GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            isShow.value = false;
            showPlusMenu.value = false;
          },
          child: Container(
              color: Colors.white,
              child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        const Color(0xFF41CCAB).withOpacity(0.1),
                        const Color(0xFF41CCAB).withOpacity(0.45),
                        const Color(0xFF41CCAB).withOpacity(0.1)
                      ])),
                  child: Scaffold(
                      backgroundColor: Colors.transparent,
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
                          actions: [
                            GestureDetector(
                                onTap: () {},
                                child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                                    child:
                                        SvgPicture.asset('assets/images/search.svg', width: 24))),
                            GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  isShow.value = true;
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                                    child: SvgPicture.asset('assets/images/hamburger.svg',
                                        width: 24))),
                            SizedBox(width: 14.w)
                          ],
                          title: Text(chatRoomHeader.chatRoomName,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B3B3B))),
                          centerTitle: true),
                      body: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification is ScrollEndNotification &&
                                notification.metrics.extentAfter == 0) {
                              ChatService()
                                  .getMessages(messages, chatRoomHeader.chatRoomId, cursor.value)
                                  .then((value) {
                                cursor.value = value;
                              });
                            }

                            return false;
                          },
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: ListView(
                                reverse: true,
                                controller: _scrollController,
                                children: [
                                  SizedBox(height: 6.h),
                                  ...messages.value.map((message) {
                                    final bool isMyMessage =
                                        message.senderId == ref.read(userProvider)!.id;
                                    final String? beforeSenderId = messages.value
                                        .where((e) => e.seqId == message.seqId - 1)
                                        .firstOrNull
                                        ?.senderId;
                                    final String? afterSenderId = messages.value
                                        .where((e) => e.seqId == message.seqId + 1)
                                        .firstOrNull
                                        ?.senderId;
                                    final bool optional = (messages.value
                                            .where((e) => e.seqId == message.seqId + 1)
                                            .map((e) => e.createdAt.to24HourFormat())
                                            .firstOrNull) !=
                                        message.createdAt.to24HourFormat();

                                    return isMyMessage
                                        ? _myChat(
                                            message: message,
                                            optional: optional || afterSenderId == null
                                                ? true
                                                : afterSenderId != ref.read(userProvider)!.id,
                                            change: afterSenderId == null
                                                ? true
                                                : afterSenderId != ref.read(userProvider)!.id)
                                        : _opponentChat(
                                            message: message,
                                            optional: optional || afterSenderId == null
                                                ? true
                                                : afterSenderId == ref.read(userProvider)!.id,
                                            first: beforeSenderId == null
                                                ? true
                                                : beforeSenderId == ref.read(userProvider)!.id,
                                            change: afterSenderId == null
                                                ? true
                                                : afterSenderId == ref.read(userProvider)!.id);
                                  }),
                                  SizedBox(height: 6.h),
                                ],
                              ))),
                      bottomNavigationBar: Container(
                        padding: const EdgeInsets.only(top: 10),
                        color: Colors.white,
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(width: 8.w),
                                  GestureDetector(
                                      onTap: () {
                                        if (showPlusMenu.value) {
                                          FocusScope.of(context).requestFocus(focusNode);
                                        } else {
                                          FocusScope.of(context).unfocus();
                                        }

                                        showPlusMenu.value = !showPlusMenu.value;
                                      },
                                      child: Container(
                                          color: Colors.transparent,
                                          padding:
                                              EdgeInsets.symmetric(horizontal: 5.w, vertical: 6),
                                          child: AnimatedRotation(
                                              turns: showPlusMenu.value ? 0.125 : 0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFFF5F5F5),
                                                  ),
                                                  child: const Icon(Icons.add_rounded,
                                                      color: Color(0xFF7C4DFF), size: 24))))),
                                  SizedBox(width: 7.w),
                                  Expanded(
                                      child: Container(
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFF5F5F5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                          ),
                                          child: TextField(
                                            controller: messageController,
                                            focusNode: focusNode,
                                            keyboardType: TextInputType.multiline,
                                            minLines: 1,
                                            maxLines: keyboardHeight == 0 ? 1 : 6,
                                            onTap: () {
                                              FocusScope.of(context).requestFocus(focusNode);

                                              showPlusMenu.value = false;
                                            },
                                            decoration: InputDecoration(
                                                isDense: true,
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(
                                                    horizontal: 16.w, vertical: 10),
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
                                  SizedBox(width: 2.w),
                                  Container(
                                      color: Colors.transparent,
                                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 7),
                                      child: SvgPicture.asset('assets/images/emoticon.svg',
                                          height: 24)),
                                  GestureDetector(
                                      onTap: () {
                                        ChatService().sendMessage(messageController.text);
                                        messageController.clear();
                                      },
                                      child: Container(
                                          color: Colors.transparent,
                                          padding:
                                              EdgeInsets.symmetric(horizontal: 5.w, vertical: 6),
                                          child: Container(
                                              padding: const EdgeInsets.only(
                                                  left: 5, bottom: 5, top: 7, right: 7),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFFF5F5F5),
                                              ),
                                              child: SvgPicture.asset('assets/images/send.svg',
                                                  height: 14)))),
                                  SizedBox(width: 10.w)
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                height: !showPlusMenu.value
                                    ? focusNode.hasFocus
                                        ? plusMenuHeight.value
                                        : keyboardHeight
                                    : plusMenuHeight.value,
                                color: const Color(0xFFF5F5F5),
                                alignment: Alignment.center,
                                child: showPlusMenu.value
                                    ? Column(
                                        children: [
                                          SizedBox(height: 12.h),
                                          Expanded(
                                              child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              ...[0, 1, 2].map((index) => GestureDetector(
                                                  onTap: () {},
                                                  child: IntrinsicHeight(
                                                      child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      SvgPicture.asset(
                                                          'assets/images/${plusMenu.keys.elementAt(index)}.svg',
                                                          height: 60),
                                                      const SizedBox(height: 8),
                                                      Text(plusMenu.values.elementAt(index),
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w500,
                                                              color: Color(0xFF3B3B3B))),
                                                    ],
                                                  ))))
                                            ],
                                          )),
                                          Expanded(
                                              child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              ...[3, 4, 5].map((index) => GestureDetector(
                                                  onTap: () {},
                                                  child: IntrinsicHeight(
                                                      child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      SvgPicture.asset(
                                                          'assets/images/${plusMenu.keys.elementAt(index)}.svg',
                                                          height: 60),
                                                      const SizedBox(height: 10),
                                                      Text(plusMenu.values.elementAt(index),
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w500,
                                                              color: Color(0xFF3B3B3B))),
                                                    ],
                                                  ))))
                                            ],
                                          )),
                                          SizedBox(height: 50.h)
                                        ],
                                      )
                                    : null,
                              )
                            ],
                          ),
                        ),
                      ))))),
      ..._showLeftBar(ref, isShow)
    ]);
  }

  Widget _opponentChat(
      {bool first = false, bool optional = false, required Message message, bool change = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
                onTap: () {},
                child: Container(
                    width: 38,
                    height: 38,
                    margin: const EdgeInsets.only(top: 4),
                    child: first
                        ? ClipOval(
                            child:
                                Image.asset('assets/images/default_profile.png', fit: BoxFit.cover),
                          )
                        : null)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                    constraints: BoxConstraints(
                      maxWidth: 243.w,
                    ),
                    margin: EdgeInsets.only(left: 7.w, top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(message.content,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF3B3B3B)),
                        maxLines: 3)),
                SizedBox(width: 4.w),
                if (optional)
                  Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (participantsCount - message.readCount > 0)
                          Text((participantsCount - message.readCount).toString(),
                              style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.7))),
                        Text(message.createdAt.to24HourFormat(),
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF3B3B3B),
                                fontWeight: FontWeight.w500)),
                      ])
              ],
            )
          ],
        ),
        if (change) const SizedBox(height: 14)
      ],
    );
  }

  Widget _myChat({required Message message, bool optional = false, bool change = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (optional)
              Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (participantsCount - message.readCount > 0)
                      Text((participantsCount - message.readCount).toString(),
                          style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.7))),
                    Text(message.createdAt.to24HourFormat(),
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF3B3B3B), fontWeight: FontWeight.w500)),
                  ]),
            SizedBox(width: 4.w),
            Container(
                constraints: BoxConstraints(
                  maxWidth: 243.w,
                ),
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: ShapeDecoration(
                  color: const Color(0xFFECE5FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(message.content,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF3B3B3B)),
                    maxLines: 3))
          ],
        ),
        if (change) const SizedBox(height: 14)
      ],
    );
  }

  List<Widget> _showLeftBar(WidgetRef ref, ValueNotifier<bool> isShow) => [
        if (isShow.value)
          GestureDetector(
              onTap: () {
                isShow.value = false;
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.6),
              )),
        AnimatedPositioned(
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 200),
            right: isShow.value ? 0 : -286.w,
            bottom: 0,
            child: Container(
                width: 286.w,
                height: 792.h,
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 20.w),
                        alignment: Alignment.centerLeft,
                        child: const DefaultTextStyle(
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF3B3B3B),
                                fontWeight: FontWeight.bold),
                            child: Text('대화상대'))),
                    SizedBox(height: 6.h),
                    Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                      children: [
                        GestureDetector(
                            onTap: () {
                              isShow.value = false;
                              router.push(InviteFriendPage.routeName);
                            },
                            child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle, color: Color(0xFFF5F5F5)),
                                      child: const Icon(Icons.add, color: Color(0xFF7C4DFF)),
                                    ),
                                    SizedBox(width: 11.w),
                                    const DefaultTextStyle(
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF7C4DFF),
                                            fontWeight: FontWeight.w500),
                                        child: Text('대화상대추가'))
                                  ],
                                ))),
                        SizedBox(height: 4.h),
                        Divider(
                          height: 1,
                          color: const Color(0xFFE0E2E4),
                          thickness: 1,
                          indent: 20.w,
                          endIndent: 26.w,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 20.w, right: 14.w, top: 10.h),
                            child: Column(
                              children: [
                                _profileWidget(ref),
                                _profileWidget(ref, friend: ref.watch(friendsProvider).firstOrNull)
                              ],
                            )),
                      ],
                    ))),
                    Container(
                        height: 52,
                        color: const Color(0xFFF5F5F5),
                        padding: EdgeInsets.only(left: 10.w),
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                            onTap: () {},
                            child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10),
                                child: SvgPicture.asset('assets/images/out.svg', width: 24))))
                  ],
                )))
      ];

  Widget _profileWidget(WidgetRef ref, {Friend? friend}) => GestureDetector(
      onTap: () {},
      child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 7.h),
          child: Row(
            children: [
              Image.asset('assets/images/default_profile.png', width: 44),
              SizedBox(width: 11.w),
              if (friend == null)
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DefaultTextStyle(
                        style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF3B3B3B),
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis),
                        child: Text(ref.watch(userProvider)!.name)),
                    const DefaultTextStyle(
                        style: TextStyle(fontSize: 12, color: Color(0xFFE0E2E4)), child: Text('나'))
                  ],
                )),
              if (friend != null) ...[
                Expanded(
                    child: DefaultTextStyle(
                        style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF3B3B3B),
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis),
                        child: Text(friend.nickname))),
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF7C4DFF), width: 1),
                      borderRadius: BorderRadius.circular(20)),
                  child: const DefaultTextStyle(
                      style: TextStyle(fontSize: 12, color: Color(0xFF7C4DFF)),
                      child: Text('내보내기')),
                )
              ]
            ],
          )));
}
