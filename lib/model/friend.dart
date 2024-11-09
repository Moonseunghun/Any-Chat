class Friend {
  final int id;
  final String nickname;
  final int friendTypeId;
  final bool isPinned;
  final DateTime createdAt;

  Friend(
      {required this.id,
      required this.nickname,
      required this.friendTypeId,
      required this.isPinned,
      required this.createdAt});
}
