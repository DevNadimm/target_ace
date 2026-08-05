import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/messages.dart';
import 'package:target_ace/core/logger/app_logger.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:target_ace/core/utils/helpers/date_formatter.dart';
import 'package:target_ace/core/utils/helpers/helper_functions.dart';

class ErrorStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? icon;
  final String? buttonText;
  final ErrorType? errorType;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.buttonText,
    this.errorType = ErrorType.unknown,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {

    Map<String, String> getMessage() {
      final Map<String, String> messageMap = {};

      switch (errorType) {
        case ErrorType.network:
          messageMap['title'] = AppMessages.networkErrorTitle;
          messageMap['message'] = AppMessages.networkErrorMessage;
          break;

        case ErrorType.server:
          messageMap['title'] = AppMessages.serverErrorTitle;
          messageMap['message'] = AppMessages.serverErrorMessage;
          break;

        case ErrorType.notFound:
          messageMap['title'] = AppMessages.notFoundErrorTitle;
          messageMap['message'] = AppMessages.notFoundErrorMessage;
          break;

        case ErrorType.botProtection:
          messageMap['title'] = AppMessages.botProtectionErrorTitle;
          messageMap['message'] = AppMessages.botProtectionErrorMessage;
          break;

        case ErrorType.unknown:
        default:
          messageMap['title'] = AppMessages.errorTitle;
          messageMap['message'] = AppMessages.errorMessage;
      }

      if (title != null && title!.isNotEmpty) {
        messageMap['title'] = title!;
      }

      if (message != null && message!.isNotEmpty) {
        messageMap['message'] = message!;
      }

      return messageMap;
    }

    final resolvedMessage = getMessage();
    final isBotProtection = errorType == ErrorType.botProtection;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ?? _loadErrorImage(),
            const SizedBox(height: 14),

            Text(
              resolvedMessage['title']!,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 14),

            Text(
              resolvedMessage['message']!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),

            // All other errors: show retry button (if provided)
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(buttonText ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getIconName() {
    if (errorType == ErrorType.network) return Assets.networkError;
    if (errorType == ErrorType.server) return Assets.serverError;
    if (errorType == ErrorType.botProtection) return Assets.serverError;
    if (errorType == ErrorType.notFound) return Assets.notFoundError;
    return Assets.error;
  }

  Widget _loadErrorImage() {
    return Image.asset(_getIconName(), height: 100, width: 100);
  }
}
