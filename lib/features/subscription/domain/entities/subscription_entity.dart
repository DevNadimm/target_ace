class SubscriptionEntity {
  final String status;
  final String? planId;
  final String? planName;
  final String? startDate;
  final String? endDate;
  final int? daysRemaining;
  final bool isTrial;

  const SubscriptionEntity({
    required this.status,
    this.planId,
    this.planName,
    this.startDate,
    this.endDate,
    this.daysRemaining,
    this.isTrial = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionEntity &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          planId == other.planId &&
          planName == other.planName &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          daysRemaining == other.daysRemaining &&
          isTrial == other.isTrial;

  @override
  int get hashCode =>
      status.hashCode ^
      planId.hashCode ^
      planName.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      daysRemaining.hashCode ^
      isTrial.hashCode;
}