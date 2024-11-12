import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:anychat/model/user.dart';
import 'package:anychat/state/user_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserService extends SecuredHttpClient {
  final String basePath = '/account/api/users';

  Future<void> getMe(WidgetRef ref) async {
    await get(path: '$basePath/get-me', converter: (result) => result['data']).run(
      ref,
      (data) {
        ref.read(userProvider.notifier).setUser(User.fromJson(data));
      },
      errorMessage: '내 정보를 불러오는데 실패했습니다',
    );
  }
}
