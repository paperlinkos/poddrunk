import 'package:flutter/material.dart';
import '../theme/neo_brutalist_theme.dart';

class BrutalistButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final bool active;

  const BrutalistButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.width,
    this.height,
    this.active = false,
  });

  @override
  State<BrutalistButton> createState() => _BrutalistButtonState();
}

class _BrutalistButtonState extends State<BrutalistButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorder = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    
    Color defaultBg;
    if (widget.active) {
      defaultBg = isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent;
    } else {
      defaultBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;
    }

    final bg = widget.backgroundColor ?? defaultBg;
    final border = widget.borderColor ?? defaultBorder;
    final shadowColor = isDark ? Colors.black : border;

    final shadowOffset = _isPressed
        ? const Offset(1, 1)
        : (widget.active ? const Offset(1, 1) : NeoBrutalistTheme.shadowOffset);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
          border: Border.all(
            color: border,
            width: NeoBrutalistTheme.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: shadowOffset,
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: DefaultTextStyle(
            style: TextStyle(
              color: widget.textColor ?? (isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText),
              fontWeight: FontWeight.bold,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
