import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../theme/app_theme.dart';
import 'package:flutter/services.dart';

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
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _ReactionOverlay(
        initialPosition: Offset(position.dx, position.dy - 70), // Show above button
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
      case ReactionType.haha:
      case ReactionType.wow:
      case ReactionType.sad: return Colors.amber;
      case ReactionType.angry: return Colors.deepOrange;
    }
  }

  String _getReactionText(ReactionType? type) {
    if (type == null) return 'Like';
    return type.name[0].toUpperCase() + type.name.substring(1);
  }

  IconData _getReactionIcon(ReactionType? type) {
    if (type == null) return Icons.thumb_up_outlined;
    switch (type) {
      case ReactionType.like: return Icons.thumb_up;
      case ReactionType.love: return Icons.favorite;
      case ReactionType.haha: return Icons.sentiment_satisfied_alt;
      case ReactionType.wow: return Icons.sentiment_very_dissatisfied;
      case ReactionType.sad: return Icons.sentiment_dissatisfied;
      case ReactionType.angry: return Icons.sentiment_very_dissatisfied;
    }
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
            Icon(
              _getReactionIcon(widget.initialReaction),
              color: color,
              size: 20,
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
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getEmoji(ReactionType type) {
    switch (type) {
      case ReactionType.like: return '👍';
      case ReactionType.love: return '❤️';
      case ReactionType.haha: return '😆';
      case ReactionType.wow: return '😮';
      case ReactionType.sad: return '😢';
      case ReactionType.angry: return '😡';
    }
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
          left: 20, // Check bounds carefully
          top: widget.initialPosition.dy,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _reactions.map((type) {
                  final isHovered = _hoveredReaction == type;
                  return GestureDetector(
                    onTapDown: (_) => widget.onReactionSelected(type),
                    child: MouseRegion(
                       onEnter: (_) => setState(() => _hoveredReaction = type),
                       onExit: (_) => setState(() => _hoveredReaction = null),
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 6),
                         child: AnimatedScale(
                           scale: isHovered ? 1.5 : 1.0,
                           duration: const Duration(milliseconds: 150),
                           curve: Curves.easeOutBack,
                           child: Text(
                             _getEmoji(type),
                             style: const TextStyle(fontSize: 28),
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
