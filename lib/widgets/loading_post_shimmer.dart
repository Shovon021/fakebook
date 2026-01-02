import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingPostShimmer extends StatelessWidget {
  const LoadingPostShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF3A3B3C) : Colors.grey[300]!;
    final highlightColor = isDark ? const Color(0xFF4E4F50) : Colors.grey[100]!;

    return Container(
      color: isDark ? const Color(0xFF242526) : Colors.white,
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
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 80,
                        height: 10,
                        color: Colors.white,
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
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 200,
                    height: 10,
                    color: Colors.white,
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
                  Container(width: 60, height: 20, color: Colors.white),
                  Container(width: 60, height: 20, color: Colors.white),
                  Container(width: 60, height: 20, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
