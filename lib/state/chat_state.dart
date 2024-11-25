import 'package:anychat/model/chat.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRoomInfoNotifier extends StateNotifier<List<ChatRoomInfo>> {
  ChatRoomInfoNotifier(super.state);

  void set(List<ChatRoomInfo> chatRoomInfo) {
    state = chatRoomInfo;
  }

  void update(ChatRoomInfo chatRoomInfo) {
    state = [...state.where((e) => e != chatRoomInfo), chatRoomInfo]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}

final chatRoomInfoProvider = StateNotifierProvider<ChatRoomInfoNotifier, List<ChatRoomInfo>>((ref) {
  return ChatRoomInfoNotifier([]);
});
