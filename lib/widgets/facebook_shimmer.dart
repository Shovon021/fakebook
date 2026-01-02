import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreenShimmer extends StatelessWidget {
  const HomeScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StoryFeedShimmer(isDark: isDark),
        _buildDivider(isDark),
        _CreatePostShimmer(isDark: isDark),
         _buildDivider(isDark),
        LoadingPostShimmer(isDark: isDark),
        _buildDivider(isDark),
        LoadingPostShimmer(isDark: isDark),
      ],
    );
  }
  
  Widget _buildDivider(bool isDark) {
    return Container(
      height: 8,
      color: isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5),
    );
  }
}

class _StoryFeedShimmer extends StatelessWidget {
  final bool isDark;

  const _StoryFeedShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? const Color(0xFF3A3B3C) : Colors.grey[300]!;
    final highlightColor = isDark ? const Color(0xFF4E4F50) : Colors.grey[100]!;

    return Container(
      height: 200,
      color: isDark ? const Color(0xFF242526) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              width: 110,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white, // This is the color that will shimmer
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CreatePostShimmer extends StatelessWidget {
  final bool isDark;
  
  const _CreatePostShimmer({required this.isDark});
  
  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? const Color(0xFF3A3B3C) : Colors.grey[300]!;
    final highlightColor = isDark ? const Color(0xFF4E4F50) : Colors.grey[100]!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      color: isDark ? const Color(0xFF242526) : Colors.white,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Row(
          children: [
             const CircleAvatar(radius: 20, backgroundColor: Colors.white),
             const SizedBox(width: 12),
             Expanded(
               child: Container(
                 height: 36,
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(20),
                 ),
               ),
             ),
             const SizedBox(width: 12),
             const Icon(Icons.photo_library, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// Renamed from LoadingPostShimmer but kept compatible name for easier refactor if needed, 
// though we usually just use HomeScreenShimmer now.
class LoadingPostShimmer extends StatelessWidget {
  final bool? isDark; // Optional, can derive from context if null

  const LoadingPostShimmer({super.key, this.isDark});

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    final baseColor = dark ? const Color(0xFF3A3B3C) : Colors.grey[300]!;
    final highlightColor = dark ? const Color(0xFF4E4F50) : Colors.grey[100]!;

    return Container(
      color: dark ? const Color(0xFF242526) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Text lines
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 200,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Image placeholder
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 60, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  Container(width: 60, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  Container(width: 60, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
