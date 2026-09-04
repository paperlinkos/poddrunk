import 'package:flutter/material.dart';
import '../theme/neo_brutalist_theme.dart';

class BrutalistModal extends StatelessWidget {
  final String title;
  final Widget child;

  const BrutalistModal({
    super.key,
    required this.title,
    required this.child,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BrutalistModal(
        title: title,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? NeoBrutalistColors.darkCanvas : NeoBrutalistColors.lightCanvas;
    final headerBg = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;
    final border = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 12,
        right: 12,
        top: 12,
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
            border: Border.all(
              color: border,
              width: NeoBrutalistTheme.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: border,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: headerBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(NeoBrutalistTheme.borderRadius),
                    topRight: Radius.circular(NeoBrutalistTheme.borderRadius),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: border,
                      width: NeoBrutalistTheme.borderWidth,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: textColor,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
