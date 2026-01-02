import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageHelper {
  /// Returns an ImageProvider for use in CircleAvatar or DecorationImage
  static ImageProvider getImageProvider(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImageProvider(url);
    } else if (url.startsWith('data:')) {
      // Handle Base64 Data URI
      try {
        final base64Str = url.split(',').last;
        return MemoryImage(base64Decode(base64Str));
      } catch (e) {
        return const AssetImage('assets/images/placeholder.jpg'); // Fallback
      }
    } else {
      return AssetImage(url);
    }
  }

  /// Returns a Widget for displaying an image
  static Widget getNetworkImage({
    required String imageUrl,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => Container(color: Colors.grey[300]),
        errorWidget: (context, url, error) => errorBuilder != null 
            ? errorBuilder(context, error, null)
            : const Icon(Icons.error),
      );
    } else if (imageUrl.startsWith('data:')) {
      // Handle Base64 Data URI
      try {
        final base64Str = imageUrl.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          fit: fit,
          width: width,
          height: height,
          errorBuilder: errorBuilder ?? (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      } catch (e) {
        return Container(color: Colors.grey);
      }
    } else {
      return Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder ?? (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
  }
}
