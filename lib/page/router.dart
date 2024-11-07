import 'package:anychat/page/login/consent_page.dart';
import 'package:anychat/page/login/language_select_page.dart';
import 'package:anychat/page/login/login_page.dart';
import 'package:go_router/go_router.dart';

import 'main_layout.dart';

final router = GoRouter(initialLocation: '/login', routes: [
  GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
  GoRoute(path: '/language', builder: (context, state) => LanguageSelectPage()),
  GoRoute(path: '/consent', builder: (context, state) => const ConsentPage()),
  GoRoute(path: '/', builder: (context, state) => MainLayout())
]);
