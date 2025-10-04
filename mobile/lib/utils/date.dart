import 'package:intl/intl.dart';

/// Get a human readable date from a YYYY-MM-DD HH:MM:SS format
/// Should output (e.g. Jan 1, 2025 - 12:00 PM)
String toHumanDate(String date) {
  try {
    final dt = DateTime.parse(date);
    final formatter = DateFormat('MMM d, yyyy - h:mm a');
    return formatter.format(dt);
  } catch (e) {
    return date;
  }
}
