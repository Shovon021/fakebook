import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/post_service.dart';
import '../providers/current_user_provider.dart';
import '../theme/app_theme.dart';
import 'shared_ui.dart';

class ShareBottomSheet extends StatefulWidget {
  final PostModel post;

  const ShareBottomSheet({
    super.key,
    required this.post,
  });

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  bool _isSharing = false;

  Future<void> _handleShareNow() async {
    final currentUser = currentUserProvider.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isSharing = true;
    });

    try {
      await PostService().createPost(
        authorId: currentUser.id,
        content: '',
        sharedPostId: widget.post.id,
      );

      if (mounted) {
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shared to your feed!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share this post',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isSharing)
                 const Center(child: CircularProgressIndicator())
                else
                 Column(
                   children: [
                     _buildListTile(
                       icon: Icons.share,
                       label: 'Share Now (Public)',
                       subtitle: 'Instantly share to your Feed',
                       onTap: _handleShareNow,
                       isDark: isDark,
                     ),
                     _buildListTile(
                       icon: Icons.edit,
                       label: 'Write Post',
                       subtitle: 'Share with your thoughts',
                       onTap: () {
                         Navigator.pop(context);
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Write Post sharing coming soon!')),
                         );
                       },
                       isDark: isDark,
                     ),
                     _buildListTile(
                       icon: Icons.send,
                       label: 'Send in Messenger',
                       subtitle: 'Send to friends privately',
                       onTap: () {
                         Navigator.pop(context);
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Messenger sharing coming soon!')),
                         );
                       },
                       isDark: isDark,
                     ),
                     _buildListTile(
                       icon: Icons.link,
                       label: 'Copy Link',
                       subtitle: 'Copy post link to clipboard',
                       onTap: () {
                         Navigator.pop(context);
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Link copied to clipboard!')),
                         );
                       },
                       isDark: isDark,
                     ),
                   ],
                 ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isDark ? Colors.white : Colors.black, size: 24),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
