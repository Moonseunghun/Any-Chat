import 'package:anychat/common/toast.dart';
import 'package:anychat/page/main_layout.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/page/user/show_image_picker.dart';
import 'package:anychat/page/user/show_profile_more.dart';
import 'package:anychat/service/chat_service.dart';
import 'package:anychat/service/friend_service.dart';
import 'package:anychat/service/user_service.dart';
import 'package:anychat/state/friend_state.dart';
import 'package:anychat/state/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/friend.dart';
import '../chat/chat_page.dart';

class ProfilePage extends HookConsumerWidget {
  static const String routeName = '/profile';

  const ProfilePage({this.friend, super.key});

  final Friend? friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = useState<bool>(false);
    final user = ref.watch(userProvider)!;
    final Friend? friend =
        [...ref.watch(friendsProvider), ...ref.watch(hiddenFriendsProvider)].contains(this.friend)
            ? this.friend
            : null;
    final nameClicked = useState<bool>(false);
    final messageClicked = useState<bool>(false);

    final nameFocus = useFocusNode();
    final messageFocus = useFocusNode();

    final nameController = useTextEditingController();
    final messageController = useTextEditingController();

    return GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 15) {
            router.pop();
          }
        },
        child: Container(
            decoration: BoxDecoration(
              image: (friend == null
                      ? user.userInfo.backgroundImg == null
                          ? null
                          : DecorationImage(
                              fit: BoxFit.cover, image: FileImage(user.userInfo.backgroundImg!))
                      : friend.friend.backgroundImg == null
                          ? null
                          : DecorationImage(
                              fit: BoxFit.cover, image: FileImage(friend.friend.backgroundImg!))) ??
                  const DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/default_profile_background.png')),
            ),
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.black.withOpacity(0.6),
                body: Stack(children: [
                  SafeArea(
                      child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          SizedBox(width: 10.w),
                          GestureDetector(
                              onTap: () {
                                if (isEditMode.value) {
                                  isEditMode.value = false;
                                } else {
                                  router.pop();
                                }
                              },
                              child: Container(
                                  color: Colors.transparent,
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                  child: const Icon(Icons.close, color: Colors.white, size: 24))),
                          const Spacer(),
                          if (friend != null &&
                              !ref
                                  .watch(hiddenFriendsProvider)
                                  .map((e) => e.id)
                                  .contains(this.friend!.id))
                            GestureDetector(
                                onTap: () {
                                  if (ref.read(pinnedFriendsProvider).contains(friend)) {
                                    FriendService().unpinFriend(ref, friend.id);
                                  } else {
                                    FriendService().pinFriend(ref, friend.id);
                                  }
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                                    child: SvgPicture.asset(
                                      'assets/images/star.svg',
                                      width: 24,
                                      colorFilter: ref.read(pinnedFriendsProvider).contains(friend)
                                          ? const ColorFilter.mode(Colors.yellow, BlendMode.srcIn)
                                          : null,
                                    ))),
                          if (friend != null)
                            GestureDetector(
                                onTap: () {
                                  showProfileMore(context, ref, friend, null);
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                                    child: SvgPicture.asset('assets/images/more.svg', width: 24))),
                          SizedBox(width: 10.w)
                        ],
                      ),
                      if (isEditMode.value)
                        Row(
                          children: [
                            SizedBox(width: 10.w),
                            GestureDetector(
                                onTap: () {
                                  showImagePicker(
                                      ref: ref,
                                      context: context,
                                      onSelected: (file) {
                                        UserService().updateProfile(ref, backgroundImage: file);
                                      });
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                    child: SvgPicture.asset('assets/images/camera.svg', width: 24)))
                          ],
                        ),
                      const Spacer(),
                      GestureDetector(
                          onTap: () {
                            if (isEditMode.value) {
                              showImagePicker(
                                  ref: ref,
                                  context: context,
                                  onSelected: (file) {
                                    UserService().updateProfile(ref, profileImage: file);
                                  });
                            }
                          },
                          child: Stack(
                            children: [
                              ClipOval(
                                child: (friend == null
                                        ? user.userInfo.profileImg == null
                                            ? null
                                            : Image.file(user.userInfo.profileImg!,
                                                width: 140, height: 140, fit: BoxFit.fill)
                                        : friend.friend.profileImg == null
                                            ? null
                                            : Image.file(friend.friend.profileImg!,
                                                width: 140, height: 140, fit: BoxFit.fill)) ??
                                    Image.asset('assets/images/default_profile.png',
                                        width: 140, height: 140),
                              ),
                              if (isEditMode.value)
                                Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: SvgPicture.asset('assets/images/camera.svg', width: 24))
                            ],
                          )),
                      SizedBox(height: 16.h),
                      GestureDetector(
                          onTap: () {
                            if (isEditMode.value) {
                              nameController.text = user.name;
                              nameClicked.value = true;
                              FocusScope.of(context).requestFocus(nameFocus);
                            }
                          },
                          child: Container(
                              padding: EdgeInsets.only(bottom: 6.h, top: 4.h),
                              margin: EdgeInsets.only(left: 30.w, right: 22.w),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: isEditMode.value
                                        ? const Color(0xFFE0E2E4)
                                        : Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Spacer(),
                                  SizedBox(
                                    width: 48.w,
                                    height: 18,
                                  ),
                                  Text(
                                    friend?.nickname ?? user.name,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFF5F5F5),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Container(
                                      width: 38.w,
                                      height: 18,
                                      margin: EdgeInsets.only(right: 10.w),
                                      alignment: Alignment.centerRight,
                                      child: isEditMode.value
                                          ? SvgPicture.asset('assets/images/pen.svg', height: 18)
                                          : null)
                                ],
                              ))),
                      SizedBox(height: 12.h),
                      GestureDetector(
                          onTap: () {
                            if (isEditMode.value) {
                              messageController.text = user.userInfo.stateMessage ?? '';
                              messageClicked.value = true;
                              FocusScope.of(context).requestFocus(messageFocus);
                            }
                          },
                          child: Container(
                              padding: EdgeInsets.only(bottom: 6.h, top: 4.h),
                              margin: EdgeInsets.only(left: 30.w, right: 22.w),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: isEditMode.value
                                        ? const Color(0xFFE0E2E4)
                                        : Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 48.w),
                                  const Spacer(),
                                  Text(
                                    friend == null
                                        ? user.userInfo.stateMessage ?? '여기에 상태메세지를 입력해주세요'
                                        : friend.friend.stateMessage ?? '',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFF5F5F5)),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Spacer(),
                                  Container(
                                      width: 38.w,
                                      height: 18,
                                      margin: EdgeInsets.only(right: 10.w),
                                      alignment: Alignment.centerRight,
                                      child: isEditMode.value
                                          ? SvgPicture.asset('assets/images/pen.svg', height: 18)
                                          : null)
                                ],
                              ))),
                      SizedBox(height: 28.h),
                      Divider(
                          color: isEditMode.value ? Colors.transparent : const Color(0xFFE0E2E4),
                          thickness: 1),
                      SizedBox(height: 10.h),
                      SizedBox(
                          height: 74 + 32.h,
                          child: isEditMode.value
                              ? null
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(width: 20.w),
                                    if (friend == null)
                                      Column(
                                        children: [
                                          GestureDetector(
                                              onTap: () {
                                                isEditMode.value = true;
                                              },
                                              child: Container(
                                                  color: Colors.transparent,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.w, vertical: 10.h),
                                                  child: SvgPicture.asset(
                                                      'assets/images/pen_circle.svg',
                                                      width: 60))),
                                          const Spacer(),
                                          const Text(
                                            '프로필편집',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Color(0xFFF5F5F5)),
                                          )
                                        ],
                                      ),
                                    if (friend != null) ...[
                                      Column(
                                        children: [
                                          GestureDetector(
                                              onTap: () {
                                                ChatService()
                                                    .makeRoom(ref, [friend.friend.userId]).then(
                                                        (chatRoomHeader) {
                                                  router.go(MainLayout.routeName);
                                                  router.push(ChatPage.routeName,
                                                      extra: chatRoomHeader);
                                                });
                                              },
                                              child: Container(
                                                  color: Colors.transparent,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.w, vertical: 10.h),
                                                  child: SvgPicture.asset('assets/images/chat.svg',
                                                      width: 60))),
                                          const Spacer(),
                                          const Text(
                                            '채팅하기',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Color(0xFFF5F5F5)),
                                          ),
                                          SizedBox(height: 9.h)
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                              onTap: () {},
                                              child: Container(
                                                  color: Colors.transparent,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.w, vertical: 10.h),
                                                  child: SvgPicture.asset(
                                                      'assets/images/voice_call.svg',
                                                      width: 60))),
                                          const Spacer(),
                                          const Text(
                                            '음성채팅',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Color(0xFFF5F5F5)),
                                          ),
                                          SizedBox(height: 9.h)
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                              onTap: () {},
                                              child: Container(
                                                  color: Colors.transparent,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.w, vertical: 10.h),
                                                  child: SvgPicture.asset(
                                                      'assets/images/face_call.svg',
                                                      width: 60))),
                                          const Spacer(),
                                          const Text(
                                            '영상채팅',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Color(0xFFF5F5F5)),
                                          ),
                                          SizedBox(height: 9.h)
                                        ],
                                      )
                                    ],
                                    SizedBox(width: 20.w)
                                  ],
                                )),
                      SizedBox(height: 60.h)
                    ],
                  )),
                  if (nameClicked.value || messageClicked.value) ...[
                    GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black.withOpacity(0.7))),
                    Positioned(
                        left: 10.w,
                        top: 10.h,
                        child: SafeArea(
                            child: GestureDetector(
                                onTap: () {
                                  nameClicked.value = false;
                                  messageClicked.value = false;
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                    child:
                                        const Icon(Icons.close, color: Colors.white, size: 24))))),
                    Container(
                        width: 393.w,
                        height: 600.h,
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 8.w),
                                Expanded(
                                    child: TextField(
                                  controller:
                                      nameClicked.value ? nameController : messageController,
                                  focusNode: nameClicked.value ? nameFocus : messageFocus,
                                  textAlign: TextAlign.center,
                                  onSubmitted: (value) {
                                    if (nameClicked.value) {
                                      if (value.trim().isEmpty || value.trim() == user.name) {
                                        nameClicked.value = false;
                                      } else if (value.trim().length > 12) {
                                        errorToast(message: '닉네임은 12자 이내로 입력해주세요');
                                      } else {
                                        UserService()
                                            .updateProfile(ref, name: value.trim())
                                            .then((_) {
                                          nameClicked.value = false;
                                        });
                                      }
                                    } else {
                                      if (value.trim().isEmpty ||
                                          value.trim() == user.userInfo.stateMessage) {
                                        messageClicked.value = false;
                                      } else if (value.trim().length > 60) {
                                        errorToast(message: '상태메세지는 60자 이내로 입력해주세요');
                                      } else {
                                        UserService()
                                            .updateProfile(ref, stateMessage: value.trim())
                                            .then((_) {
                                          messageClicked.value = false;
                                        });
                                      }
                                    }
                                  },
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                      hintText: nameClicked.value ? '닉네임' : '상태메세지',
                                      hintStyle: const TextStyle(
                                          color: Color(0xFFDBDBDB),
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal),
                                      border: InputBorder.none),
                                )),
                                SizedBox(width: 4.w),
                                GestureDetector(
                                    onTap: () {
                                      if (nameClicked.value) {
                                        nameController.text = '';
                                      } else {
                                        messageController.text = '';
                                      }
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5),
                                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                                    ))
                              ],
                            ),
                            const Divider(color: Colors.white, thickness: 1, height: 1),
                          ],
                        ))
                  ]
                ]))));
  }
}
