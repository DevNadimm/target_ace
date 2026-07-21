part of 'live_battle_hub_bloc.dart';

abstract class LiveBattleHubEvent {}

class LiveBattleHubFetchRequested extends LiveBattleHubEvent {
  final bool isSilent;
  LiveBattleHubFetchRequested({this.isSilent = false});
}
