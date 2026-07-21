part of 'dashboard_bloc.dart';

sealed class DashboardEvent {}

class DashboardFetchRequested extends DashboardEvent {
  final bool isSilent;
  DashboardFetchRequested({this.isSilent = false});
}

