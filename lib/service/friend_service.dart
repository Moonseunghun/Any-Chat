import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/util_state.dart';

class FriendService extends SecuredHttpClient {
  final String basePath = '/friend/api';

  Future<void> getFriends(WidgetRef ref) async {
    // ref.read(loadingProvider.notifier).on();
    // get(path: basePath, queryParams: {'order': 'nickname_ASC'}, converter: (result) => result).run(
    //     (data) {
    //   print(data);
    // }, errorMessage: '친구 목록을 불러오는 중 오류가 발생했습니다.').whenComplete(() {
    //   ref.read(loadingProvider.notifier).off();
    // });
  }
}
