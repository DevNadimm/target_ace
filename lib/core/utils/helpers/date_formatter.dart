import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static DateTime? _parse(dynamic value) {
    try {
      if (value == null) return null;
      if (value is DateTime) return value;

      if (value.runtimeType.toString() == 'Timestamp') {
        return value.toDate();
      }

      final str = value.toString().trim();

      final iso = DateTime.tryParse(str);
      if (iso != null) return iso.toLocal();

      const formats = [
        'dd MMM, yyyy', // 07 Apr, 2026
        'dd MMMM, yyyy', // 07 April, 2026
        'dd/MM/yyyy', // 20/09/2025
        'EEE, dd MMM', // Thu, 02 Apr  (no year â€” limited use)
      ];

      for (final fmt in formats) {
        try {
          return DateFormat(fmt).parseLoose(str).toLocal();
        } catch (_) {}
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// 20 September, 2025
  static String readable(dynamic value, {bool isShortMonth = false, bool forceEnglish = false}) {
    final date = _parse(value);
    if (date == null) return value.toString();
    return DateFormat(
      isShortMonth ? 'dd MMM, yyyy' : 'dd MMMM, yyyy',
      forceEnglish ? 'en' : null,
    ).format(date);
  }

  /// 20 September, 2025 01:51 AM
  static String readableWithTime(dynamic value) {
    final date = _parse(value);
    if (date == null) return value.toString();
    return DateFormat('dd MMMM, yyyy hh:mm a').format(date);
  }

  /// 20 Sep 2025  •  01:51 AM
  static String readableShortWithTime(dynamic value) {
    final date = _parse(value);
    if (date == null) return value?.toString() ?? 'N/A';
    return '${DateFormat('dd MMM yyyy').format(date)}  •  ${DateFormat('hh:mm a').format(date)}';
  }

  static String readableWithTime12(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return value.toString();
    }

    try {
      final date = DateFormat('yyyy-MM-dd hh:mm a', 'en').parse(value.toString());
      return DateFormat('dd MMMM, yyyy hh:mm a').format(date);
    } catch (_) {
      return value.toString();
    }
  }

  /// 20/09/2025
  static String ddMMyyyy(dynamic value) {
    final date = _parse(value);
    if (date == null) return value.toString();
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// 2025-09-20  — always ASCII digits (safe for API calls)
  static String yyyyMMdd(dynamic value) {
    final date = _parse(value);
    if (date == null) return value.toString();
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Thu, 02 Apr
  static String eeeddMMM(dynamic value) {
    final date = _parse(value);
    if (date == null) return value.toString();
    return DateFormat('EEE, dd MMM').format(date);
  }

  /// FEB
  static String monthShort(String yearMonth) {
    try {
      final date = DateTime.parse('$yearMonth-01');
      return DateFormat('MMM').format(date).toUpperCase();
    } catch (_) {
      return yearMonth;
    }
  }

  /// January 2025
  static String monthYear(dynamic value, {bool? isShortMonth}) {
    if (value == null) return '';

    final str = value.toString().trim();

    try {
      DateTime? date;

      if (RegExp(r'^\d{4}-\d{2}$').hasMatch(str)) {
        date = DateTime.parse('$str-01');
      } else {
        date = _parse(value);
      }

      if (date == null) return str;

      return DateFormat(
        isShortMonth == true ? 'MMM yyyy' : 'MMMM yyyy',
      ).format(date);
    } catch (_) {
      return str;
    }
  }

  static String monthToYearMonth(dynamic value) {
    if (value == null) return '';

    final str = value.toString().trim();

    try {
      if (RegExp(r'^\d{4}-\d{2}$').hasMatch(str)) {
        return str;
      }

      try {
        final date = DateFormat('MMMM yyyy').parseLoose(str);
        return DateFormat('yyyy-MM', 'en').format(date);
      } catch (_) {}

      try {
        final date = DateFormat('MMM yyyy').parseLoose(str);
        return DateFormat('yyyy-MM', 'en').format(date);
      } catch (_) {}

      return str;
    } catch (_) {
      return str;
    }
  }

  /// Returns relative time string like 'Just now', '5m ago', '2h ago', 'Yesterday', '3d ago', or 'dd MMM'
  static String timeAgo(dynamic value) {
    final dateTime = _parse(value);
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM').format(dateTime);
    }
  }

  /// Formats upcoming time (e.g., Live Now, Starts in 5 mins, Starts in 2 hours, or specific date)
  static String formatUpcomingTime(dynamic value) {
    final startStr = value?.toString() ?? '';
    if (startStr.isEmpty) return '';
    
    try {
      final start = _parse(value);
      if (start == null) return startStr;
      
      final now = DateTime.now();
      final diff = start.difference(now);

      if (diff.isNegative) {
        return "Live Now";
      } else if (diff.inMinutes < 60) {
        return "Starts in ${diff.inMinutes} mins";
      } else if (diff.inHours < 24) {
        return "Starts in ${diff.inHours} hours";
      } else {
        return DateFormat('EEE, dd MMM  •  hh:mm a').format(start);
      }
    } catch (_) {
      return startStr;
    }
  }
}

