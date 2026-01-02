import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'friends_screen.dart';
import 'watch_screen.dart';
import 'marketplace_screen.dart';
import 'notifications_screen.dart';
import 'menu_screen.dart';
import 'search_screen.dart';
import 'messenger_screen.dart';
import '../utils/slide_page_route.dart';

class NavScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const NavScreen({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<IconData> _tabIcons = [
    Icons.home_outlined,
    Icons.people_outline,
    Icons.ondemand_video_outlined,
    Icons.storefront_outlined,
    Icons.notifications_outlined,
    Icons.menu,
  ];

  final List<IconData> _tabIconsActive = [
    Icons.home,
    Icons.people,
    Icons.ondemand_video,
    Icons.storefront,
    Icons.notifications,
    Icons.menu,
  ];

  // Badge counts for tabs: Index -> Count
  final Map<int, int> _badgeCounts = {
    1: 9,  // Friends
    2: 5,  // Watch
    3: 2,  // Marketplace
    4: 7,  // Notifications
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
          // Clear badge when tab is selected
          if (_badgeCounts.containsKey(_currentIndex)) {
            _badgeCounts.remove(_currentIndex);
          }
        });
        HapticFeedback.selectionClick();
      }
    });
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
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            // Facebook Logo Text
            Text(
              'fakebook',
              style: TextStyle(
                color: AppTheme.facebookBlue,
                fontWeight: FontWeight.bold,
                fontSize: 26,
                letterSpacing: -1.2,
              ),
            ),
          ],
        ),
        actions: [
          // Add/Plus button
          _buildHeaderIconButton(
            icon: Icons.add,
            isDark: isDark,
            onTap: () => _showCreateMenu(context, isDark),
          ),
          // Search button
          _buildHeaderIconButton(
            icon: Icons.search,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const SearchScreen()),
              );
            },
          ),
          // Messenger button
          _buildHeaderIconButton(
            icon: Icons.chat_bubble,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const MessengerScreen()),
              );
            },
            badgeCount: 2,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.facebookBlue,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: EdgeInsets.zero,
              dividerColor: Colors.transparent,
              onTap: (index) {
                setState(() {
                  _badgeCounts.remove(index);
                });
              },
              tabs: List.generate(6, (index) {
                final isSelected = _currentIndex == index;
                final badgeCount = _badgeCounts[index] ?? 0;
                
                return Tab(
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          isSelected ? _tabIconsActive[index] : _tabIcons[index],
                          size: 26,
                          color: isSelected 
                              ? AppTheme.facebookBlue 
                              : (isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey),
                        ),
                        // Badge
                        if (badgeCount > 0)
                          Positioned(
                            right: isSelected ? 30 : 25, // Adjust based on icon position
                            top: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Center(
                                child: Text(
                                  badgeCount > 9 ? '9+' : badgeCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomeScreenContent(),
          FriendsScreen(),
          WatchScreen(),
          MarketplaceScreen(),
          NotificationsScreen(),
          MenuScreen(),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        children: [
          Material(
            color: isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 22,
                  color: isDark ? Colors.white : AppTheme.black,
                ),
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCreateMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Create',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildCreateOption(
              context,
              icon: Icons.article,
              color: Colors.green,
              title: 'Post',
              subtitle: 'Share what\'s on your mind',
              onTap: () {
                Navigator.pop(context);
                // Navigate to create post
              },
            ),
            _buildCreateOption(
              context,
              icon: Icons.auto_stories,
              color: AppTheme.facebookBlue,
              title: 'Story',
              subtitle: 'Share a photo or video',
              onTap: () {
                Navigator.pop(context);
                // Navigate to create story
              },
            ),
            _buildCreateOption(
              context,
              icon: Icons.video_library,
              color: Colors.red,
              title: 'Reel',
              subtitle: 'Create a short video',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildCreateOption(
              context,
              icon: Icons.videocam,
              color: Colors.purple,
              title: 'Live Video',
              subtitle: 'Start a live broadcast',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600),
      ),
      onTap: onTap,
    );
  }
}
