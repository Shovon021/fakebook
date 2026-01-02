import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../models/notification_model.dart';
import '../models/marketplace_model.dart';
import '../models/reel_model.dart';

class DummyData {
  // Current User
  static final UserModel currentUser = UserModel(
    id: '0',
    name: 'Sarfaraz Ahamed Shovon',
    avatarUrl: 'https://i.imgur.com/K3Z3gM9.jpeg', // Adjusted to look like red shirt Profile
    isOnline: true,
    bio: 'Alhamdulillah🤲',
    friendsCount: 767,
    details: [
      'Undergraduate Teaching Assistant (UTA) at East West University',
      'General Member at East West University Robotics Club',
      'Studied at East West University',
      'Went to Government Science College',
      'Lives in Dhaka, Bangladesh',
    ],
  );

  // Specific Friends from User's Feed/Story
  static final UserModel tareq = UserModel(
    id: '100',
    name: 'Tareq Aziz',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1887&auto=format&fit=crop', // Male portrait
    isOnline: false,
    friendsCount: 1052,
    isFriend: true,
  );

  static final UserModel ankon = UserModel(
    id: '101',
    name: 'Ankon Baroi',
    avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1887&auto=format&fit=crop', // Male portrait
    isOnline: true,
    friendsCount: 420,
    isFriend: true,
  );

  static final UserModel esme = UserModel(
    id: '102',
    name: 'Esme Azam Rifat',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1887&auto=format&fit=crop', // Male portrait
    isOnline: true,
    friendsCount: 890,
    isFriend: true,
  );
  
  static final UserModel zamil = UserModel(
    id: '103',
    name: 'Zamil Zani',
    avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=1887&auto=format&fit=crop', // Groom/Wedding attire
    isOnline: false,
    friendsCount: 1560,
    isFriend: true,
  );

  // Original Sample Users (keeping some for variety)
  static final List<UserModel> users = [
    tareq,
    ankon,
    esme,
    zamil,
    UserModel(
      id: '1',
      name: 'Sarah Johnson',
      avatarUrl: 'https://picsum.photos/seed/user1/150/150',
      isOnline: true,
      friendsCount: 523,
      isFriend: true,
    ),
    UserModel(
      id: '4',
      name: 'David Brown',
      avatarUrl: 'https://picsum.photos/seed/user4/150/150',
      isOnline: false,
      friendsCount: 456,
      isFriend: true,
    ),
    UserModel(
      id: '5',
      name: 'Lisa Anderson',
      avatarUrl: 'https://picsum.photos/seed/user5/150/150',
      isOnline: true,
      friendsCount: 678,
      isFriend: false,
    ),
  ];

  // Sample Posts
  static final List<PostModel> posts = [
    // 1. Tareq's Cover Photo Update (From Screenshot)
    PostModel(
      id: 'p1',
      author: tareq,
      content: 'updated his cover photo.',
      imageUrl: 'https://images.unsplash.com/photo-1542362567-b07e54358753?q=80&w=2070&auto=format&fit=crop', // Car interior
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likesCount: 124,
      commentsCount: 32,
      sharesCount: 2,
      userReaction: ReactionType.like,
      isShared: false,
    ),
    // 2. Ankon's Life Update
    PostModel(
      id: 'p2',
      author: ankon,
      content: 'New year, new resolution! 2025 will be great. ✨',
      imageUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?q=80&w=2069&auto=format&fit=crop', // Celebration/Party
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      likesCount: 89,
      commentsCount: 15,
      sharesCount: 0,
    ),
    // 3. User's Own Post (Cover Photo Update simulation)
    PostModel(
      id: 'p3',
      author: currentUser,
      content: 'Singing along to 🎤',
      imageUrl: 'https://images.unsplash.com/photo-1516280440614-6697288d5d38?q=80&w=2070&auto=format&fit=crop', // Music/Mic theme
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      likesCount: 45,
      commentsCount: 12,
      sharesCount: 1,
    ),
    // 4. Esme's Shared Post
    PostModel(
      id: 'p4',
      author: esme,
      content: 'Couldn\'t agree more!',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      likesCount: 210,
      commentsCount: 56,
      sharesCount: 5,
      isShared: true,
      sharedPost: PostModel(
        id: 'p5',
        author: zamil,
        content: 'Wedding season vibes! 💍🤵',
        imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=2070&auto=format&fit=crop',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        likesCount: 890,
        commentsCount: 230,
        sharesCount: 45,
      ),
    ),
    PostModel(
      id: 'p6',
      author: users[5], // David Brown
      content: 'Does anyone know a good place to fix a laptop screen? Urgent! 💻🔧',
      backgroundColor: const Color(0xFFE41E3F),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      likesCount: 45,
      commentsCount: 32,
      sharesCount: 0,
    ),
  ];

