import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/post_model.dart';
import '../../theme/app_theme.dart';
import 'package:flutter/services.dart';
import '../../utils/reaction_assets.dart';

class ReactionButton extends StatefulWidget {
  final ReactionType? initialReaction;
  final Function(ReactionType?) onReactionChanged;

  const ReactionButton({
    super.key,
    this.initialReaction,
    required this.onReactionChanged,
  });

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  void _showReactionTray() {
    if (_overlayEntry != null) return;

    final RenderBox renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    
    // Calculate vertical position (tray moves up)
    final topPosition = position.dy - 60; // Just above the button
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _ReactionOverlay(
        initialPosition: Offset(20, topPosition), // Fixed left margin like FB
        onReactionSelected: (reaction) {
          widget.onReactionChanged(reaction);
          _hideOverlay();
        },
        onDismiss: _hideOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    HapticFeedback.selectionClick();
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleTap() {
    if (widget.initialReaction == null) {
      widget.onReactionChanged(ReactionType.like);
      HapticFeedback.lightImpact();
    } else {
      widget.onReactionChanged(null);
    }
  }

  Color _getReactionColor(ReactionType? type) {
    if (type == null) return Colors.grey[600]!;
    switch (type) {
      case ReactionType.like: return AppTheme.facebookBlue;
      case ReactionType.love: return Colors.red;
      case ReactionType.care: return Colors.amber;
      case ReactionType.haha: return Colors.amber;
      case ReactionType.wow: return Colors.amber;
      case ReactionType.sad: return Colors.amber;
      case ReactionType.angry: return Colors.deepOrange;
    }
  }

  String _getReactionText(ReactionType? type) {
    if (type == null) return 'Like';
    return type.name[0].toUpperCase() + type.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.initialReaction == null
        ? (isDark ? const Color(0xFFB0B3B8) : Colors.grey[600]!)
        : _getReactionColor(widget.initialReaction);

    return GestureDetector(
      key: _buttonKey,
      onTap: _handleTap,
      onLongPressStart: (_) => _showReactionTray(),
      child: Container(
        color: Colors.transparent, // Hit test target
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            if (widget.initialReaction == null)
              Icon(
                Icons.thumb_up_outlined,
                color: color,
                size: 20,
              )
            else
              CachedNetworkImage(
                imageUrl: ReactionAssets.getReactionIcon(widget.initialReaction!),
                width: 20,
                height: 20,
                placeholder: (context, url) => SizedBox(width: 20, height: 20),
                errorWidget: (context, url, error) => Icon(Icons.error, size: 20, color: color),
              ),
              
            const SizedBox(width: 8),
            Text(
              _getReactionText(widget.initialReaction),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionOverlay extends StatefulWidget {
  final Offset initialPosition;
  final Function(ReactionType) onReactionSelected;
  final VoidCallback onDismiss;

  const _ReactionOverlay({
    required this.initialPosition,
    required this.onReactionSelected,
    required this.onDismiss,
  });

  @override
  State<_ReactionOverlay> createState() => _ReactionOverlayState();
}

class _ReactionOverlayState extends State<_ReactionOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  ReactionType? _hoveredReaction;

  final List<ReactionType> _reactions = [
    ReactionType.like,
    ReactionType.love,
    ReactionType.care,
    ReactionType.haha,
    ReactionType.wow,
    ReactionType.sad,
    ReactionType.angry,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop to detect tap outside
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            onPanDown: (_) => widget.onDismiss(), 
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: widget.initialPosition.dx,
          top: widget.initialPosition.dy,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _reactions.map((type) {
                  final isHovered = _hoveredReaction == type;
                  return GestureDetector(
                    onTapDown: (_) {
                       HapticFeedback.lightImpact();
                       widget.onReactionSelected(type);
                    },
                    onTap: () {
                       HapticFeedback.lightImpact();
                       widget.onReactionSelected(type);
                    },
                    child: MouseRegion(
                       onEnter: (_) => setState(() => _hoveredReaction = type),
                       onExit: (_) => setState(() => _hoveredReaction = null),
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 4),
                         child: AnimatedContainer(
                           duration: const Duration(milliseconds: 200),
                           curve: Curves.easeOutBack,
                           transform: Matrix4.identity()
                             ..translate(0.0, isHovered ? -10.0 : 0.0)
                             ..scale(isHovered ? 1.3 : 1.0),
                           child: CachedNetworkImage(
                             imageUrl: ReactionAssets.getReactionPath(type),
                             width: 40,
                             height: 40,
                             placeholder: (context, url) => Container(
                               width: 40, 
                               height: 40, 
                               decoration: BoxDecoration(
                                 color: Colors.grey[200],
                                 shape: BoxShape.circle,
                               ),
                               child: Center(
                                 child: Text(
                                   ReactionAssets.getReactionEmoji(type),
                                   style: const TextStyle(fontSize: 24),
                                 ),
                               ),
                             ),
                             errorWidget: (context, url, error) => Container(
                               width: 40, 
                               height: 40, 
                               alignment: Alignment.center,
                               child: Text(
                                 ReactionAssets.getReactionEmoji(type),
                                 style: const TextStyle(fontSize: 28),
                               ),
                             ),
                           ),
                         ),
                       ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

