part of 'notification_bloc.dart';

sealed class NotificationEvent {}

class FetchNotificationsEvent extends NotificationEvent {
  final bool isRefresh;
  FetchNotificationsEvent({this.isRefresh = false});
}

class FetchMoreNotificationsEvent extends NotificationEvent {}

class MarkReadEvent extends NotificationEvent {
  final String id;
  MarkReadEvent(this.id);
}

class MarkAllReadEvent extends NotificationEvent {}

class DeleteSingleEvent extends NotificationEvent {
  final String id;
  DeleteSingleEvent(this.id);
}

class DeleteAllEvent extends NotificationEvent {}
