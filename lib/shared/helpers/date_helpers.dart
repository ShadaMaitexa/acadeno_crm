/// Shared date/time formatting helpers used across the app.
class DateHelpers {
  DateHelpers._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Formats a [DateTime] to "Mon D, H:MM AM/PM".
  /// Handles midnight correctly (hour 0 → 12 AM).
  static String formatDateTime(DateTime dt) {
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${_months[dt.month - 1]} ${dt.day}, $h:$min $ampm';
  }

  /// Formats a Unix timestamp (milliseconds) to "Mon D, H:MM AM/PM".
  /// Returns empty string for null timestamps.
  static String formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    return formatDateTime(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  /// Formats duration in seconds to "Xm Ys".
  static String formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '0m 0s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }
}
