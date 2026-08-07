import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/notification/domain/entities/notification_entity.dart';
import 'package:target_ace/features/notification/domain/usecases/get_notifications.dart';
import 'package:target_ace/features/notification/domain/usecases/mark_notification_as_read.dart';
import 'package:target_ace/features/notification/domain/usecases/mark_all_notifications_as_read.dart';
import 'package:target_ace/features/notification/domain/usecases/delete_notification.dart';
import 'package:target_ace/features/notification/domain/usecases/delete_all_notifications.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  static const int _pageSize = 20;

  final GetNotifications _getNotifications;
  final MarkNotificationAsRead _markNotificationAsRead;
  final MarkAllNotificationsAsRead _markAllNotificationsAsRead;
  final DeleteNotification _deleteNotification;
  final DeleteAllNotifications _deleteAllNotifications;

  NotificationBloc({
    required GetNotifications getNotifications,
    required MarkNotificationAsRead markNotificationAsRead,
    required MarkAllNotificationsAsRead markAllNotificationsAsRead,
    required DeleteNotification deleteNotification,
    required DeleteAllNotifications deleteAllNotifications,
  })  : _getNotifications = getNotifications,
        _markNotificationAsRead = markNotificationAsRead,
        _markAllNotificationsAsRead = markAllNotificationsAsRead,
        _deleteNotification = deleteNotification,
        _deleteAllNotifications = deleteAllNotifications,
        super(NotificationInitial()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<FetchMoreNotificationsEvent>(_onFetchMoreNotifications);
    on<MarkReadEvent>(_onMarkRead);
    on<MarkAllReadEvent>(_onMarkAllRead);
    on<DeleteSingleEvent>(_onDeleteSingle);
    on<DeleteAllEvent>(_onDeleteAll);
  }

  Future<void> _onFetchNotifications(
    FetchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (!event.isRefresh && state is! NotificationLoaded) {
      emit(NotificationLoading());
    }

    final res = await _getNotifications(const GetNotificationsParams(page: 1, limit: _pageSize));
    res.fold(
      (failure) => emit(NotificationError(failure.message, failure.type)),
      (notifications) {
        emit(NotificationLoaded(
          notifications: notifications,
          currentPage: 1,
          hasMore: notifications.length >= _pageSize,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onFetchMoreNotifications(
    FetchMoreNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationLoaded || currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final res = await _getNotifications(GetNotificationsParams(page: nextPage, limit: _pageSize));

    res.fold(
      (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (newNotifications) {
        final updatedList = List<NotificationEntity>.from(currentState.notifications)..addAll(newNotifications);
        emit(NotificationLoaded(
          notifications: updatedList,
          currentPage: nextPage,
          hasMore: newNotifications.length >= _pageSize,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onMarkRead(
    MarkReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final res = await _markNotificationAsRead(event.id);
    res.fold(
      (failure) => emit(NotificationError(failure.message, failure.type)),
      (_) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          final updatedList = currentState.notifications.map((item) {
            if (item.id == event.id) {
              return item.copyWith(isRead: true);
            }
            return item;
          }).toList();
          emit(currentState.copyWith(notifications: updatedList));
        }
      },
    );
  }

  Future<void> _onMarkAllRead(
    MarkAllReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final res = await _markAllNotificationsAsRead(const NoParams());
    res.fold(
      (failure) => emit(NotificationError(failure.message, failure.type)),
      (_) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          final updatedList = currentState.notifications.map((item) => item.copyWith(isRead: true)).toList();
          emit(currentState.copyWith(notifications: updatedList));
        }
      },
    );
  }

  Future<void> _onDeleteSingle(
    DeleteSingleEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final res = await _deleteNotification(event.id);
    res.fold(
      (failure) => emit(NotificationError(failure.message, failure.type)),
      (_) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          final updatedList = currentState.notifications.where((item) => item.id != event.id).toList();
          emit(currentState.copyWith(notifications: updatedList));
        }
      },
    );
  }

  Future<void> _onDeleteAll(
    DeleteAllEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final res = await _deleteAllNotifications(const NoParams());
    res.fold(
      (failure) => emit(NotificationError(failure.message, failure.type)),
      (_) => emit(const NotificationLoaded(notifications: [], hasMore: false, currentPage: 1)),
    );
  }
}