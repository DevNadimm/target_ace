class SubscriptionModel {
  final String status;
  final String? planId;
  final String? planName;
  final String? startDate;
  final String? endDate;
  final int? daysRemaining;
  final bool isTrial;

  SubscriptionModel({
    required this.status,
    this.planId,
    this.planName,
    this.startDate,
    this.endDate,
    this.daysRemaining,
    this.isTrial = false,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      status: json['status'] as String? ?? 'none',
      planId: json['plan_id']?.toString(),
      planName: json['plan_name'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      daysRemaining: json['days_remaining'] as int?,
      isTrial: json['is_trial'] == true,
    );
  }
}

