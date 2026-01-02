import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  final UserModel currentUser;

  const CreatePostScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isPostButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isPostButtonEnabled = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18191A) : Colors.white,
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.black,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton(
              onPressed: _isPostButtonEnabled
                  ? () {
                      // Logic to post would go here
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPostButtonEnabled
                    ? AppTheme.facebookBlue
                    : (isDark ? const Color(0xFF4E4F50) : const Color(0xFFE4E6EB)),
                foregroundColor: _isPostButtonEnabled
                    ? Colors.white
                    : (isDark ? const Color(0xFFAAB0B8) : const Color(0xFFBCC0C4)),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Post',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // User Info & Privacy
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: CachedNetworkImageProvider(
                          widget.currentUser.avatarUrl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentUser.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.black,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[400]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.public,
                                  size: 12,
                                  color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Public',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 14,
                                  color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Text Field
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: TextStyle(
                        fontSize: 24,
                        color: isDark ? const Color(0xFFB0B3B8) : Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 24,
                      color: isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Sliding Panel (Simplified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242526) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[300]!,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildActionRow(Icons.photo_library, Colors.green, "Photo/video", isDark),
                const SizedBox(height: 12),
                _buildActionRow(Icons.person_add, AppTheme.facebookBlue, "Tag people", isDark),
                const SizedBox(height: 12),
                _buildActionRow(Icons.emoji_emotions, Colors.orange, "Feeling/activity", isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, Color iconColor, String label, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : AppTheme.black,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
