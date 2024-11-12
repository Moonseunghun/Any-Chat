import 'package:anychat/page/chat/chat_page.dart';
import 'package:anychat/page/home/add_friend_by_id_page.dart';
import 'package:anychat/page/login/consent_page.dart';
import 'package:anychat/page/login/language_select_page.dart';
import 'package:anychat/page/login/login_page.dart';
import 'package:anychat/page/user/profile_page.dart';
import 'package:go_router/go_router.dart';

import 'main_layout.dart';

final router = GoRouter(initialLocation: '/login', routes: [
  GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
  GoRoute(path: '/language', builder: (context, state) => LanguageSelectPage()),
  GoRoute(path: '/consent', builder: (context, state) => const ConsentPage()),
  GoRoute(path: '/', builder: (context, state) => MainLayout()),
  GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
  GoRoute(path: '/friend/add/id', builder: (context, state) => const AddFriendByIdPage()),
  GoRoute(path: '/chat', builder: (context, state) => const ChatPage())
]);
