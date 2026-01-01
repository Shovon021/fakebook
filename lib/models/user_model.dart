class UserModel {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String? bio;
  final int friendsCount;
  final bool isFriend;

  UserModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isOnline = false,
    this.bio,
    this.friendsCount = 0,
    this.isFriend = false,
  });
}
