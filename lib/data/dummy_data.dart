import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../models/notification_model.dart';
import '../models/marketplace_model.dart';

class DummyData {
  // Current User
  static final UserModel currentUser = UserModel(
    id: '0',
    name: 'John Doe',
    avatarUrl: 'https://picsum.photos/seed/user0/150/150',
    isOnline: true,
    bio: 'Living my best life 🌟',
    friendsCount: 847,
  );

  // Sample Users
  static final List<UserModel> users = [
    UserModel(
      id: '1',
      name: 'Sarah Johnson',
      avatarUrl: 'https://picsum.photos/seed/user1/150/150',
      isOnline: true,
      friendsCount: 523,
      isFriend: true,
    ),
    UserModel(
      id: '2',
      name: 'Mike Wilson',
      avatarUrl: 'https://picsum.photos/seed/user2/150/150',
      isOnline: false,
      friendsCount: 892,
      isFriend: true,
    ),
    UserModel(
      id: '3',
      name: 'Emily Davis',
      avatarUrl: 'https://picsum.photos/seed/user3/150/150',
      isOnline: true,
      friendsCount: 1205,
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
    UserModel(
      id: '6',
      name: 'James Miller',
      avatarUrl: 'https://picsum.photos/seed/user6/150/150',
      isOnline: false,
      friendsCount: 234,
      isFriend: false,
    ),
    UserModel(
      id: '7',
      name: 'Amanda Taylor',
      avatarUrl: 'https://picsum.photos/seed/user7/150/150',
      isOnline: true,
      friendsCount: 1567,
      isFriend: true,
    ),
    UserModel(
      id: '8',
      name: 'Chris Martinez',
      avatarUrl: 'https://picsum.photos/seed/user8/150/150',
      isOnline: true,
      friendsCount: 890,
      isFriend: true,
    ),
  ];

  // Sample Posts
  static final List<PostModel> posts = [
    PostModel(
      id: '1',
      author: users[0],
      content: 'Just had an amazing brunch with friends! 🥞☕ Nothing beats good food and great company. #WeekendVibes #BrunchTime',
      imageUrl: 'https://picsum.photos/seed/food1/800/600',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likesCount: 234,
      commentsCount: 45,
      sharesCount: 12,
      userReaction: ReactionType.like,
    ),
    PostModel(
      id: '2',
      author: users[1],
      content: 'Excited to announce that I just got promoted! 🎉 Hard work really pays off. Thank you everyone for your support!',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likesCount: 892,
      commentsCount: 156,
      sharesCount: 23,
    ),
    PostModel(
      id: '3',
      author: users[2],
      content: 'Beautiful sunset at the beach today 🌅',
      imageUrl: 'https://picsum.photos/seed/beach1/800/600',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      likesCount: 567,
      commentsCount: 89,
      sharesCount: 34,
      userReaction: ReactionType.love,
    ),
    PostModel(
      id: '4',
      author: users[3],
      content: 'Who else is watching the game tonight? 🏈 Let\'s go team!',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likesCount: 123,
      commentsCount: 67,
      sharesCount: 5,
    ),
    PostModel(
      id: '5',
      author: users[4],
      content: 'New adventure begins! Starting my road trip across the country 🚗✨',
      imageUrl: 'https://picsum.photos/seed/road1/800/600',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      likesCount: 445,
      commentsCount: 78,
      sharesCount: 21,
    ),
    PostModel(
      id: '6',
      author: users[6],
      content: 'Coffee and coding - perfect Monday combo ☕💻',
      imageUrl: 'https://picsum.photos/seed/coffee1/800/600',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likesCount: 321,
      commentsCount: 45,
      sharesCount: 8,
      userReaction: ReactionType.haha,
    ),
  ];

  // Sample Stories
  static final List<StoryModel> stories = [
    StoryModel(
      id: '0',
      user: currentUser,
      createdAt: DateTime.now(),
      isOwnStory: true,
    ),
    StoryModel(
      id: '1',
      user: users[0],
      imageUrl: 'https://picsum.photos/seed/story1/400/600',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    StoryModel(
      id: '2',
      user: users[2],
      imageUrl: 'https://picsum.photos/seed/story2/400/600',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isViewed: true,
    ),
    StoryModel(
      id: '3',
      user: users[4],
      imageUrl: 'https://picsum.photos/seed/story3/400/600',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    StoryModel(
      id: '4',
      user: users[6],
      imageUrl: 'https://picsum.photos/seed/story4/400/600',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    StoryModel(
      id: '5',
      user: users[7],
      imageUrl: 'https://picsum.photos/seed/story5/400/600',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      isViewed: true,
    ),
  ];

  // Sample Notifications
  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      title: 'Sarah Johnson',
      body: 'liked your photo.',
      avatarUrl: 'https://picsum.photos/seed/user1/150/150',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.like,
    ),
    NotificationModel(
      id: '2',
      title: 'Mike Wilson',
      body: 'commented on your post: "This is awesome!"',
      avatarUrl: 'https://picsum.photos/seed/user2/150/150',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.comment,
    ),
    NotificationModel(
      id: '3',
      title: 'Emily Davis',
      body: 'sent you a friend request.',
      avatarUrl: 'https://picsum.photos/seed/user3/150/150',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.friendRequest,
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      title: 'David Brown',
      body: 'shared your post.',
      avatarUrl: 'https://picsum.photos/seed/user4/150/150',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.share,
      isRead: true,
    ),
    NotificationModel(
      id: '5',
      title: "Lisa Anderson's birthday is today!",
      body: 'Write on her timeline to wish her a happy birthday.',
      avatarUrl: 'https://picsum.photos/seed/user5/150/150',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      type: NotificationType.birthday,
    ),
    NotificationModel(
      id: '6',
      title: 'You have memories to look back on today',
      body: 'See your memories from 1 year ago.',
      avatarUrl: 'https://picsum.photos/seed/user0/150/150',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.memory,
      isRead: true,
    ),
  ];

  // Sample Marketplace Items
  static final List<MarketplaceItemModel> marketplaceItems = [
    MarketplaceItemModel(
      id: '1',
      title: 'iPhone 14 Pro Max - Like New',
      price: 899,
      imageUrl: 'https://picsum.photos/seed/phone1/400/400',
      location: 'New York, NY',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    MarketplaceItemModel(
      id: '2',
      title: 'Vintage Leather Sofa',
      price: 450,
      imageUrl: 'https://picsum.photos/seed/sofa1/400/400',
      location: 'Los Angeles, CA',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    MarketplaceItemModel(
      id: '3',
      title: 'Mountain Bike - Trek',
      price: 650,
      imageUrl: 'https://picsum.photos/seed/bike1/400/400',
      location: 'Chicago, IL',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isSaved: true,
    ),
    MarketplaceItemModel(
      id: '4',
      title: 'Gaming PC Setup',
      price: 1200,
      imageUrl: 'https://picsum.photos/seed/pc1/400/400',
      location: 'Houston, TX',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MarketplaceItemModel(
      id: '5',
      title: 'Acoustic Guitar - Fender',
      price: 280,
      imageUrl: 'https://picsum.photos/seed/guitar1/400/400',
      location: 'Phoenix, AZ',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MarketplaceItemModel(
      id: '6',
      title: 'Drone DJI Mini 3',
      price: 550,
      imageUrl: 'https://picsum.photos/seed/drone1/400/400',
      location: 'Philadelphia, PA',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isSaved: true,
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
      id: '10',
      name: 'Jessica White',
      avatarUrl: 'https://picsum.photos/seed/user10/150/150',
      friendsCount: 345,
    ),
    UserModel(
      id: '11',
      name: 'Robert Clark',
      avatarUrl: 'https://picsum.photos/seed/user11/150/150',
      friendsCount: 567,
    ),
    UserModel(
      id: '12',
      name: 'Michelle Lee',
      avatarUrl: 'https://picsum.photos/seed/user12/150/150',
      friendsCount: 234,
    ),
  ];
}
