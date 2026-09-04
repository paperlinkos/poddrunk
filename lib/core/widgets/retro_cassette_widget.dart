import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/neo_brutalist_theme.dart';

class RetroCassetteWidget extends StatefulWidget {
  final bool isPlaying;
  final String title;
  final String artist;
  final double progress; // 0.0 to 1.0

  const RetroCassetteWidget({
    super.key,
    required this.isPlaying,
    required this.title,
    required this.artist,
    this.progress = 0.0,
  });

  @override
  State<RetroCassetteWidget> createState() => _RetroCassetteWidgetState();
}

class _RetroCassetteWidgetState extends State<RetroCassetteWidget> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant RetroCassetteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : const Color(0xFFEBE3D5);
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final accentColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black : borderColor,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top Sticker/Label Area
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'HIGH POSITION - TYPE II',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.title} - ${widget.artist}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Text(
                    'SIDE A',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Middle Reel Window
          Positioned(
            top: 60,
            left: 24,
            right: 24,
            height: 85,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left Reel
                  _buildReel(isLeft: true),

                  // Center Tape Window showing progress
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A3525), // Tape color
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Stack(
                        children: [
                          // Left tape spool thickness (decreases as progress increases)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: (1.0 - widget.progress).clamp(0.1, 0.9),
                              child: Container(color: const Color(0xFF7C5A3F)),
                            ),
                          ),
                          // Tape window lines
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                5,
                                (i) => Container(
                                  width: 1,
                                  height: double.infinity,
                                  color: Colors.black26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right Reel
                  _buildReel(isLeft: false),
                ],
              ),
            ),
          ),

          // Bottom Screw Points & Grill
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildScrew(borderColor),
                Row(
                  children: List.generate(
                    8,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 4,
                      height: 12,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
                _buildScrew(borderColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReel({required bool isLeft}) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Spoke holes
                ...List.generate(6, (index) {
                  final angle = index * (math.pi / 3);
                  return Transform.translate(
                    offset: Offset(14 * math.cos(angle), 14 * math.sin(angle)),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  );
                }),
                // Center spindle
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrew(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 1),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 1.5,
          color: color,
        ),
      ),
    );
  }
}
