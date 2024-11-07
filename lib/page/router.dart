import 'package:anychat/page/login/login_page.dart';
import 'package:go_router/go_router.dart';

import 'main_layout.dart';

final router = GoRouter(initialLocation: '/', routes: [
  GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
  GoRoute(path: '/', builder: (context, state) => MainLayout())
]);
