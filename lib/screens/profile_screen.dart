import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_widget.dart';

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
  final List<String> _tabs = ['Posts', 'Photos', 'Reels', 'Life Events'];

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
                  fontSize: 16, // FB style is smaller title in pinned appbar
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: ColoredBox(
                color: isDark ? const Color(0xFF242526) : Colors.white,
                child: Column(
                  children: [
                    _buildProfileHeader(context, isDark),
                    const Divider(height: 1),
                    _buildInfoSection(isDark),
                    const Divider(height: 1),
                    _buildFriendsList(context, isDark),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _StickyTabBarDelegate(
                child: Container(
                  color: isDark ? const Color(0xFF242526) : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.facebookBlue,
                    unselectedLabelColor: isDark ? Colors.grey : Colors.grey[600],
                    indicatorColor: AppTheme.facebookBlue,
                    indicatorWeight: 3,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                    isScrollable: true, 
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  ),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Posts Tab
            _buildPostsTab(isDark),
            // Photos Tab (Placeholder)
            Center(child: Text('Photos', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
             // Reels Tab (Placeholder)
            Center(child: Text('Reels', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
             // Life Events Tab (Placeholder)
            Center(child: Text('Life Events', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                CreatePostWidget(currentUser: widget.user),
                _buildDivider(isDark),
                _buildUserPosts(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Cover Photo
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: CachedNetworkImage(
                imageUrl: 'https://picsum.photos/seed/cover${widget.user.id}/800/400',
                fit: BoxFit.cover,
                 placeholder: (context, url) => Container(color: Colors.grey[300]),
              ),
            ),
            // Camera Icon for Cover
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
            // Profile Picture
            Positioned(
              bottom: -60,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF242526) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: CachedNetworkImageProvider(widget.user.avatarUrl),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
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
            ),
          ],
        ),
        const SizedBox(height: 70),
        // Name and Bio
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
        
        // Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: ElevatedButton.icon(
                  onPressed: () {},
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
                  onPressed: () {},
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
          // 3x3 Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 9, // Showing 9 friends
            itemBuilder: (context, index) {
              // Cycle through users for demo
              final friend = DummyData.users[index % DummyData.users.length];
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

  Widget _buildInfoSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow(Icons.work, 'Works at Flutter Developer', isDark),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.school, 'Studied at Tech University', isDark),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.home, 'Lives in San Francisco, CA', isDark),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on, 'From New York, NY', isDark),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.rss_feed, 'Followed by 1,234 people', isDark),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.more_horiz, 'See your About Info', isDark),
          const SizedBox(height: 16),
          SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               onPressed: () {}, 
               style: ElevatedButton.styleFrom(
                 backgroundColor: const Color(0xFFE7F3FF),
                 elevation: 0,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
               ),
               child: Text(
                 'Edit Public Details',
                  style: TextStyle(
                    color: AppTheme.facebookBlue,
                    fontWeight: FontWeight.bold,
                  ),
               ),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600], size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : AppTheme.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserPosts(bool isDark) {
    final userPosts = DummyData.posts.where((p) => p.author.id == widget.user.id).toList();
    
    return Column(
      children: userPosts.map((post) => Column(
        children: [
           // We need to remove the top/bottom spacing from post card for better list feel
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

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 48.0;

  @override
  double get minExtent => 48.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
