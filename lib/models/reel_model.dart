import 'user_model.dart';

class ReelModel {
  final String id;
  final UserModel user;
  final String videoUrl;
  final String thumbUrl;
  final String description;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool isLiked;

  ReelModel({
    required this.id,
    required this.user,
    required this.videoUrl,
    required this.thumbUrl,
    required this.description,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.viewsCount,
    this.isLiked = false,
  });
}
