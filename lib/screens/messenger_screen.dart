import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/current_user_provider.dart';
import '../theme/app_theme.dart';
import '../services/messenger_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../utils/image_helper.dart';
import 'chat_screen.dart';

class MessengerScreen extends StatefulWidget {
  const MessengerScreen({super.key});

  @override
  State<MessengerScreen> createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> {
  final MessengerService _messengerService = MessengerService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = currentUserProvider.currentUserOrDefault;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
        title: Row(
          children: [
            // Profile Avatar
            GestureDetector(
              onTap: () {
                // Navigate to settings
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: ImageHelper.getImageProvider(currentUser.avatarUrl),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.black : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Chats',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ],
        ),
        actions: [
          // Camera button
          _buildActionButton(
            icon: Icons.camera_alt_outlined,
            isDark: isDark,
            onTap: () {},
          ),
          // Edit/New message button
          _buildActionButton(
            icon: Icons.edit_outlined,
            isDark: isDark,
            onTap: () => _showNewChatDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () {
                // Open search
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade500, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Now Section
                  FutureBuilder<List<UserModel>>(
                    future: _userService.getAllUsers(),
                    builder: (context, snapshot) {
                      final users = (snapshot.data ?? [])
                          .where((u) => u.id != currentUser.id)
                          .toList();
                      if (users.isEmpty) return const SizedBox.shrink();
                      
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return _buildActiveUser(context, user, isDark);
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),

                  // Chat List
                  StreamBuilder<QuerySnapshot>(
                    stream: _messengerService.getChatRoomsStream(currentUser.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      // Sort client-side by lastMessageTime (descending)
                      final chatRooms = (snapshot.data?.docs ?? [])..sort((a, b) {
                        final aTime = (a.data() as Map<String, dynamic>)['lastMessageTime'] as Timestamp?;
                        final bTime = (b.data() as Map<String, dynamic>)['lastMessageTime'] as Timestamp?;
                        if (aTime == null && bTime == null) return 0;
                        if (aTime == null) return 1;
                        if (bTime == null) return -1;
                        return bTime.compareTo(aTime); // Descending
                      });

                      if (chatRooms.isEmpty) {
                        return _buildEmptyState(isDark);
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: chatRooms.length,
                        itemBuilder: (context, index) {
                          final roomData = chatRooms[index].data() as Map<String, dynamic>;
                          final participants = List<String>.from(roomData['participants'] ?? []);
                          final otherUserId = participants.firstWhere(
                            (id) => id != currentUser.id,
                            orElse: () => '',
                          );

                          return FutureBuilder<UserModel?>(
                            future: _userService.getUserById(otherUserId),
                            builder: (context, userSnapshot) {
                              final otherUser = userSnapshot.data;
                              if (otherUser == null) return const SizedBox.shrink();

                              return _buildChatTile(
                                context,
                                otherUser,
                                roomData['lastMessage'] ?? '',
                                roomData['lastMessageTime'] as Timestamp?,
                                isDark,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveUser(BuildContext context, UserModel user, bool isDark) {
    return GestureDetector(
      onTap: () => _openChat(context, user),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: ImageHelper.getImageProvider(user.avatarUrl),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.black : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                user.name.split(' ')[0],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context,
    UserModel user,
    String lastMessage,
    Timestamp? lastMessageTime,
    bool isDark,
  ) {
    String timeAgo = '';
    if (lastMessageTime != null) {
      final diff = DateTime.now().difference(lastMessageTime.toDate());
      if (diff.inMinutes < 60) {
        timeAgo = '${diff.inMinutes}m';
      } else if (diff.inHours < 24) {
        timeAgo = '${diff.inHours}h';
      } else {
        timeAgo = '${diff.inDays}d';
      }
    }

    return InkWell(
      onTap: () => _openChat(context, user),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: ImageHelper.getImageProvider(user.avatarUrl),
                ),
                if (user.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.black : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Name and Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage.isEmpty ? 'Tap to start chatting' : lastMessage,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeAgo.isNotEmpty) ...[
                        Text(
                          ' · $timeAgo',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppTheme.facebookBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with your friends',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showNewChatDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.facebookBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Start a chat'),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, UserModel otherUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(otherUser: otherUser),
      ),
    );
  }

  void _showNewChatDialog() async {
    final users = await _userService.getAllUsers();
    if (!mounted) return;

    final currentUser = currentUserProvider.currentUserOrDefault;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'New Message',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                if (user.id == currentUser.id) return const SizedBox.shrink();
                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: ImageHelper.getImageProvider(user.avatarUrl),
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openChat(context, user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
