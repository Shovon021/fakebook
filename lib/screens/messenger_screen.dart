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
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: ImageHelper.getImageProvider(currentUser.avatarUrl),
            ),
            const SizedBox(width: 12),
            Text(
              'Chats',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.edit, color: isDark ? Colors.white : Colors.black),
            onPressed: () => _showNewChatDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2B2C) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: isDark ? Colors.grey : Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Search',
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Active Now - Show all users
            FutureBuilder<List<UserModel>>(
              future: _userService.getAllUsers(),
              builder: (context, snapshot) {
                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      if (user.id == currentUser.id) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: () => _openChat(context, user),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: ImageHelper.getImageProvider(user.avatarUrl),
                                  ),
                                  if (user.isOnline)
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
                              const SizedBox(height: 4),
                              Text(
                                user.name.split(' ')[0],
                                style: TextStyle(
                                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Chat List - Real chat rooms
            StreamBuilder<QuerySnapshot>(
              stream: _messengerService.getChatRoomsStream(currentUser.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chatRooms = snapshot.data?.docs ?? [];

                if (chatRooms.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No chats yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation by tapping the edit icon',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
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
    );
  }

  Widget _buildChatTile(BuildContext context, UserModel user, String lastMessage, bool isDark) {
    return GestureDetector(
      onTap: () => _openChat(context, user),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: ImageHelper.getImageProvider(user.avatarUrl),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 2),
                  Text(
                    lastMessage.isEmpty ? 'Tap to start chatting' : lastMessage,
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
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

  void _showNewChatDialog(BuildContext context) async {
    final users = await _userService.getAllUsers();
    final currentUser = currentUserProvider.currentUserOrDefault;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          if (user.id == currentUser.id) return const SizedBox.shrink();
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: ImageHelper.getImageProvider(user.avatarUrl),
            ),
            title: Text(user.name),
            onTap: () {
              Navigator.pop(context);
              _openChat(context, user);
            },
          );
        },
      ),
    );
  }
}
