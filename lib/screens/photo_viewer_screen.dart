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

class _PhotoViewerScreenState extends State<PhotoViewerScreen> with SingleTickerProviderStateMixin {
  bool _showOverlay = true;
  double _dragDistance = 0;
  double _opacity = 1.0;
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        _transformationController.value = _animation!.value;
      });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_transformationController.value.getMaxScaleOnAxis() > 1.0) return;
    setState(() {
      _dragDistance += details.delta.dy;
      _opacity = (1.0 - (_dragDistance.abs() / 200)).clamp(0.0, 1.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragDistance.abs() > 100) {
      Navigator.pop(context);
    } else {
      setState(() {
        _dragDistance = 0;
        _opacity = 1.0;
      });
    }
  }

  void _handleDoubleTap() {
    Matrix4 endMatrix;
    if (_transformationController.value.getMaxScaleOnAxis() > 1.0) {
      endMatrix = Matrix4.identity();
    } else {
      endMatrix = Matrix4.diagonal3Values(2.0, 2.0, 1.0);
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: _opacity),
      body: GestureDetector(
        onTap: () => setState(() => _showOverlay = !_showOverlay),
        onDoubleTap: _handleDoubleTap,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Stack(
          children: [
            // Main Image
            Center(
              child: Transform.translate(
                offset: Offset(0, _dragDistance),
                child: Hero(
                  tag: widget.imageUrl,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1.0,
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
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.more_horiz, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom Actions
            if (_showOverlay && widget.post != null)
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
