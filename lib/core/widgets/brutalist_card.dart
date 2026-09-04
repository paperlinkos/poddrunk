import 'package:flutter/material.dart';
import '../theme/neo_brutalist_theme.dart';

class BrutalistCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;
    final defaultBorder = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;

    final bg = backgroundColor ?? defaultBg;
    final border = borderColor ?? defaultBorder;
    final shadowColor = isDark ? Colors.black : border;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
        border: Border.all(
          color: border,
          width: NeoBrutalistTheme.borderWidth,
        ),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: shadowColor,
                  offset: shadowOffset,
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
