import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/post_card.dart';
import '../utils/image_helper.dart';
import 'edit_profile_screen.dart';
import 'create_story_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Posts', 'Photos', 'Reels'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
              title: Text(
                widget.user.name,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: false,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(isDark),
                const Divider(height: 20, thickness: 1),
                if (widget.user.details.isNotEmpty) _buildDetailsSection(isDark),
                if (widget.user.details.isNotEmpty) const Divider(height: 20, thickness: 1),
                _buildFriendsList(context, isDark),
              ]),
            ),
          ];
        },
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF18191A) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF3A3B3C) : const Color(0xFFCCCDD2),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.facebookBlue,
                labelColor: AppTheme.facebookBlue,
                unselectedLabelColor: isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B),
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostsTab(context, isDark),
                  _buildPhotosTab(context, isDark),
                  const Center(child: Text('Reels Content')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
             Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: ImageHelper.getNetworkImage(
                imageUrl: 'https://images.unsplash.com/photo-1596486095368-f9e4f50998d8?q=80&w=2070&auto=format&fit=crop', // Brick wall/abstract cover
                fit: BoxFit.cover,
               // placeholder: (context, url) => Container(color: Colors.grey[300]), // ImageHelper handles this
              ),
             ),
             Positioned(
               bottom: -60,
               child: Container(
                 padding: const EdgeInsets.all(4),
                 decoration: BoxDecoration(
                   color: isDark ? const Color(0xFF242526) : Colors.white,
                   shape: BoxShape.circle,
                 ),
                 child: CircleAvatar(
                   radius: 70,
                   backgroundImage: ImageHelper.getImageProvider(widget.user.avatarUrl),
                 ),
               ),
             ),
          ],
        ),
        const SizedBox(height: 70),
        Text(
          widget.user.name,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.black,
          ),
        ),
        if (widget.user.bio != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 32),
            child: Text(
              widget.user.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey,
              ),
            ),
          ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text('Add to Story'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.facebookBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditProfileScreen(user: widget.user)),
                      );
                    },
                    icon: Icon(Icons.edit, color: isDark ? Colors.white : Colors.black, size: 18),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF3A3B3C) : const Color(0xFFE4E6EB),
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3A3B3C) : const Color(0xFFE4E6EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.more_horiz, color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection(bool isDark) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.black,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.user.details.map((detail) {
              IconData icon = Icons.info_outline;
              if (detail.contains('Works') || detail.contains('Assistant') || detail.contains('Member')) {
                icon = Icons.work;
              } else if (detail.contains('Studied') || detail.contains('School') || detail.contains('College')) {
                icon = Icons.school;
              } else if (detail.contains('Lives') || detail.contains('From')) {
                icon = Icons.home;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        detail,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : AppTheme.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF3A3B3C).withValues(alpha: 0.5) : const Color(0xFFE7F3FF),
                  foregroundColor: AppTheme.facebookBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Edit public details'),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildFriendsList(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                    '${widget.user.friendsCount} friends',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey,
                    ),
                  ),
                ],
              ),
              Text(
                'Find Friends',
                style: TextStyle(
                  color: AppTheme.facebookBlue,
                  fontSize: 16,
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
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 9, // Demo count
            itemBuilder: (context, index) {
              final friend = DummyData.users[index % DummyData.users.length];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ImageHelper.getNetworkImage(
                        imageUrl: friend.avatarUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    friend.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : AppTheme.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               onPressed: () {}, 
               style: ElevatedButton.styleFrom(
                 backgroundColor: isDark ? const Color(0xFF3A3B3C) : const Color(0xFFE4E6EB),
                 elevation: 0,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
               ),
               child: Text(
                 'See All Friends',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
               ),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildUserPosts(isDark),
        ],
      ),
    );
  }

  Widget _buildPhotosTab(BuildContext context, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
            image: ImageHelper.getImageProvider('https://picsum.photos/seed/photo$index/400/400'),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserPosts(bool isDark) {
    // If viewing Current User, show all posts where author is currentUser
    // If viewing another user (e.g. from search), show their posts
    final userPosts = DummyData.posts.where((p) => p.author.id == widget.user.id).toList();
    
    // Fallback: If no specific posts for this user in DummyData, show a generic one or empty
    if (userPosts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text('No posts yet', style: TextStyle(color: isDark ? Colors.grey : Colors.black)),
      );
    }

    return Column(
      children: userPosts.map((post) => Column(
        children: [
          PostCard(post: post),
          Container(height: 8, color: isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5)),
        ],
      )).toList(),
    );
  }
}
