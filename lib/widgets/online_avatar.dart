import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Avatar widget with optional online indicator (green dot).
class OnlineAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool isOnline;

  const OnlineAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: CachedNetworkImageProvider(imageUrl),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.5,
              height: radius * 0.5,
              decoration: BoxDecoration(
                color: const Color(0xFF31A24C), // Facebook green
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF242526) : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
