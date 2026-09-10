import 'package:intl/intl.dart';

/// Formatting utility for dates, times, and relative timestamps
class DateFormatter {
  static final DateFormat _monthDayYear = DateFormat('MMM d, yyyy');
  static final DateFormat _monthDay = DateFormat('MMM d');
  static final DateFormat _weekdayMonthDay = DateFormat('EEEE, MMMM d');
  static final DateFormat _timeOnly = DateFormat('h:mm a');
  static final DateFormat _time24 = DateFormat('HH:mm');

  static String formatFull(DateTime dateTime) => _monthDayYear.format(dateTime);

  static String formatShort(DateTime dateTime) => _monthDay.format(dateTime);

  static String formatHeader(DateTime dateTime) => _weekdayMonthDay.format(dateTime);

  static String formatTime(DateTime dateTime) => _timeOnly.format(dateTime);

  static String formatTime24(DateTime dateTime) => _time24.format(dateTime);

  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return _monthDay.format(dateTime);
    }
  }

  static String formatGreetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'morning';
    } else if (hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
