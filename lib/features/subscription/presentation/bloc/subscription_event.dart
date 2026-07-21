part of 'subscription_bloc.dart';

sealed class SubscriptionEvent {}

class FetchSubscriptionStatus extends SubscriptionEvent {
  final bool isManualCheck;
  FetchSubscriptionStatus({this.isManualCheck = false});
}

