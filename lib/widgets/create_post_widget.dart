import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../screens/create_post_screen.dart';

class CreatePostWidget extends StatelessWidget {
  final UserModel currentUser;
  final VoidCallback? onTap;

  const CreatePostWidget({
    super.key,
    required this.currentUser,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: isDark ? const Color(0xFF242526) : Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: CachedNetworkImageProvider(
                  currentUser.avatarUrl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostScreen(currentUser: currentUser),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark 
                            ? const Color(0xFF3A3B3C) 
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      "What's on your mind?",
                      style: TextStyle(
                        color: isDark 
                            ? const Color(0xFFB0B3B8) 
                            : AppTheme.mediumGrey,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade200,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.video_call,
                  label: 'Live',
                  color: Colors.red,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade300,
              ),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.photo_library,
                  label: 'Photo',
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade300,
              ),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.videocam,
                  label: 'Room',
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
