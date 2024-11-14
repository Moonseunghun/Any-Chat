import 'package:anychat/model/friend.dart';
import 'package:anychat/page/chat/chat_page.dart';
import 'package:anychat/page/chat/invite_friend_page.dart';
import 'package:anychat/page/home/add_friend_by_id_page.dart';
import 'package:anychat/page/home/block_friend_page.dart';
import 'package:anychat/page/home/edit_friend_page.dart';
import 'package:anychat/page/home/hide_friend_page.dart';
import 'package:anychat/page/login/consent_page.dart';
import 'package:anychat/page/login/language_select_page.dart';
import 'package:anychat/page/login/login_page.dart';
import 'package:anychat/page/user/profile_page.dart';
import 'package:go_router/go_router.dart';

import 'main_layout.dart';

final router = GoRouter(initialLocation: '/login', routes: [
  GoRoute(path: LoginPage.routeName, builder: (context, state) => const LoginPage()),
  GoRoute(path: LanguageSelectPage.routeName, builder: (context, state) => LanguageSelectPage()),
  GoRoute(path: ConsentPage.routeName, builder: (context, state) => const ConsentPage()),
  GoRoute(path: MainLayout.routeName, builder: (context, state) => MainLayout()),
  GoRoute(
      path: ProfilePage.routeName,
      builder: (context, state) => ProfilePage(friend: state.extra as Friend?)),
  GoRoute(
      path: AddFriendByIdPage.routeName, builder: (context, state) => const AddFriendByIdPage()),
  GoRoute(path: ChatPage.routeName, builder: (context, state) => const ChatPage()),
  GoRoute(path: HideFriendPage.routeName, builder: (context, state) => const HideFriendPage()),
  GoRoute(path: BlockFriendPage.routeName, builder: (context, state) => const BlockFriendPage()),
  GoRoute(path: InviteFriendPage.routeName, builder: (context, state) => const InviteFriendPage()),
  GoRoute(
    path: EditFriendPage.routeName,
    pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const EditFriendPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
        transitionDuration: Duration.zero),
  )
]);
