import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/neo_brutalist_theme.dart';

class BrutalistCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool hasShadow;
  final Offset shadowOffset;

  const BrutalistCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.all(12.0),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.onLongPress,
    this.hasShadow = true,
    this.shadowOffset = NeoBrutalistTheme.shadowOffset,
  });

  @override
  State<BrutalistCard> createState() => _BrutalistCardState();
}

class _BrutalistCardState extends State<BrutalistCard> {
  bool _isPressed = false;

  bool get _isInteractive => widget.onTap != null || widget.onLongPress != null;

  void _onTapDown(TapDownDetails details) {
    if (!_isInteractive) return;
    HapticFeedback.selectionClick();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;
    final defaultBorder = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;

    final bg = widget.backgroundColor ?? defaultBg;
    final border = widget.borderColor ?? defaultBorder;
    final shadowColor = isDark ? Colors.black : border;

    final isPressedState = _isInteractive && _isPressed;
    final currentOffset = isPressedState
        ? Offset(
            (widget.shadowOffset.dx - 1.5).clamp(1.0, 10.0),
            (widget.shadowOffset.dy - 1.5).clamp(1.0, 10.0),
          )
        : widget.shadowOffset;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(
        isPressedState ? 1.5 : 0.0,
        isPressedState ? 1.5 : 0.0,
        0.0,
      ),
      margin: widget.margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
        border: Border.all(
          color: border,
          width: NeoBrutalistTheme.borderWidth,
        ),
        boxShadow: widget.hasShadow
            ? [
                BoxShadow(
                  color: shadowColor,
                  offset: currentOffset,
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
