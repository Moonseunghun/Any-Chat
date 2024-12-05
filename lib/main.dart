import 'package:anychat/page/router.dart';
import 'package:anychat/service/chat_service.dart';
import 'package:anychat/service/database_service.dart';
import 'package:anychat/service/gateway_service.dart';
import 'package:anychat/state/util_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:toastification/toastification.dart';

import 'firebase_options.dart';

late final SharedPreferences prefs;
Socket? socket;
bool socketConnected = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await DatabaseService.getDatabase();

  GatewayService().gateway();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      return () {
        DatabaseService.close();
        if (socket != null) {
          ChatService().disposeSocket();
        }
      };
    }, []);

    return ScreenUtilInit(
        designSize: const Size(393, 852),
        splitScreenMode: false,
        builder: (_, child) => ToastificationWrapper(
            child: MaterialApp.router(
                theme: ThemeData(
                    useMaterial3: false,
                    scaffoldBackgroundColor: Colors.white,
                    fontFamily: 'Pretendard'),
                routerConfig: router,
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  return Stack(children: [
                    child!,
                    if (ref.watch(loadingProvider))
                      Container(
                          color: Colors.black.withOpacity(0.35),
                          child: SpinKitRing(
                              color: const Color(0xFF7C4DFF),
                              duration: const Duration(milliseconds: 1600),
                              lineWidth: 6.r,
                              size: 50.r))
                  ]);
                })));
  }
}
