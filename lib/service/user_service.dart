import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:anychat/model/user.dart';
import 'package:anychat/state/user_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/util_state.dart';

class UserService extends SecuredHttpClient {
  final String basePath = '/account/api/users';

  Future<void> getMe(WidgetRef ref) async {
    ref.read(loadingProvider.notifier).on();
    await get(path: '$basePath/get-me', converter: (result) => result['data']).run(
      (data) {
        ref.read(userProvider.notifier).setUser(User.fromJson(data));
      },
      errorMessage: '내 정보를 불러오는데 실패했습니다',
    ).whenComplete(() {
      ref.read(loadingProvider.notifier).off();
    });
  }
}
