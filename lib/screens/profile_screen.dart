import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_widget.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;

  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          user.name,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
        leading: BackButton(
          color: isDark ? Colors.white : AppTheme.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, isDark),
            _buildDivider(isDark),
            _buildFriendsList(context, isDark),
            _buildDivider(isDark),
            _buildInfoSection(isDark),
            _buildDivider(isDark),
            CreatePostWidget(currentUser: user),
            _buildDivider(isDark),
            _buildUserPosts(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF242526) : Colors.white,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Cover Photo
              Container(
                height: 200,
                color: Colors.grey[300],
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: 'https://picsum.photos/seed/cover${user.id}/800/400',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[300]),
                  errorWidget: (context, url, error) => const Icon(Icons.image),
                ),
              ),
              // Profile Picture
              Positioned(
                bottom: -50,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF242526) : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
                  ),
                ),
              ),
              // Camera Icon for Cover
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE4E6EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          // Name and Bio
          Text(
            user.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.black,
            ),
          ),
          if (user.bio != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                user.bio!,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey,
                ),
              ),
            ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle, color: Colors.white, size: 18),
                    label: const Text('Add to Story'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.facebookBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.edit, color: isDark ? Colors.white : Colors.black, size: 18),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey,
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.more_horiz, color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFriendsList(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF242526) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Friends',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                  Text(
                    '${user.friendsCount} friends',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey,
                    ),
                  ),
                ],
              ),
              Text(
                'Find Friends',
                style: TextStyle(
                  color: AppTheme.facebookBlue,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              final friend = DummyData.users[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: friend.avatarUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    friend.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : AppTheme.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF242526) : Colors.white,
      child: Column(
        children: [
          _buildInfoRow(Icons.work, 'Works at Flutter Developer', isDark),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.school, 'Studied at Tech University', isDark),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.home, 'Lives in San Francisco, CA', isDark),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'From New York, NY', isDark),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.more_horiz, 'See your About Info', isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white : AppTheme.black,
          ),
        ),
      ],
    );
  }

  Widget _buildUserPosts(bool isDark) {
    final userPosts = DummyData.posts.where((p) => p.author.id == user.id).toList();
    
    return Column(
      children: userPosts.map((post) => Column(
        children: [
          PostCard(post: post),
          _buildDivider(isDark),
        ],
      )).toList(),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 8,
      color: isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5),
    );
  }
}
