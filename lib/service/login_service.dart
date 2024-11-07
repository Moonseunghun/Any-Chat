import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../common/toast.dart';
import '../main.dart';
import '../state/util_state.dart';

class LoginService {
  Future<bool> signInWithGoogle(WidgetRef ref) async {
    late final bool result;
    ref.read(loadingProvider.notifier).on();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleUser == null || googleAuth == null) return false;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      await firebaseAuth.signInWithCredential(credential);

      result = true;
    } catch (error) {
      errorToast(message: "구글 계정 로그인에 실패했습니다");
      result = false;
    } finally {
      ref.read(loadingProvider.notifier).off();
    }

    return result;
  }
}
