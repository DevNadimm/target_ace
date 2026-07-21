// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:target_ace/core/config/colors.dart';
//
// class SectionHeader extends StatelessWidget {
//   final String title;
//   final String? actionText;
//   final VoidCallback? onAction;
//
//   const SectionHeader({
//     super.key,
//     required this.title,
//     this.actionText,
//     this.onAction,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           if (actionText != null)
//             GestureDetector(
//               onTap: onAction,
//               child: Text(
//                 actionText!,
//                 style: GoogleFonts.poppins(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
