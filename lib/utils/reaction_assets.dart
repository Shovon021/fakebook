import '../models/post_model.dart';

class ReactionAssets {
  // Using reliable static emoji images - FB-style reactions from Imgur
  static String getReactionPath(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return 'https://i.imgur.com/O3Z5P5E.png'; // Blue thumbs up
      case ReactionType.love:
        return 'https://i.imgur.com/RLxqvHf.png'; // Red heart
      case ReactionType.haha:
        return 'https://i.imgur.com/b8qKvds.png'; // Laughing face
      case ReactionType.wow:
        return 'https://i.imgur.com/XGjBEuJ.png'; // Wow face
      case ReactionType.sad:
        return 'https://i.imgur.com/P3wLdwN.png'; // Sad face
      case ReactionType.angry:
        return 'https://i.imgur.com/lPb5aSD.png'; // Angry face
      case ReactionType.care:
        return 'https://i.imgur.com/5o8LmzX.png'; // Care hug
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
