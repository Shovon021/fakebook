import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../providers/current_user_provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final UserService _userService = UserService();
  List<UserModel> _suggestions = [];
  // bool _isLoading = true; // Not keeping full screen loading for suggestions

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final users = await _userService.getAllUsers();
    // In a real app, filter out existing friends
    if (mounted) {
      setState(() {
        _suggestions = users;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = currentUserProvider.currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Friends',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search,
                    color: isDark ? Colors.white : AppTheme.black,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTab('Suggestions', true, isDark),
                const SizedBox(width: 8),
                _buildTab('Your Friends', false, isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Friend Requests Stream
          if (currentUser != null)
            StreamBuilder<QuerySnapshot>(
              stream: _userService.getFriendRequestsStream(currentUser.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();

                final requests = snapshot.data!.docs;
                
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Friend Requests',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppTheme.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${requests.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'See All',
                              style: TextStyle(color: AppTheme.facebookBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final reqDoc = requests[index];
                        final fromUserId = reqDoc['from'];
                        
                        return FutureBuilder<UserModel?>(
                          future: _userService.getUserById(fromUserId),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) return const SizedBox.shrink();
                            return _buildFriendRequestCard(userSnapshot.data!, reqDoc.id, isDark);
                          },
                        );
                      },
                    ),
                    Divider(
                      height: 32,
                      thickness: 8,
                      color: isDark ? const Color(0xFF18191A) : AppTheme.lightGrey,
                    ),
                  ],
                );
              },
            ),

          // People You May Know
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'People You May Know',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.black,
              ),
            ),
          ),
          ..._suggestions.map(
            (user) => _buildSuggestionCard(user, isDark),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive 
            ? AppTheme.facebookBlue.withValues(alpha: 0.15)
            : (isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive 
              ? AppTheme.facebookBlue 
              : (isDark ? Colors.white : AppTheme.black),
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildFriendRequestCard(UserModel user, String requestId, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 44,
            backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppTheme.black,
                      ),
                    ),
                    Text(
                      'Anytime', // Placeholder timestamp
                      style: TextStyle(
                        color: isDark 
                            ? const Color(0xFFB0B3B8) 
                            : AppTheme.mediumGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Mutual friends avatars stack
                    SizedBox(
                      width: 40,
                      height: 20,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundImage: const CachedNetworkImageProvider(
                              'https://picsum.photos/seed/mutual1/50/50',
                            ),
                          ),
                          Positioned(
                            left: 12,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF242526) : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundImage: CachedNetworkImageProvider(
                                  'https://picsum.photos/seed/mutual2/50/50',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user.friendsCount} mutual friends',
                      style: TextStyle(
                        color: isDark 
                            ? const Color(0xFFB0B3B8) 
                            : AppTheme.mediumGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final currentUser = currentUserProvider.currentUser;
                          if (currentUser != null) {
                            await _userService.acceptFriendRequest(requestId, user.id, currentUser.id);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.facebookBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle Delete
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark 
                              ? const Color(0xFF3A3B3C) 
                              : AppTheme.lightGrey,
                          foregroundColor: isDark ? Colors.white : AppTheme.black,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
  Widget _buildSuggestionCard(UserModel user, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 44,
            backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppTheme.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Mutual friends avatars stack
                    SizedBox(
                      width: 40,
                      height: 20,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundImage: const CachedNetworkImageProvider(
                              'https://picsum.photos/seed/mutual3/50/50',
                            ),
                          ),
                          Positioned(
                            left: 12,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF242526) : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundImage: CachedNetworkImageProvider(
                                  'https://picsum.photos/seed/mutual4/50/50',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user.friendsCount} mutual friends',
                      style: TextStyle(
                        color: isDark 
                            ? const Color(0xFFB0B3B8) 
                            : AppTheme.mediumGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.facebookBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add Friend',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark 
                              ? const Color(0xFF3A3B3C) 
                              : AppTheme.lightGrey,
                          foregroundColor: isDark ? Colors.white : AppTheme.black,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Remove',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
