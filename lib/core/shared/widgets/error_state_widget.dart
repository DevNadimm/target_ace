import 'package:flutter/material.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/messages.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';

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

      // Only allow custom messages for Server/Unknown errors.
      // Global errors like Network, NotFound, BotProtection MUST use AppMessages.
      if (message != null && message!.isNotEmpty) {
        if (errorType == ErrorType.server || errorType == ErrorType.unknown) {
          messageMap['message'] = message!;
        }
      }

      return messageMap;
    }

    final resolvedMessage = getMessage();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ?? _loadErrorImage(),
            const SizedBox(height: 8),
            Text(
              resolvedMessage['title']!,
              style: AppFonts.heading(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Text(
              resolvedMessage['message']!,
              style: AppFonts.body(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                height: 40,
                width: 120,
                child: SpringButton(
                  onPressed: onRetry,
                  child: Text(buttonText ?? 'RETRY'),
                ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Image.asset(_getIconName(), width: double.infinity),
    );
  }
}
