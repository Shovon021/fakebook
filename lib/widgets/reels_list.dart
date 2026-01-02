import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/reel_model.dart';
import '../theme/app_theme.dart';

class ReelsList extends StatelessWidget {
  final List<ReelModel> reels;

  const ReelsList({
    super.key,
    required this.reels,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 280,
      color: isDark ? const Color(0xFF242526) : Colors.white,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.pink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.movie_creation,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Reels and short videos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
          // Horizontal List
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: reels.length,
              itemBuilder: (context, index) {
                return _buildReelCard(reels[index], isDark);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildReelCard(ReelModel reel, bool isDark) {
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail
            CachedNetworkImage(
              imageUrl: reel.thumbUrl,
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.5, 0.8, 1.0],
                ),
              ),
            ),
            // Views Count
            Positioned(
              left: 8,
              bottom: 8,
              child: Row(
                children: [
                  const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatViews(reel.viewsCount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // User Avatar (Optional - can be added to top left)
          ],
        ),
      ),
    );
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(0)}k';
    }
    return views.toString();
  }
}
