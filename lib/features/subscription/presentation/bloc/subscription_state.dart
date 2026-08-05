part of 'subscription_bloc.dart';

sealed class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionEntity subscription;
  final bool isManualCheck;
  
  SubscriptionLoaded(this.subscription, {this.isManualCheck = false});
}

class SubscriptionError extends SubscriptionState {
  final ErrorType? errorType;
  final String? message;
  SubscriptionError(this.errorType, this.message);
}