part of 'notification_bloc.dart';

sealed class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;

  const NotificationLoaded({
    required this.notifications,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.currentPage = 1,
  });

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class NotificationError extends NotificationState {
  final String? message;
  final ErrorType? errorType;
  const NotificationError([this.message, this.errorType]);
}