import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/features/notification/data/models/notification_model.dart';
import 'package:target_ace/features/notification/data/repos/notification_repo.dart';

// Events
abstract class NotificationEvent {}

class FetchNotificationsEvent extends NotificationEvent {}

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

// States
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  NotificationLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

// Bloc implementation
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<MarkReadEvent>(_onMarkRead);
    on<MarkAllReadEvent>(_onMarkAllRead);
    on<DeleteSingleEvent>(_onDeleteSingle);
    on<DeleteAllEvent>(_onDeleteAll);
  }

  Future<void> _onFetchNotifications(
    FetchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final list = await NotificationRepo.fetchNotifications();
      emit(NotificationLoaded(list));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkRead(
    MarkReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await NotificationRepo.markAsRead(event.id);
      if (state is NotificationLoaded) {
        final currentList = (state as NotificationLoaded).notifications;
        final updatedList = currentList.map((item) {
          if (item.id == event.id) {
            return item.copyWith(isRead: true);
          }
          return item;
        }).toList();
        emit(NotificationLoaded(updatedList));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllRead(
    MarkAllReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await NotificationRepo.markAllAsRead();
      if (state is NotificationLoaded) {
        final currentList = (state as NotificationLoaded).notifications;
        final updatedList = currentList.map((item) => item.copyWith(isRead: true)).toList();
        emit(NotificationLoaded(updatedList));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onDeleteSingle(
    DeleteSingleEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await NotificationRepo.deleteNotification(event.id);
      if (state is NotificationLoaded) {
        final currentList = (state as NotificationLoaded).notifications;
        final updatedList = currentList.where((item) => item.id != event.id).toList();
        emit(NotificationLoaded(updatedList));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onDeleteAll(
    DeleteAllEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      await NotificationRepo.deleteAllNotifications();
      emit(NotificationLoaded(const []));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
