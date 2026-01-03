import '../models/post_model.dart';

class ReactionAssets {
  // Using reliable CDN-hosted SVG icons from cdnlogo.com
  static String getReactionPath(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return 'https://static.cdnlogo.com/logos/f/41/facebook-reaction-like.svg';
      case ReactionType.love:
        return 'https://static.cdnlogo.com/logos/f/61/facebook-reaction-love.svg';
      case ReactionType.haha:
        return 'https://static.cdnlogo.com/logos/f/83/facebook-reaction-haha.svg'; 
      case ReactionType.wow:
        return 'https://static.cdnlogo.com/logos/f/20/facebook-reaction-wow.svg';
      case ReactionType.sad:
        return 'https://static.cdnlogo.com/logos/f/73/facebook-reaction-sad.svg';
      case ReactionType.angry:
        return 'https://static.cdnlogo.com/logos/f/23/facebook-reaction-angry.svg';
      case ReactionType.care:
        return 'https://static.cdnlogo.com/logos/f/33/facebook-reaction-care.svg';
    }
  }

  static String getReactionIcon(ReactionType type) {
    return getReactionPath(type);
  }
  
  // Get emoji fallback if images fail
  static String getReactionEmoji(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return '👍';
      case ReactionType.love:
        return '❤️';
      case ReactionType.haha:
        return '😂';
      case ReactionType.wow:
        return '😮';
      case ReactionType.sad:
        return '😢';
      case ReactionType.angry:
        return '😠';
      case ReactionType.care:
        return '🤗';
    }
  }
}
