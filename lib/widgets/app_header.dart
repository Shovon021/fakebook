import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onMessengerTap;

  const AppHeader({
    super.key,
    this.onSearchTap,
    this.onMessengerTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      title: const Text(
        'fakebook',
        style: TextStyle(
          color: AppTheme.facebookBlue,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          letterSpacing: -1,
        ),
      ),
      actions: [
        _buildIconButton(
          icon: Icons.search,
          onTap: onSearchTap ?? () {},
          isDark: isDark,
        ),
        _buildIconButton(
          icon: Icons.chat_bubble,
          onTap: onMessengerTap ?? () {},
          isDark: isDark,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 22,
              color: isDark ? Colors.white : AppTheme.black,
            ),
          ),
        ),
      ),
    );
  }
}
