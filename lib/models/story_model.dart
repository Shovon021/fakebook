import 'user_model.dart';

class StoryModel {
  final String id;
  final UserModel user;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isViewed;
  final bool isOwnStory;

  StoryModel({
    required this.id,
    required this.user,
    this.imageUrl,
    required this.createdAt,
    this.isViewed = false,
    this.isOwnStory = false,
  });

  StoryModel copyWith({
    String? id,
    UserModel? user,
    String? imageUrl,
    DateTime? createdAt,
    bool? isViewed,
    bool? isOwnStory,
  }) {
    return StoryModel(
      id: id ?? this.id,
      user: user ?? this.user,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isViewed: isViewed ?? this.isViewed,
      isOwnStory: isOwnStory ?? this.isOwnStory,
    );
  }
}
