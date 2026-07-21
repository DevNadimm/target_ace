import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:target_ace/core/services/dio_service.dart';

class HelperFunctions {
  HelperFunctions._();

  static final NumberFormat _bdTakaFormat = NumberFormat.decimalPattern('en');

  static String toBengaliDigits(String input) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengaliDigits = ['à§¦', 'à§§', 'à§¨', 'à§©', 'à§ª', 'à§«', 'à§¬', 'à§­', 'à§®', 'à§¯'];
    
    var result = input;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(englishDigits[i], bengaliDigits[i]);
    }
    return result;
  }

  static String toEnglishDigits(String input) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengaliDigits = ['à§¦', 'à§§', 'à§¨', 'à§©', 'à§ª', 'à§«', 'à§¬', 'à§­', 'à§®', 'à§¯'];
    
    var result = input;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(bengaliDigits[i], englishDigits[i]);
    }
    return result;
  }

  static String toBengaliDigitsIfBn(String input) {
    final isBn = Intl.defaultLocale?.startsWith('bn') ?? false;
    return isBn ? toBengaliDigits(input) : input;
  }

  static String formatTaka(num? amount, {bool forceEnglish = false}) {
    if (amount == null) return forceEnglish ? '0' : 'à§¦';
    final formatted = _bdTakaFormat.format(amount);
    if (forceEnglish) return formatted;
    final isBn = Intl.defaultLocale?.startsWith('bn') ?? false;
    return isBn ? toBengaliDigits(formatted) : formatted;
  }

  static String formatTakaWithSymbol(num? amount) {
    if (amount == null) return 'à§³à§¦';
    final formatted = 'à§³${_bdTakaFormat.format(amount)}';
    final isBn = Intl.defaultLocale?.startsWith('bn') ?? false;
    return isBn ? toBengaliDigits(formatted) : formatted;
  }

  static String capitalize(String? input) {
    if (input == null || input.isEmpty) return '';
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  static String padNumber(int number) {
    final formatted = number.toString().padLeft(2, '0');
    final isBn = Intl.defaultLocale?.startsWith('bn') ?? false;
    return isBn ? toBengaliDigits(formatted) : formatted;
  }

  static String formatCompact(num? value) {
    if (value == null) return 'à§¦';
    String formatted;
    if (value >= 10000000) {
      formatted = '${(value / 10000000).toStringAsFixed(value % 10000000 == 0 ? 0 : 1)}Cr';
    } else if (value >= 100000) {
      formatted = '${(value / 100000).toStringAsFixed(value % 100000 == 0 ? 0 : 1)}L';
    } else if (value >= 1000) {
      formatted = '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    } else {
      formatted = value.toStringAsFixed(0);
    }
    final isBn = Intl.defaultLocale?.startsWith('bn') ?? false;
    return isBn ? toBengaliDigits(formatted) : formatted;
  }

  static String combineInfo(
    List<String?> parts, {
    String separator = ' â€¢ ',
    String fallback = '',
  }) {
    final filtered = parts.where((part) => part != null && part.trim().isNotEmpty).map((part) => part!.trim()).toList();
    return filtered.isEmpty ? fallback : filtered.join(separator);
  }

  static Future<String> getPublicIp() async {
    final dio = GetIt.instance<DioService>();

    try {
      final response = await dio.getRequest(
        'https://api.ipify.org?format=json',
      );

      return response.data['ip'] as String;
    } catch (_) {
      return 'Unknown';
    }
  }
}

