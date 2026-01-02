import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../screens/create_post_screen.dart';
import '../screens/profile_screen.dart';
import '../utils/image_helper.dart';

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
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : Colors.white,
        boxShadow: isDark ? null : AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(user: currentUser),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: ImageHelper.getImageProvider(
                    currentUser.avatarUrl,
                  ),
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
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3B3C) : const Color(0xFFF0F2F5), // Filled style like FB
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "What's on your mind?",
                      style: TextStyle(
                        color: isDark 
                            ? const Color(0xFFB0B3B8) 
                            : const Color(0xFF65676B),
                        fontSize: 16,
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
            color: isDark ? const Color(0xFF3E4042) : const Color(0xFFCED0D4),
            thickness: 0.5,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.video_call,
                  label: 'Live',
                  color: const Color(0xFFF3425F), // FB Live Red
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.photo_library,
                  label: 'Photo',
                  color: const Color(0xFF45BD62), // FB Green
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.video_camera_back, // Room/Reel icon
                  label: 'Room',
                  color: const Color(0xFF9360F7), // FB Purple
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
