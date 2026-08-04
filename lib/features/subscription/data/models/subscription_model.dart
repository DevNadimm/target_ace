import 'package:target_ace/features/subscription/domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.status,
    super.planId,
    super.planName,
    super.startDate,
    super.endDate,
    super.daysRemaining,
    super.isTrial = false,
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
