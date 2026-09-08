class TimeFormatter {
  /// Formats a [Duration] into `HH:MM:SS` format (e.g. `00:03:45`, `01:15:30`).
  static String formatHHMMSS(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
