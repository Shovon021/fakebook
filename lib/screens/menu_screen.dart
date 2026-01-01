import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = DummyData.currentUser;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menu',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.black,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings,
                      color: isDark ? Colors.white : AppTheme.black,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
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
            ],
          ),
          const SizedBox(height: 20),
          // Profile card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242526) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: CachedNetworkImageProvider(
                          currentUser.avatarUrl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: isDark ? Colors.white : AppTheme.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'See your profile',
                              style: TextStyle(
                                color: isDark 
                                    ? const Color(0xFFB0B3B8) 
                                    : AppTheme.mediumGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isDark 
                            ? const Color(0xFFB0B3B8) 
                            : AppTheme.mediumGrey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Divider(
                  color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[300],
                  height: 1,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.switch_account,
                          color: isDark 
                              ? const Color(0xFFB0B3B8) 
                              : AppTheme.mediumGrey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Switch profiles',
                        style: TextStyle(
                          color: isDark 
                              ? const Color(0xFFB0B3B8) 
                              : AppTheme.mediumGrey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Shortcuts grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _buildShortcutCard(
                icon: Icons.bookmark,
                label: 'Saved',
                color: Colors.purple,
                isDark: isDark,
              ),
              _buildShortcutCard(
                icon: Icons.group,
                label: 'Groups',
                color: AppTheme.facebookBlue,
                isDark: isDark,
              ),
              _buildShortcutCard(
                icon: Icons.ondemand_video,
                label: 'Reels',
                color: Colors.pink,
                isDark: isDark,
              ),
              _buildShortcutCard(
                icon: Icons.history,
                label: 'Memories',
                color: Colors.teal,
                isDark: isDark,
              ),
              _buildShortcutCard(
                icon: Icons.event,
                label: 'Events',
                color: Colors.red,
                isDark: isDark,
              ),
              _buildShortcutCard(
                icon: Icons.flag,
                label: 'Pages',
                color: Colors.orange,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // More options
          _buildMenuItem(Icons.help_outline, 'Help & Support', isDark),
          _buildMenuItem(Icons.settings, 'Settings & Privacy', isDark),
          _buildMenuItem(Icons.dark_mode, 'Dark Mode', isDark),
          _buildMenuItem(Icons.logout, 'Log Out', isDark),
          const SizedBox(height: 32),
          // Meta info
          Center(
            child: Column(
              children: [
                Text(
                  'facebook',
                  style: TextStyle(
                    color: AppTheme.facebookBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'from Meta',
                  style: TextStyle(
                    color: isDark 
                        ? const Color(0xFFB0B3B8) 
                        : AppTheme.mediumGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(10),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.white : AppTheme.black,
                size: 22,
              ),
            ),
            title: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.black,
                fontSize: 15,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey,
            ),
          ),
        ),
      ),
    );
  }
}
