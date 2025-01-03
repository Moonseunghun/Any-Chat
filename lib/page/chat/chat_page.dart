import 'dart:async';
import 'dart:io';

import 'package:anychat/common/datetime_extension.dart';
import 'package:anychat/main.dart';
import 'package:anychat/model/chat.dart';
import 'package:anychat/page/chat/camera_page.dart';
import 'package:anychat/page/chat/kick_popup.dart';
import 'package:anychat/page/image_close_page.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/chat_service.dart';
import 'package:anychat/service/user_service.dart';
import 'package:anychat/state/chat_state.dart';
import 'package:anychat/state/user_state.dart';
import 'package:chewie/chewie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../model/auth.dart';
import '../../model/message.dart';
import '../../service/database_service.dart';
import '../user/chat_profile_page.dart';
import '../video_player_page.dart';
import 'invite_friend_page.dart';

bool _internetConnected = true;

class ChatPage extends HookConsumerWidget {
  static const String routeName = '/chat';

  ChatPage(this.chatRoomHeader, {super.key});

  final Map<String, String> plusMenu = {
    'album': '앨범',
    'camera_circled': 'cam_title'.tr(),
    'file': '파일',
    'contact': 'contact_title'.tr(),
    'voice_call_circled': '음성통화',
    'face_call_circled': '영상통화'
  };

  final ScrollController _scrollController = ScrollController();

  final ChatRoomHeader chatRoomHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomViewPadding = MediaQuery.of(context).viewPadding.bottom;
    final appLifecycleState = useAppLifecycleState();
    final init = useState<bool>(false);

    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final owner = useState<ChatUserInfo?>(null);
    final isShow = useState<bool>(false);
    final showPlusMenu = useState<bool>(false);
    final plusMenuHeight = useState<double>(300.h);
    final focusNode = useFocusNode();
    final messageController = useTextEditingController();

    final messages = useState<List<Message>>([]);
    final showOriginMessages = useState<List<int>>([]);
    final loadingMessages = useState<List<LoadingMessage>>([]);
    final cursor = useState<String?>(null);
    final scrollAtBottom = useState<bool>(true);
    final participants = useState<List<ChatUserInfo>>([]);
    final selectedImage = useState<File?>(null);
    final selectedVideo = useState<File?>(null);
    final chewieController = useState<ChewieController?>(null);
    final videoPlayerController = useState<VideoPlayerController?>(null);

    useEffect(() {
      if (keyboardHeight > plusMenuHeight.value) {
        plusMenuHeight.value = keyboardHeight;
      }
      return () {};
    }, [keyboardHeight]);

    useEffect(() {
      late final StreamSubscription<List<ConnectivityResult>> subscription;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        subscription =
            Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
          if (result.contains(ConnectivityResult.mobile) ||
              result.contains(ConnectivityResult.wifi)) {
            if (!_internetConnected && auth != null) {
              if (!socketConnected) {
                UserService.refreshAccessToken().then((_) {
                  ChatService().connectSocket(ref, callback: () {
                    ChatService().joinRoom(ref, participants, chatRoomHeader.chatRoomId, messages,
                        loadingMessages, cursor);
                    ChatService().onMessageRead(ref, messages);
                    ChatService().onMessageReceived(
                        ref, chatRoomHeader.chatRoomId, messages, participants, loadingMessages);
                    ChatService().onKickUser(ref);
                    ChatService().onUpdatedMessages(ref, messages);
                  });
                });
              }

              ChatService().getParticipants(chatRoomHeader.chatRoomId, participants).then((_) {
                ChatService().getRoomInfo(chatRoomHeader.chatRoomId).then((value) {
                  owner.value = participants.value.where((e) => e.id == value).firstOrNull;
                });
              });

              _internetConnected = true;
            }
          } else {
            _internetConnected = false;
          }
        });

        DatabaseService.search('Message',
                where: 'chatRoomId = ?',
                whereArgs: [chatRoomHeader.chatRoomId],
                orderBy: 'seqId DESC')
            .then((value) async {
          final List<Message> tmp = [];

          for (final message in value) {
            tmp.add(await Message.fromJson(ref, participants.value, message));
          }

          messages.value = tmp;
        });

        DatabaseService.search('ChatUserInfo',
            where: 'chatRoomId = ?', whereArgs: [chatRoomHeader.chatRoomId]).then((value) async {
          final List<ChatUserInfo> chatUserInfos = [];

          for (final participant in value) {
            chatUserInfos.add(await ChatUserInfo.fromJson(participant));
          }

          participants.value = chatUserInfos;
        });

