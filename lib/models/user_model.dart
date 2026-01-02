class UserModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String? coverUrl;
  final bool isOnline;
  final String? bio;
  final int friendsCount;
  final bool isFriend;
  final List<String> details; // Education, Work, etc.
  final List<String>? friends; // Friend user IDs

  UserModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.coverUrl,
    this.isOnline = false,
    this.bio,
    this.friendsCount = 0,
    this.isFriend = false,
    this.details = const [],
    this.friends,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'coverUrl': coverUrl,
      'isOnline': isOnline,
      'bio': bio,
      'friendsCount': friendsCount,
      'isFriend': isFriend,
      'details': details,
      'friends': friends,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'] ?? 'https://i.imgur.com/7u537k8.png',
      coverUrl: map['coverUrl'],
      isOnline: map['isOnline'] ?? false,
      bio: map['bio'],
      friendsCount: map['friendsCount'] ?? 0,
      isFriend: map['isFriend'] ?? false,
      details: List<String>.from(map['details'] ?? []),
      friends: map['friends'] != null ? List<String>.from(map['friends']) : null,
    );
  }

  // CopyWith for easy updates
  UserModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? coverUrl,
    bool? isOnline,
    String? bio,
    int? friendsCount,
    bool? isFriend,
    List<String>? details,
    List<String>? friends,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      isOnline: isOnline ?? this.isOnline,
      bio: bio ?? this.bio,
      friendsCount: friendsCount ?? this.friendsCount,
      isFriend: isFriend ?? this.isFriend,
      details: details ?? this.details,
      friends: friends ?? this.friends,
    );
  }
}