  // Sample Stories (Matching Screenshot order)
  static final List<StoryModel> stories = [
    // 1. Current User
    StoryModel(
      id: 's0',
      user: currentUser,
      createdAt: DateTime.now(),
      isOwnStory: true,
    ),
    // 2. Ankon Baroi
    StoryModel(
      id: 's1',
      user: ankon,
      imageUrl: 'https://images.unsplash.com/photo-1705646543088-3729e2730248?q=80&w=1964&auto=format&fit=crop', // Tall building/City
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    // 3. Esme Azam Rifat
    StoryModel(
      id: 's2',
      user: esme,
      imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1887&auto=format&fit=crop', // Friends group
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isViewed: true,
    ),
    // 4. Zamil Zani
    StoryModel(
      id: 's3',
      user: zamil,
      imageUrl: 'https://images.unsplash.com/photo-1606800052052-a08af7148866?q=80&w=2070&auto=format&fit=crop', // Wedding decor
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    // 5. Tareq Aziz
    StoryModel(
      id: 's4',
      user: tareq,
      imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?q=80&w=2021&auto=format&fit=crop', // Travel
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // Sample Notifications
  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'n1',
      title: 'Esme Azam Rifat',
      body: 'liked your photo.',
      avatarUrl: esme.avatarUrl,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.like,
    ),
    NotificationModel(
      id: 'n2',
      title: 'Tareq Aziz',
      body: 'commented on your post: "Congrats!"',
      avatarUrl: tareq.avatarUrl,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.comment,
    ),
    NotificationModel(
      id: 'n3',
      title: 'Ankon Baroi',
      body: 'sent you a friend request.',
      avatarUrl: ankon.avatarUrl,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.friendRequest,
      isRead: true,
    ),
    NotificationModel(
      id: 'n4',
      title: 'Zamil Zani',
      body: 'invited you to join a group.',
      avatarUrl: zamil.avatarUrl,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.groupActivity,
      isRead: true,
    ),
    NotificationModel(
      id: 'n5',
      title: "Tamim Iqbal's birthday is today!",
      body: 'Write on his timeline.',
      avatarUrl: 'https://picsum.photos/seed/tamim/150/150',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      type: NotificationType.birthday,
    ),
  ];

  // Sample Marketplace Items
  static final List<MarketplaceItemModel> marketplaceItems = [
    MarketplaceItemModel(
      id: 'm1',
      title: 'iPhone 14 Pro Max - Like New',
      price: 899,
      imageUrl: 'https://source.unsplash.com/random/400x400?iphone',
      location: 'Dhaka, Bangladesh',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Electronics',
      description: 'Like new condition, no scratches.',
      sellerId: 'dummySeller1',
    ),
    MarketplaceItemModel(
      id: 'm2',
      title: 'Yamaha R15 v3',
      price: 2500,
      imageUrl: 'https://source.unsplash.com/random/400x400?motorcycle',
      location: 'Chittagong',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      category: 'Vehicles',
      description: 'Sports bike in excellent condition.',
      sellerId: 'dummySeller2',
    ),
    MarketplaceItemModel(
      id: 'm3',
      title: 'Sony PlayStation 5',
      price: 450,
      imageUrl: 'https://source.unsplash.com/random/400x400?ps5',
      location: 'Sylhet',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isSaved: true,
      category: 'Electronics',
      description: 'Gaming console with one controller.',
      sellerId: 'dummySeller3',
    ),
  ];

  // Friend Requests
  static final List<UserModel> friendRequests = [
    users[4],
    users[5],
  ];

  // Friend Suggestions
  static final List<UserModel> friendSuggestions = [
    UserModel(
      id: 'fs1',
      name: 'Rahim Islam',
      avatarUrl: 'https://picsum.photos/seed/rahim/150/150',
      friendsCount: 345,
    ),
    UserModel(
      id: 'fs2',
      name: 'Karim Uddin',
      avatarUrl: 'https://picsum.photos/seed/karim/150/150',
      friendsCount: 567,
    ),
  ];

  // Sample Reels
  static final List<ReelModel> reels = [
    ReelModel(
      id: 'r1',
      user: users[0],
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4',
      thumbUrl: 'https://picsum.photos/seed/reel1/400/800',
      description: 'Dhaka nightlife ✨ #dhaka #night',
      likesCount: 1200,
      commentsCount: 300,
      sharesCount: 50,
      viewsCount: 5000,
    ),
    ReelModel(
      id: 'r2',
      user: zamil,
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4',
      thumbUrl: 'https://picsum.photos/seed/reel2/400/800',
      description: 'Cox\'s Bazar trip 🌊 #beach #fun',
      likesCount: 890,
      commentsCount: 150,
      sharesCount: 30,
      viewsCount: 3000,
    ),
  ];
}