        _scrollController.addListener(() {
          if (_scrollController.position.pixels <= _scrollController.position.minScrollExtent) {
            scrollAtBottom.value = true;
          } else {
            scrollAtBottom.value = false;
          }
        });
      });

      return () {
        subscription.cancel();
        _scrollController.dispose();
        ChatService().outRoom(ref);
      };
    }, []);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (appLifecycleState == AppLifecycleState.resumed) {
          if (_internetConnected && auth != null) {
            if (socketConnected && !init.value) {
              ChatService().getParticipants(chatRoomHeader.chatRoomId, participants).then((_) {
                ChatService().getRoomInfo(chatRoomHeader.chatRoomId).then((value) {
                  owner.value = participants.value.where((e) => e.id == value).firstOrNull;
                });
              });

              ChatService().joinRoom(
                  ref, participants, chatRoomHeader.chatRoomId, messages, loadingMessages, cursor);
              ChatService().onMessageRead(ref, messages);
              ChatService().onMessageReceived(
                  ref, chatRoomHeader.chatRoomId, messages, participants, loadingMessages);
              ChatService().onKickUser(ref);
              ChatService().onUpdatedMessages(ref, messages);
            } else if (!socketConnected) {
              UserService.refreshAccessToken().then((_) {
                ChatService().getParticipants(chatRoomHeader.chatRoomId, participants).then((_) {
                  ChatService().getRoomInfo(chatRoomHeader.chatRoomId).then((value) {
                    owner.value = participants.value.where((e) => e.id == value).firstOrNull;
                  });
                });

                ChatService().connectSocket(ref, callback: () {
                  ChatService().joinRoom(ref, participants, chatRoomHeader.chatRoomId, messages,
                      loadingMessages, cursor);
                  ChatService().onMessageRead(ref, messages);
                  ChatService().onMessageReceived(
                      ref, chatRoomHeader.chatRoomId, messages, participants, loadingMessages);
                  ChatService().onKickUser(ref);
                  ChatService().onUpdatedMessages(ref, messages);
                });
              });
            }
          }

          init.value = true;
        }
      });

      return () {};
    }, [appLifecycleState]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatRoomInfoProvider.notifier).allRead(chatRoomHeader.chatRoomId);

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
            selectedImage.value = null;
            selectedVideo.value = null;
            chewieController.value?.dispose();
            chewieController.value = null;
            videoPlayerController.value?.dispose();
            videoPlayerController.value = null;
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
                                  .getMessages(ref, participants, messages,
                                      chatRoomHeader.chatRoomId, cursor.value)
                                  .then((value) {
                                cursor.value = value;
                              });
                            }

                            return false;
                          },
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: ListView(
                                shrinkWrap: true,
                                reverse: true,
                                controller: _scrollController,
                                children: [
                                  SizedBox(height: 6.h),
                                  ...loadingMessages.value
                                      .map((e) => _myChat(ref: ref, loadingMessage: e)),
                                  ...messages.value.map((message) {
                                    final bool isMyMessage =
                                        message.senderId == ref.read(userProvider)!.id;
                                    final Message? beforeMessage = messages.value
                                        .where((e) => e.seqId == message.seqId - 1)
                                        .firstOrNull;
                                    final String? afterSenderId = messages.value
                                        .where((e) => e.seqId == message.seqId + 1)
                                        .firstOrNull
                                        ?.senderId;
                                    final bool optional = (messages.value
                                            .where((e) => e.seqId == message.seqId + 1)
                                            .map((e) => e.createdAt.to24HourFormat())
                                            .firstOrNull) !=
                                        message.createdAt.to24HourFormat();

                                    return Column(
                                      children: [
                                        if (!compareDates(
                                            beforeMessage?.createdAt, message.createdAt))
                                          dateMessage(message.createdAt),
                                        if (message.messageType == MessageType.text ||
                                            message.messageType == MessageType.image ||
                                            message.messageType == MessageType.video ||
                                            message.messageType == MessageType.file)
                                          isMyMessage
                                              ? _myChat(
                                                  ref: ref,
                                                  message: message,
                                                  optional: optional || afterSenderId == null
                                                      ? true
                                                      : afterSenderId != ref.read(userProvider)!.id,
                                                  change: afterSenderId == null
                                                      ? true
                                                      : afterSenderId != ref.read(userProvider)!.id,
                                                )
                                              : _opponentChat(
                                                  ref: ref,
                                                  message: message,
                                                  showOriginMessages: showOriginMessages,
                                                  optional: optional || afterSenderId == null
                                                      ? true
                                                      : afterSenderId == ref.read(userProvider)!.id,
                                                  first: beforeMessage?.senderId == null
                                                      ? true
                                                      : beforeMessage?.messageType ==
                                                              MessageType.invite ||
                                                          beforeMessage?.messageType ==
                                                              MessageType.kick ||
                                                          beforeMessage?.messageType ==
                                                              MessageType.leave ||
                                                          beforeMessage?.senderId ==
                                                              ref.read(userProvider)!.id,
                                                  change: afterSenderId == null
                                                      ? true
                                                      : afterSenderId == ref.read(userProvider)!.id,
                                                  participants: participants),
                                        if (message.messageType == MessageType.invite ||
                                            message.messageType == MessageType.kick ||
                                            message.messageType == MessageType.leave)
                                          infoMessage(
                                              message.showMessage(participants: participants.value))
                                      ],
                                    );
                                  }),
                                  SizedBox(height: 6.h),
                                ],
                              ))),
                      bottomNavigationBar: Container(
                        padding: EdgeInsets.only(
                            top: 10,
                            bottom: bottomViewPadding > 0 &&
                                    (!showPlusMenu.value && !focusNode.hasFocus)
                                ? 16
                                : 0),
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
                                        if (selectedImage.value == null &&
                                            selectedVideo.value == null) {
                                          if (showPlusMenu.value) {
                                            FocusScope.of(context).requestFocus(focusNode);
                                          } else {
                                            FocusScope.of(context).unfocus();
                                          }

                                          showPlusMenu.value = !showPlusMenu.value;
                                        } else {
                                          selectedImage.value = null;
                                          selectedVideo.value = null;
                                          chewieController.value?.dispose();
                                          chewieController.value = null;
                                          videoPlayerController.value?.dispose();
                                          videoPlayerController.value = null;
                                        }
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
                                  if (selectedImage.value == null &&
                                      selectedVideo.value == null) ...[
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
                                            height: 24))
                                  ],
                                  if (selectedImage.value != null || selectedVideo.value != null)
                                    const Spacer(),
                                  GestureDetector(
                                      onTap: () async {
                                        if (messageController.text.trim().isNotEmpty) {
                                          loadingMessages.value = [
                                            LoadingMessage(
                                                senderId: ref.read(userProvider)!.id,
                                                status: MessageStatus.loading,
                                                messageType: MessageType.text,
                                                content: messageController.text,
                                                createdAt: DateTime.now()),
                                            ...loadingMessages.value
                                          ];
                                          ChatService().sendMessage(ref, messageController.text);
                                          messageController.clear();
                                        } else if (selectedImage.value != null) {
                                          final uuid = const Uuid().v4();

                                          loadingMessages.value = [
                                            LoadingMessage(
                                                senderId: ref.read(userProvider)!.id,
                                                status: MessageStatus.loading,
                                                messageType: MessageType.image,
                                                content: selectedImage.value,
                                                uuid: uuid,
                                                createdAt: DateTime.now()),
                                            ...loadingMessages.value
                                          ];
                                          ChatService().sendFile(ref, selectedImage.value!, uuid);
                                          FocusScope.of(context).unfocus();
                                          selectedImage.value = null;
                                        } else if (selectedVideo.value != null) {
                                          final uuid = const Uuid().v4();

                                          final thumbnailProvider = FutureProvider((ref) async {
                                            return await VideoThumbnail.thumbnailData(
                                              video: selectedVideo.value!.path,
                                              imageFormat: ImageFormat.JPEG,
                                              quality: 25,
                                            );
                                          });

                                          loadingMessages.value = [
                                            LoadingMessage(
                                                senderId: ref.read(userProvider)!.id,
                                                status: MessageStatus.loading,
                                                messageType: MessageType.video,
                                                content: {
                                                  'file': selectedVideo.value,
                                                  'thumbnail': thumbnailProvider
                                                },
                                                uuid: uuid,
                                                createdAt: DateTime.now()),
                                            ...loadingMessages.value
                                          ];
                                          ChatService().sendFile(ref, selectedVideo.value!, uuid);
                                          if (!context.mounted) return;
                                          FocusScope.of(context).unfocus();
                                          selectedVideo.value = null;
                                          chewieController.value?.dispose();
                                          chewieController.value = null;
                                          videoPlayerController.value?.dispose();
                                          videoPlayerController.value = null;
                                        }
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
                                    ? selectedImage.value != null
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 40.w,
                                              vertical: 24,
                                            ),
                                            child: Image.file(selectedImage.value!,
                                                fit: BoxFit.contain))
                                        : chewieController.value != null
                                            ? Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 24.w, vertical: 12),
                                                child: Chewie(controller: chewieController.value!))
                                            : Column(
                                                children: [
                                                  SizedBox(height: 12.h),
                                                  Expanded(
                                                      child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceEvenly,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      ...[0, 1, 2].map((index) => GestureDetector(
                                                          onTap: () async {
                                                            if (index == 0) {
                                                              await _loadMedia(
                                                                  selectedImage,
                                                                  selectedVideo,
                                                                  chewieController,
                                                                  videoPlayerController,
                                                                  messageController);
                                                            } else if (index == 1) {
                                                              await _loadMediaByCamera(
                                                                  selectedImage,
                                                                  selectedVideo,
                                                                  chewieController,
                                                                  videoPlayerController,
                                                                  messageController);
                                                            } else if (index == 2) {
                                                              _pickFile().then((file) {
                                                                if (file != null) {
                                                                  final uuid = const Uuid().v4();
                                                                  loadingMessages.value = [
                                                                    LoadingMessage(
                                                                        senderId: ref
                                                                            .read(userProvider)!
                                                                            .id,
                                                                        status:
                                                                            MessageStatus.loading,
                                                                        messageType:
                                                                            MessageType.file,
                                                                        content: file,
                                                                        uuid: uuid,
                                                                        createdAt: DateTime.now()),
                                                                    ...loadingMessages.value
                                                                  ];
                                                                  ChatService()
                                                                      .sendFile(ref, file, uuid);
                                                                  if (!context.mounted) return;
                                                                  FocusScope.of(context).unfocus();
                                                                  showPlusMenu.value = false;
                                                                }
                                                              });
                                                            } else if (index == 3) {}
                                                          },
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
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceEvenly,
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
      ..._showLeftBar(ref, context, isShow, participants, owner.value)
    ]);
  }

  Widget _opponentChat(
      {required WidgetRef ref,
      bool first = false,
      bool optional = false,
      required ValueNotifier<List<int>> showOriginMessages,
      required Message message,
      bool change = false,
      required ValueNotifier<List<ChatUserInfo>> participants}) {
    final ChatUserInfo? participant =
        participants.value.where((e) => e.id == message.senderId).firstOrNull;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
                onTap: () async {
                  if (participant != null) {
                    if (participant.id == ref.read(userProvider)!.id) {
                      router.push(ChatProfilePage.routeName, extra: participant);
                    } else {
                      final ChatUserInfo chatUserInfo =
                          await UserService().getChatUserInfo(ref, participant.id);

                      router.push(ChatProfilePage.routeName, extra: chatUserInfo);
                    }
                  }
                },
                child: Container(
                    width: 38,
                    height: 38,
                    margin: const EdgeInsets.only(top: 4),
                    child: first
                        ? ClipOval(
                            child: participant?.profileImg == null
                                ? Image.asset('assets/images/default_profile.png',
                                    fit: BoxFit.cover)
                                : Image.file(participant!.profileImg!, fit: BoxFit.fill))
                        : null)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (first)
                  Padding(
                      padding: EdgeInsets.only(left: 7.w),
                      child: Text(participant?.name ?? '알 수 없음',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3B3B3B)))),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                        constraints: BoxConstraints(
                          maxWidth: 243.w,
                        ),
                        margin: EdgeInsets.only(left: 7.w, top: 6),
                        padding: message.messageType == MessageType.text
                            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                            : EdgeInsets.zero,
                        decoration: ShapeDecoration(
                          color:
                              message.messageType == MessageType.text ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: message.messageType == MessageType.text ||
                                    message.messageType == MessageType.file
                                ? BorderRadius.circular(16)
                                : BorderRadius.zero,
                          ),
                        ),
                        child: message.messageType == MessageType.text
                            ? Text(
                                message.showMessage(
                                    showOrigin: showOriginMessages.value.contains(message.seqId)),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Color(0xFF3B3B3B)))
                            : message.messageType == MessageType.image
                                ? GestureDetector(
                                    onTap: () {
                                      router.push(ImageClosePage.routeName,
                                          extra: message.content['file'] as File);
                                    },
                                    child: Image.file(message.content['file'] as File,
                                        fit: BoxFit.cover))
                                : message.messageType == MessageType.video
                                    ? GestureDetector(
                                        onTap: () {
                                          router.push(VideoPlayerPage.routeName,
                                              extra: message.content['file'] as File);
                                        },
                                        child: Stack(
                                          children: [
                                            (ref.watch(message.content['thumbnail'])
                                                    as AsyncValue<Uint8List>)
                                                .when(
                                                    data: (data) =>
                                                        Image.memory(data, fit: BoxFit.cover),
                                                    loading: () =>
                                                        SizedBox(width: 243.w, height: 400.h),
                                                    error: (error, stackTrace) =>
                                                        SizedBox(width: 243.w, height: 400.h)),
                                            Positioned.fill(
                                                child: Align(
                                                    alignment: Alignment.center,
                                                    child: Icon(Icons.play_circle_fill,
                                                        color: Colors.white, size: 50.r)))
                                          ],
                                        ))
                                    : Container(
                                        height: 60,
                                        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8.w),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8)),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Text(message.content['fileName'],
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 14,
                                                        color: Color(0xFF3B3B3B)))),
                                            SizedBox(width: 4.w),
                                            GestureDetector(
                                                onTap: () async {
                                                  await OpenFilex.open(
                                                      message.content['file'].path);
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                        border: const Border.fromBorderSide(
                                                            BorderSide(
                                                                color: Colors.grey, width: 1)),
                                                        borderRadius: BorderRadius.circular(4),
                                                        color: Colors.white),
                                                    child: Icon(Icons.file_copy,
                                                        size: 22,
                                                        color: Colors.blue.withOpacity(0.9))))
                                          ],
                                        ))),
                    SizedBox(width: 4.w),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.messageType == MessageType.text)
                            GestureDetector(
                                onTap: () {
                                  showOriginMessages.value =
                                      showOriginMessages.value.contains(message.seqId)
                                          ? showOriginMessages.value
                                              .where((e) => e != message.seqId)
                                              .toList()
                                          : [...showOriginMessages.value, message.seqId];
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    child: Text(
                                        showOriginMessages.value.contains(message.seqId)
                                            ? '번역보기'
                                            : '원문보기',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.black.withOpacity(0.7))))),
                          if ((message.totalParticipants ?? 0) - message.readCount! > 0)
                            Text(((message.totalParticipants ?? 0) - message.readCount!).toString(),
                                style:
                                    TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.7))),
                          if (optional)
                            Text(message.createdAt.to24HourFormat(),
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF3B3B3B),
                                    fontWeight: FontWeight.w500)),
                        ])
                  ],
                )
              ],
            )
          ],
        ),
        if (change) const SizedBox(height: 14)
      ],
    );
  }

  Widget _myChat({required WidgetRef ref,
    Message? message,
      bool optional = false,
      bool change = false,
      LoadingMessage? loadingMessage}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (loadingMessage != null && loadingMessage.messageType == MessageType.text)
              const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(),
                  )
                ],
              ),
            if (message != null)
              Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if ((message.totalParticipants ?? 0) - message.readCount! > 0)
                      Text(((message.totalParticipants ?? 0) - message.readCount!).toString(),
                          style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.7))),
                    if (optional)
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
                padding: message?.messageType == MessageType.text ||
                        loadingMessage?.messageType == MessageType.text
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                    : EdgeInsets.zero,
                decoration: ShapeDecoration(
                  color: message?.messageType == MessageType.text ||
                          loadingMessage?.messageType == MessageType.text
                      ? const Color(0xFFECE5FF)
                      : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: message?.messageType == MessageType.text ||
                            loadingMessage?.messageType == MessageType.text ||
                            message?.messageType == MessageType.file ||
                            loadingMessage?.messageType == MessageType.file
                        ? BorderRadius.circular(16)
                        : BorderRadius.zero,
                  ),
                ),
                child: message?.messageType == MessageType.text ||
                        loadingMessage?.messageType == MessageType.text
                    ? Text(message?.showMessage() ?? loadingMessage?.showMessage(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF3B3B3B)))
                    : message?.messageType == MessageType.image ||
                            loadingMessage?.messageType == MessageType.image
                        ? GestureDetector(
                            onTap: () {
                              if (message != null) {
                                router.push(ImageClosePage.routeName,
                                    extra: message.content['file'] as File);
                              }
                            },
                            child: Stack(children: [
                              Image.file(
                                  (message?.content['file'] ?? loadingMessage?.content) as File,
                                  fit: BoxFit.cover),
                              if (loadingMessage != null)
                                Positioned.fill(
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 6,
                                          value: (loadingMessage.progress ?? 0) / 100,
                                          color: const Color(0xFF7D4DFF),
                                        )))
                            ]))
                        : message?.messageType == MessageType.video ||
                                loadingMessage?.messageType == MessageType.video
                            ? GestureDetector(
                                onTap: () {
                                  if (message != null) {
                                    router.push(VideoPlayerPage.routeName,
                                        extra: message.content['file'] as File);
                                  }
                                },
                                child: Stack(
                                  children: [
                                    (ref.watch((message?.content['thumbnail'] ??
                                                loadingMessage?.content['thumbnail']))
                                            as AsyncValue<Uint8List>)
                                        .when(
                                            data: (data) => Image.memory(data, fit: BoxFit.cover),
                                            loading: () => SizedBox(width: 243.w, height: 400.h),
                                            error: (error, stackTrace) =>
                                                SizedBox(width: 243.w, height: 400.h)),
                                    loadingMessage == null
                                        ? Positioned.fill(
                                            child: Align(
                                                alignment: Alignment.center,
                                                child: Icon(Icons.play_circle_fill,
                                                    color: Colors.white, size: 50.r)))
                                        : Positioned.fill(
                                            child: Align(
                                                alignment: Alignment.center,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 6,
                                                  value: (loadingMessage.progress ?? 0) / 100,
                                                  color: const Color(0xFF7D4DFF),
                                                )))
                                  ],
                                ))
                            : Container(
                                height: 60,
                                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8.w),
                                decoration: BoxDecoration(
                                    color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            message?.content['fileName'] ??
                                                loadingMessage?.showMessage().path.split('/').last,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Color(0xFF3B3B3B)))),
                                    SizedBox(width: 4.w),
                                    message == null
                                        ? SizedBox(
                                            width: 22.r,
                                            height: 22.r,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 6,
                                              value: (loadingMessage?.progress ?? 0) / 100,
                                              color: const Color(0xFF7D4DFF),
                                            ))
                                        : GestureDetector(
                                            onTap: () async {
                                              await OpenFilex.open(message.content['file'].path);
                                            },
                                            child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                    border: const Border.fromBorderSide(
                                                        BorderSide(color: Colors.grey, width: 1)),
                                                    borderRadius: BorderRadius.circular(4),
                                                    color: Colors.white),
                                                child: Icon(Icons.file_copy,
                                                    size: 22, color: Colors.blue.withOpacity(0.9))))
                                  ],
                                ))),
          ],
        ),
        if (change) const SizedBox(height: 14)
      ],
    );
  }

  List<Widget> _showLeftBar(WidgetRef ref, BuildContext context, ValueNotifier<bool> isShow,
          ValueNotifier<List<ChatUserInfo>> participants, ChatUserInfo? owner) =>
      [
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
                              router.push(InviteFriendPage.routeName, extra: {
                                'chatRoomId': chatRoomHeader.chatRoomId,
                                'participants': participants.value.map((e) => e.id).toList()
                              });
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
                                _profileWidget(ref, context, participants.value.length, owner),
                                ...participants.value
                                    .where((e) => e.id != ref.watch(userProvider)!.id)
                                    .map((e) => _profileWidget(
                                        ref, context, participants.value.length, owner,
                                        participant: e))
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
                            onTap: () {
                              isShow.value = false;
                              ChatService().leaveRoom(ref, chatRoomHeader.chatRoomId).then((_) {
                                router.pop();
                              });
                            },
                            child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10),
                                child: SvgPicture.asset('assets/images/out.svg', width: 24))))
                  ],
                )))
      ];

  Widget _profileWidget(
          WidgetRef ref, BuildContext context, int participantCount, ChatUserInfo? owner,
          {ChatUserInfo? participant}) =>
      GestureDetector(
          onTap: () async {
            if (participant != null) {
              final ChatUserInfo chatUserInfo =
                  await UserService().getChatUserInfo(ref, participant.id);

              router.push(ChatProfilePage.routeName, extra: chatUserInfo);
            } else {
              router.push(ChatProfilePage.routeName,
                  extra: ChatUserInfo(id: ref.read(userProvider)!.id, name: ''));
            }
          },
          child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 7.h),
              child: Row(
                children: [
                  ClipOval(
                    child: (participant == null
                            ? ref.read(userProvider)!.userInfo.profileImg == null
                                ? null
                                : Image.file(ref.read(userProvider)!.userInfo.profileImg!,
                                    width: 40, height: 40, fit: BoxFit.fill)
                            : participant.profileImg == null
                                ? null
                                : Image.file(participant.profileImg!,
                                    width: 40, height: 40, fit: BoxFit.fill)) ??
                        Image.asset('assets/images/default_profile.png', width: 40, height: 40),
                  ),
                  SizedBox(width: 11.w),
                  if (participant == null)
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DefaultTextStyle(
                            style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF3B3B3B),
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis),
                            child: Text(ref.watch(userProvider)!.name)),
                        const DefaultTextStyle(
                            style: TextStyle(fontSize: 12, color: Color(0xFFE0E2E4)),
                            child: Text('나'))
                      ],
                    )),
                  if (participant != null) ...[
                    Expanded(
                        child: DefaultTextStyle(
                            style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF3B3B3B),
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis),
                            child: Text(participant.name))),
                    SizedBox(width: 4.w),
                    if (owner?.id == ref.read(userProvider)!.id)
                      GestureDetector(
                          onTap: () {
                            kickPopup(context, ref, participant);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFF7C4DFF), width: 1),
                                borderRadius: BorderRadius.circular(20)),
                            child: const DefaultTextStyle(
                                style: TextStyle(fontSize: 12, color: Color(0xFF7C4DFF)),
                                child: Text('내보내기')),
                          ))
                  ]
                ],
              )));

  Widget infoMessage(String message) => Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      );

  Widget dateMessage(DateTime dateTime) => Row(
        children: [
          Expanded(
              child: Divider(
                  color: const Color(0xFFA1A1A1), height: 20, thickness: 1, endIndent: 14.w)),
          Text(
            dateTime.yyyyMMdd(),
            style: const TextStyle(fontSize: 10, color: Color(0xFFA1A1A1)),
          ),
          Expanded(
              child:
                  Divider(color: const Color(0xFFA1A1A1), height: 20, thickness: 1, indent: 14.w)),
        ],
      );

  Future<void> _loadMedia(
      ValueNotifier<File?> selectedImage,
      ValueNotifier<File?> selectedVideo,
      ValueNotifier<ChewieController?> chewieController,
      ValueNotifier<VideoPlayerController?> videoPlayerController,
      TextEditingController textController) async {
    await ImagePicker().pickMedia(imageQuality: 10).then((value) {
      if (value != null) {
        if (['mov', 'mp4', 'temp'].contains(value.path.split('.').last)) {
          selectedVideo.value = File(value.path);
          videoPlayerController.value = VideoPlayerController.file(selectedVideo.value!);
          chewieController.value = ChewieController(
              videoPlayerController: videoPlayerController.value!,
              autoPlay: true,
              looping: true,
              allowFullScreen: false,
              allowPlaybackSpeedChanging: false);
        } else {
          selectedImage.value = File(value.path);
        }
        textController.clear();
      }
    });
  }

  Future<void> _loadMediaByCamera(
      ValueNotifier<File?> selectedImage,
      ValueNotifier<File?> selectedVideo,
      ValueNotifier<ChewieController?> chewieController,
      ValueNotifier<VideoPlayerController?> videoPlayerController,
      TextEditingController textController) async {
    final XFile? xFile = await router.push(CameraPage.routeName);
    print('xFile: ${xFile?.path}');

    if (xFile != null) {
      if (['mov', 'mp4', 'temp'].contains(xFile.path.split('.').last)) {
        selectedVideo.value = File(xFile.path);
        videoPlayerController.value = VideoPlayerController.file(selectedVideo.value!);
        chewieController.value = ChewieController(
            videoPlayerController: videoPlayerController.value!,
            autoPlay: true,
            looping: true,
            allowFullScreen: false,
            allowPlaybackSpeedChanging: false);
      } else {
        selectedImage.value = File(xFile.path);
      }
      textController.clear();
    }
  }

  Future<File?> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      return null;
    }
  }
}
