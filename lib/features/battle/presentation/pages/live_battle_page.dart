import 'package:target_ace/core/config/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/features/battle/presentation/bloc/battle/battle_bloc.dart';
import 'package:target_ace/features/battle/presentation/widgets/live/analyzing_battle_results_view.dart';
import 'package:target_ace/features/battle/presentation/widgets/live/active_battle_view.dart';
import 'package:target_ace/features/battle/presentation/widgets/live/battle_disqualified_view.dart';
import 'package:target_ace/features/battle/presentation/widgets/live/battle_scoreboard_view.dart';
import 'package:target_ace/features/battle/presentation/widgets/live/battle_waiting_room_view.dart';

class LiveBattlePage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const LiveBattlePage());

  const LiveBattlePage({super.key});

  @override
  State<LiveBattlePage> createState() => _LiveBattlePageState();
}

class _LiveBattlePageState extends State<LiveBattlePage> with WidgetsBindingObserver {
  late final BattleBloc _bloc;
  DateTime? _backgroundTime;
  final ValueNotifier<int> _secondsRemainingNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bloc = sl<BattleBloc>()..add(BattleLoadRequested());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _secondsRemainingNotifier.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final currentState = _bloc.state;
    if (currentState is BattleActive) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        _backgroundTime ??= DateTime.now();
      } else if (state == AppLifecycleState.resumed) {
        if (_backgroundTime != null) {
          final elapsedSeconds = DateTime.now().difference(_backgroundTime!).inSeconds;
          _backgroundTime = null; // reset

          if (elapsedSeconds > 30) {
            _bloc.add(BattleDisqualificationRequested());
          } else {
            // Deduct elapsed time from active remaining time
            final newTimeRemaining = currentState.questionSecondsRemaining - elapsedSeconds;
            _bloc.add(BattleTimeTicked(newTimeRemaining));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<BattleBloc, BattleState>(
        listenWhen: (previous, current) => true,
        listener: (context, state) {
          if (state is BattleError) {
            AppNotifier.showSnackBar(context, state.message ?? AppMessages.errorMessage, type: MessageType.error);
          }
          if (state is BattleWaiting) {
            _secondsRemainingNotifier.value = state.waitingSecondsRemaining;
          } else if (state is BattleActive) {
            _secondsRemainingNotifier.value = state.questionSecondsRemaining;
          } else if (state is BattleAnalyzing) {
            _secondsRemainingNotifier.value = state.analyzingSecondsRemaining;
          }
        },
        buildWhen: (previous, current) {
          if (previous.runtimeType != current.runtimeType) return true;
          if (previous is BattleActive && current is BattleActive) {
            // selectedOption MUST trigger rebuild so the option UI highlights
            return previous.currentIndex != current.currentIndex ||
                previous.selectedOption != current.selectedOption ||
                previous.questions != current.questions;
          }
          if (previous is BattleAnalyzing && current is BattleAnalyzing) {
            return previous.isDisqualified != current.isDisqualified;
          }
          // BattleWaiting timer ticks â†’ never rebuild (handled by ValueNotifier)
          if (previous is BattleWaiting && current is BattleWaiting) return false;
          return true;
        },
        builder: (context, state) {
          return PopScope(
            canPop: state is BattleInitial || state is BattleError || state is BattleScoreboard,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              AppNotifier.showSnackBar(
                context,
                'You cannot exit the live battle area during active testing.',
                type: MessageType.warning,
              );
            },
            child: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, BattleState state) {
    if (state is BattleInitial || state is BattleLoading) {
      return const Scaffold(
        body: GradientBackground(
          child: Center(
            child: Loader(),
          ),
        ),
      );
    }

    if (state is BattleError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Live Battle Error'),
        ),
        body: GradientBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  state.message ?? AppMessages.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (state is BattleWaiting) {
      return BattleWaitingRoomView(
        examTitle: state.examTitle,
        secondsNotifier: _secondsRemainingNotifier,
      );
    }

    if (state is BattleActive) {
      return ActiveBattleView(
        examTitle: state.examTitle,
        questions: state.questions,
        currentIndex: state.currentIndex,
        selectedOption: state.selectedOption,
        userAnswersList: state.userAnswersList,
        secondsNotifier: _secondsRemainingNotifier,
        isSubmitting: false,
        onOptionSelected: (option) => context.read<BattleBloc>().add(BattleOptionSelected(option)),
        onSubmit: () => context.read<BattleBloc>().add(BattleAnswerSubmitted()),
        onQuestionJumped: (index) => context.read<BattleBloc>().add(BattleQuestionJumped(index)),
      );
    }

    if (state is BattleAnalyzing) {
      return AnalyzingBattleResultsView(
        examTitle: state.examTitle,
        secondsNotifier: _secondsRemainingNotifier,
        isDisqualified: state.isDisqualified,
      );
    }

    if (state is BattleScoreboard) {
      if (state.isDisqualified) {
        return BattleDisqualifiedView(
          examTitle: state.examTitle,
          onExit: () => Navigator.pop(context),
        );
      }
      return BattleScoreboardView(
        examId: state.examId,
        examTitle: state.examTitle,
        score: state.score,
        examRank: state.examRank,
        groupRank: state.groupRank,
        globalRank: state.globalRank,
        leaderboard: state.leaderboard,
        userAnswersList: state.userAnswersList,
        onExit: () => Navigator.pop(context),
      );
    }

    return const SizedBox.shrink();
  }
}