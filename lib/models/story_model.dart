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
}
