import 'package:flutter/material.dart';
import '../theme/neo_brutalist_theme.dart';

class BrutalistBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const BrutalistBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent);
    final border = borderColor ?? (isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder);
    final txt = textColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: border,
            offset: const Offset(1.5, 1.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: txt,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
