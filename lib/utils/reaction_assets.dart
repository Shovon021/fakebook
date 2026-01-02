import '../models/post_model.dart';

class ReactionAssets {
  // Using public raw github assets for standard FB reactions (GIFs)
  static const String _baseMove = 'https://raw.githubusercontent.com/may-andro/flutter_reactions/master/example/assets/images';
  
  static String getReactionPath(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return '$_baseMove/like.gif';
      case ReactionType.love:
        return '$_baseMove/love.gif';
      case ReactionType.haha:
        return '$_baseMove/haha.gif';
      case ReactionType.wow:
        return '$_baseMove/wow.gif';
      case ReactionType.sad:
        return '$_baseMove/sad.gif';
      case ReactionType.angry:
        return '$_baseMove/angry.gif';
      case ReactionType.care:
        // Care reaction is newer, using a specific reliable source or fallback
        // Using a known Care animation URL
        return 'https://media.tenor.com/_ed8aW8oJgIAAAAi/facebook-care-emoji-care.gif'; 
    }
  }

  static String getReactionIcon(ReactionType type) {
    // For static icons (small), we can use the same or specific PNGs if available.
    // For now returning the same as they scale down okay, or we could use specific PNGs.
    return getReactionPath(type);
  }
}
