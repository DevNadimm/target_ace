// import 'package:in_app_update/in_app_update.dart';
// import 'package:flutter/material.dart';
//
// class AppUpdateService {
//   static Future<void> checkForUpdate(BuildContext context) async {
//     try {
//       final info = await InAppUpdate.checkForUpdate();
//
//       await Future.delayed(const Duration(seconds: 2));
//
//       if (info.updateAvailability == UpdateAvailability.updateAvailable) {
//
//         // âœ… Flexible update (non-critical)
//         await InAppUpdate.startFlexibleUpdate();
//         await InAppUpdate.completeFlexibleUpdate();
//
//         // âš ï¸ OR Immediate update (critical)
//         await InAppUpdate.performImmediateUpdate();
//
//         debugPrint("âœ… Update completed successfully!");
//       } else {
//         debugPrint("â„¹ï¸ No update available.");
//       }
//     } catch (e) {
//       debugPrint("âŒ Failed to check for update: $e");
//     }
//   }
// }
