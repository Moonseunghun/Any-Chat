import 'package:anychat/page/login/login_page.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
    initialLocation: '/login',
    routes: [GoRoute(path: '/login', builder: (context, state) => const LoginPage())]);
