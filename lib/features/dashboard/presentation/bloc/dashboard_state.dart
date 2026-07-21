part of 'dashboard_bloc.dart';

sealed class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardSuccess extends DashboardState {
  final DashboardModel dashboardModel;
  DashboardSuccess(this.dashboardModel);
}

class DashboardFailure extends DashboardState {
  final ErrorType? errorType;
  final String? message;
  DashboardFailure(this.errorType, this.message);
}

