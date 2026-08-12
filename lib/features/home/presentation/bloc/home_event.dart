part of 'home_bloc.dart';

sealed class HomeEvent {}

class HomeFetchRequested extends HomeEvent {
  final bool isSilent;
  final bool force;
  HomeFetchRequested({this.isSilent = false, this.force = false});
}
