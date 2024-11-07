import 'package:anychat/page/router.dart';
import 'package:anychat/state/util_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'firebase_options.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
