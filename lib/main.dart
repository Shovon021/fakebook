import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/watch_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/search_screen.dart';
import 'screens/messenger_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const FakebookApp());
}

class FakebookApp extends StatefulWidget {
  const FakebookApp({super.key});

  @override
  State<FakebookApp> createState() => _FakebookAppState();
}

class _FakebookAppState extends State<FakebookApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light 
          ? ThemeMode.dark 
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facebook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: MainScreen(onThemeToggle: _toggleTheme),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const MainScreen({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
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
  Map<int, int> _badgeCounts = {
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
            onTap: () {},
          ),
          // Search button
          _buildHeaderIconButton(
            icon: Icons.search,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
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
                MaterialPageRoute(builder: (context) => const MessengerScreen()),
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
}
