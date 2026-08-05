part of 'home_bloc.dart';

sealed class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final HomeEntity homeModel;
  HomeSuccess(this.homeModel);
}

class HomeFailure extends HomeState {
  final ErrorType? errorType;
  final String? message;
  HomeFailure(this.errorType, this.message);
}