part of 'home_bloc.dart';

sealed class HomeEvent {}

class HomeFetchRequested extends HomeEvent {
  final bool isSilent;
  HomeFetchRequested({this.isSilent = false});
}
