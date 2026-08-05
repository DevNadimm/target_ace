import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/colors.dart';

Color parseHexColor(String hex) {
  try {
    final cleanHex = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  } catch (_) {
    return AppColors.primary;
  }
}

List<List<dynamic>> mapIconToHugeIcon(String iconName) {
  switch (iconName) {
    case 'bookOpen':
      return HugeIcons.strokeRoundedBookOpen01;
    case 'graduateCap':
      return HugeIcons.strokeRoundedGraduateMale;
    case 'school':
      return HugeIcons.strokeRoundedSchool;
    case 'atom':
    case 'atom01':
      return HugeIcons.strokeRoundedAtom01;
    case 'chartAnalysing':
    case 'chart':
      return HugeIcons.strokeRoundedBarChart;
    case 'tools':
      return HugeIcons.strokeRoundedTools;
    case 'dna':
      return HugeIcons.strokeRoundedDna;
    default:
      return HugeIcons.strokeRoundedTarget01;
  }
}