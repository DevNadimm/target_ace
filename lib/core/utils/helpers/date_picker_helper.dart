import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerHelper {
  DatePickerHelper._();

  /// Opens date picker and sets formatted date into controller
  static Future<void> show({
    required BuildContext context,
    required TextEditingController controller,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? initialDate,
    String format = 'dd MMM, yyyy',
  }) async {
    final now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(now.year - 5),
      lastDate: lastDate ?? DateTime(now.year + 5),
    );

    if (pickedDate != null) {
      controller.text = DateFormat(format).format(pickedDate);
    }
  }
}
