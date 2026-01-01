import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                index: 0,
                label: 'Home',
              ),
              _buildNavItem(
                context: context,
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                index: 1,
                label: 'Friends',
              ),
              _buildNavItem(
                context: context,
                icon: Icons.ondemand_video_outlined,
                activeIcon: Icons.ondemand_video,
                index: 2,
                label: 'Watch',
              ),
              _buildNavItem(
                context: context,
                icon: Icons.storefront_outlined,
                activeIcon: Icons.storefront,
                index: 3,
                label: 'Marketplace',
              ),
              _buildNavItem(
                context: context,
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                index: 4,
                label: 'Notifications',
                badge: 3,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.menu,
                activeIcon: Icons.menu,
                index: 5,
                label: 'Menu',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required String label,
    int badge = 0,
  }) {
    final isSelected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.facebookBlue.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 26,
                  color: isSelected 
                      ? AppTheme.facebookBlue 
                      : (isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey),
                ),
              ),
              if (badge > 0)
                Positioned(
                  right: 8,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      badge.toString(),
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
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 28,
              decoration: BoxDecoration(
                color: AppTheme.facebookBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
