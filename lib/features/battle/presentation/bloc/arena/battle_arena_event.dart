part of 'battle_arena_bloc.dart';

abstract class BattleArenaEvent {}

class BattleArenaFetchRequested extends BattleArenaEvent {
  final bool isSilent;
  BattleArenaFetchRequested({this.isSilent = false});
}