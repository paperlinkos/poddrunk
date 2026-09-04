import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../../audio/domain/models/track_model.dart';

class TrackInfoDialog extends StatelessWidget {
  final TrackModel track;

  const TrackInfoDialog({super.key, required this.track});

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return 'Unknown';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;

    int fileSize = 0;
    String extension = 'MP3';
    if (track.isLocal && track.uri.isNotEmpty) {
      try {
        final file = File(track.uri);
        if (file.existsSync()) {
          fileSize = file.lengthSync();
          extension = track.uri.split('.').last.toUpperCase();
        }
      } catch (_) {}
    } else {
      extension = 'STREAM';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
          border: Border.all(color: borderColor, width: NeoBrutalistTheme.borderWidth),
          boxShadow: [
            BoxShadow(
              color: borderColor,
              offset: NeoBrutalistTheme.shadowOffset,
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
                border: Border(
                  bottom: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'TRACK DETAILS & METADATA',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content Body
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaRow('TITLE', track.title, textColor),
                  _buildMetaRow('ARTIST', track.artist, textColor),
                  _buildMetaRow('ALBUM', track.album, textColor),
                  _buildMetaRow('DURATION', _formatDuration(track.duration), textColor),
                  _buildMetaRow('FORMAT', extension, textColor),
                  if (track.isLocal && fileSize > 0)
                    _buildMetaRow('FILE SIZE', _formatFileSize(fileSize), textColor),
                  _buildMetaRow('SOURCE', track.isLocal ? 'Device Internal Storage' : 'Cloud Audio Stream', textColor),
                  if (track.uri.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'FILE PATH / URI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black54 : Colors.grey.shade100,
                        border: Border.all(color: borderColor, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SelectableText(
                        track.uri,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Close Button
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: BrutalistButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
