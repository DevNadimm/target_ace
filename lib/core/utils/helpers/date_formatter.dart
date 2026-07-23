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
}

