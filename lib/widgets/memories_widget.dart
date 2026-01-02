import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

class MemoriesWidget extends StatelessWidget {
  const MemoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      color: isDark ? const Color(0xFF242526) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Memories',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppTheme.black,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.more_horiz,
                color: isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF6A94F5), Color(0xFF4267B2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.access_time_filled, color: Colors.white, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'On This Day',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '1 year ago',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'See what you were doing regarding your trip to Japan.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Transform.rotate(
                         angle: 0.1,
                         child: CachedNetworkImage(
                          imageUrl: 'https://picsum.photos/seed/japan/300/300',
                          fit: BoxFit.cover,
                          height: 140,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
