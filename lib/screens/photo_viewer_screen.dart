import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';

class PhotoViewerScreen extends StatefulWidget {
  final String imageUrl;
  final PostModel? post; // Optional context for bottom actions

  const PhotoViewerScreen({
    super.key,
    required this.imageUrl,
    this.post,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  // Simple check to toggle UI overlaid on tap
  bool _showOverlay = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
             _showOverlay = !_showOverlay;
          });
        },
        child: Stack(
          children: [
            // Main Image with Zoom
            Center(
              child: Dismissible(
                key: const Key('photo_viewer'),
                direction: DismissDirection.vertical,
                onDismissed: (_) => Navigator.pop(context),
                background: const ColoredBox(color: Colors.transparent),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            
            // Top Bar
            if (_showOverlay)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.more_horiz, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom Actions (if post data provided)
            if (_showOverlay && widget.post != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       const Icon(Icons.thumb_up_outlined, color: Colors.white),
                       const Icon(Icons.chat_bubble_outline, color: Colors.white),
                       const Icon(Icons.share_outlined, color: Colors.white),
                     ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
