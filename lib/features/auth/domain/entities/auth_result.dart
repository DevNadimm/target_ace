import 'package:target_ace/core/common/entities/user.dart';

/// Pure domain entity representing subscription details.
class AuthSubscription {
  final String status;
  final String? planId;
  final String? planName;
  final String? startDate;
  final String? endDate;
  final int? daysRemaining;
  final bool isTrial;

  const AuthSubscription({
    required this.status,
    this.planId,
    this.planName,
    this.startDate,
    this.endDate,
    this.daysRemaining,
    this.isTrial = false,
  });
}

/// Represents the success result of an authentication operation.
class AuthResult {
  final bool success;
  final String message;
  final String token;
  final User user;
  final AuthSubscription? subscription;

  const AuthResult({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
    this.subscription,
  });
}
