import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';

class PhotoViewerScreen extends StatefulWidget {
  final String imageUrl;
  final PostModel? post;

  const PhotoViewerScreen({
    super.key,
    required this.imageUrl,
    this.post,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  bool _showOverlay = true;
  double _dragDistance = 0;
  double _scale = 1.0;
  double _opacity = 1.0;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDistance += details.delta.dy;
      // Scale down as user drags (0.5 is minimum scale at 200px drag)
      _scale = (1.0 - (_dragDistance.abs() / 400)).clamp(0.5, 1.0);
      // Fade background as user drags
      _opacity = (1.0 - (_dragDistance.abs() / 200)).clamp(0.0, 1.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragDistance.abs() > 100) {
      Navigator.pop(context);
    } else {
      setState(() {
        _dragDistance = 0;
        _scale = 1.0;
        _opacity = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: _opacity),
      body: GestureDetector(
        onTap: () => setState(() => _showOverlay = !_showOverlay),
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Stack(
          children: [
            // Main Image with Scale Animation
            Center(
              child: Transform.scale(
                scale: _scale,
                child: Transform.translate(
                  offset: Offset(0, _dragDistance),
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
            ),
            
            // Top Bar
            if (_showOverlay && _scale == 1.0)
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

            // Bottom Actions
            if (_showOverlay && widget.post != null && _scale == 1.0)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: const Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       Icon(Icons.thumb_up_outlined, color: Colors.white),
                       Icon(Icons.chat_bubble_outline, color: Colors.white),
                       Icon(Icons.share_outlined, color: Colors.white),
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
