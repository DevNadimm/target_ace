// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:target_ace/core/components/custom_container.dart';
// import 'package:target_ace/core/config/colors.dart';
//
// class DashboardStatTile extends StatelessWidget {
//   final List<List<dynamic>> icon;
//   final String value;
//   final String label;
//   final Color color;
//
//   const DashboardStatTile({
//     super.key,
//     required this.icon,
//     required this.value,
//     required this.label,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: CustomContainer(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: color.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: HugeIcon(icon: icon, size: 24, color: color),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     value,
//                     style: GoogleFonts.poppins(
//                       color: AppColors.textPrimary,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       height: 1,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     label,
//                     style: GoogleFonts.poppins(
//                       color: AppColors.textSecondary,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
