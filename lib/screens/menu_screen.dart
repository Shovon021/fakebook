import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/current_user_provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'groups_screen.dart';
import 'login_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Expansion state for the "See more" shortcuts (optional, but requested implicitly by "See more" pattern)
  bool _showAllShortcuts = false;

  final List<Map<String, dynamic>> _allShortcuts = [
    {'icon': Icons.bookmark, 'label': 'Saved', 'color': Colors.purple},
    {'icon': Icons.group, 'label': 'Groups', 'color': AppTheme.facebookBlue},
    {'icon': Icons.ondemand_video, 'label': 'Video', 'color': Colors.blue},
    {'icon': Icons.storefront, 'label': 'Marketplace', 'color': Colors.blueAccent},
    {'icon': Icons.people, 'label': 'Friends', 'color': Colors.blue},
    {'icon': Icons.history, 'label': 'Memories', 'color': Colors.blue},
    {'icon': Icons.event, 'label': 'Events', 'color': Colors.red},
    {'icon': Icons.games, 'label': 'Gaming', 'color': Colors.blue},
    {'icon': Icons.flag, 'label': 'Pages', 'color': Colors.orange},
    {'icon': Icons.campaign, 'label': 'Ad Center', 'color': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = currentUserProvider.currentUserOrDefault;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                  Row(
                    children: [
                      _buildHeaderButton(Icons.settings, isDark),
                      const SizedBox(width: 12),
                      _buildHeaderButton(Icons.search, isDark),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // PROFILE CARD
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(user: currentUser),
                    ),
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: CachedNetworkImageProvider(currentUser.avatarUrl),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.black,
                          ),
                        ),
                        Text(
                          'See your profile',
                          style: TextStyle(
                            color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // SHORTCUTS LABEL
              Text(
                'All shortcuts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.black,
                ),
              ),
              const SizedBox(height: 12),

              // GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.5, // Wider cards
                ),
                itemCount: _showAllShortcuts ? _allShortcuts.length : 8,
                itemBuilder: (context, index) {
                  // If not expanded and this is the last item (index 7), show "See more"
                  if (!_showAllShortcuts && index == 7) {
                    return _buildSeeMoreButton(isDark, true);
                  }
                  // If expanded and this is the last item, show "See less"
                  if (_showAllShortcuts && index == _allShortcuts.length - 1) {
                    // Logic issue: if we just append "See less", length needs to be +1. 
                    // Let's simplify: Standard button in list.
                  }
                  
                  final item = _allShortcuts[index];
                  return _buildShortcutCard(
                    icon: item['icon'],
                    label: item['label'],
                    color: item['color'],
                    isDark: isDark,
                  );
                },
              ),
              if (_showAllShortcuts)
                 Padding(
                   padding: const EdgeInsets.only(top: 8),
                   child: _buildSeeMoreButton(isDark, false),
                 ),

              const SizedBox(height: 24),
              
              // ACCORDIONS
              _buildExpansionTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                isDark: isDark,
                children: [
                   _buildSubMenuItem('Help Center', Icons.support, isDark),
                   _buildSubMenuItem('Support Inbox', Icons.mail_outline, isDark),
                   _buildSubMenuItem('Report a problem', Icons.warning_amber, isDark),
                ],
              ),
              _buildExpansionTile(
                icon: Icons.settings,
                title: 'Settings & Privacy',
                isDark: isDark,
                children: [
                   _buildSubMenuItem('Settings', Icons.person, isDark),
                   _buildSubMenuItem('Device requests', Icons.perm_device_information, isDark),
                   _buildSubMenuItem('Recent ad activity', Icons.history, isDark),
                ],
              ),
              _buildExpansionTile(
                icon: Icons.grid_view,
                title: 'Also from Meta',
                isDark: isDark,
                children: [
                   _buildSubMenuItem('WhatsApp', Icons.chat, isDark),
                   _buildSubMenuItem('Threads', Icons.alternate_email, isDark),
                ],
              ),

              const SizedBox(height: 24),
              // Log Out
               Container(
                 width: double.infinity,
                 decoration: BoxDecoration(
                   color: isDark ? const Color(0xFF242526) : Colors.white,
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: isDark ? Colors.transparent : Colors.grey[300]!),
                 ),
                 child: TextButton(
                   onPressed: () {}, 
                   child: Text(
                     'Log Out', 
                     style: TextStyle(
                       color: isDark ? Colors.white : Colors.black,
                       fontSize: 16,
                     ),
                   ),
                 ),
               ),
               const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(), // Remove default borders
          leading: Icon(icon, color: isDark ? const Color(0xFFB0B3B8) : Colors.purple, size: 28),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.black,
            ),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(String title, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.black54),
        title: Text(
          title, 
          style: TextStyle(
            fontSize: 14, 
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: isDark ? Colors.white : Colors.black),
    );
  }

  Widget _buildShortcutCard({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
             blurRadius: 4,
             offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (label == 'Groups') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GroupsScreen()),
              );
            } else {
              // Other shortcuts...
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Icon(icon, color: color, size: 28),
                 const Spacer(),
                 Text(
                   label,
                   style: TextStyle(
                     fontWeight: FontWeight.w600,
                     fontSize: 14,
                     color: isDark ? Colors.white : Colors.black,
                   ),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeeMoreButton(bool isDark, bool expand) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _showAllShortcuts = expand;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              expand ? 'See more' : 'See less',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
