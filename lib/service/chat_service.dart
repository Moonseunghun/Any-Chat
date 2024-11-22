import 'package:anychat/common/error.dart';
import 'package:anychat/common/http_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/friend.dart';

class ChatService extends SecuredHttpClient {
  final String basePath = '/chat/api';

  Future<void> getRooms() async {
    get(path: basePath, converter: (result) => result).run(null, (result) {
      print(result);
    }, errorMessage: '채팅방 목록을 불러오는데 실패했습니다.');
  }

  makeRoom(WidgetRef ref, List<Friend> friends) async {
    post(
        path: basePath,
        queryParams: {
          'targetUserIds': friends.map((e) => e.friend.id).toList(),
          'chatRoomName': friends.length > 6
              ? "${friends.map((e) => e.nickname).take(6).join(', ')}..."
              : friends.map((e) => e.nickname).join(', ')
        },
        converter: (result) => result['data']).run(ref, (result) {
      print(result);
    }, errorMessage: '채팅방을 생성하는데 실패했습니다.');
  }
}
