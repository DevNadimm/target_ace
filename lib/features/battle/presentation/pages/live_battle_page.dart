import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/features/battle/presentation/bloc/battle_cubit.dart';
import 'package:target_ace/features/battle/presentation/widgets/analyzing_results_widget.dart';
import 'package:target_ace/features/battle/presentation/widgets/battle_arena_widget.dart';
import 'package:target_ace/features/battle/presentation/widgets/battle_scoreboard_widget.dart';
import 'package:target_ace/features/battle/presentation/widgets/waiting_room_widget.dart';

class LiveBattlePage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const LiveBattlePage());

  const LiveBattlePage({super.key});

  @override
  State<LiveBattlePage> createState() => _LiveBattlePageState();
}

class _LiveBattlePageState extends State<LiveBattlePage> with WidgetsBindingObserver {
  late final BattleCubit _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = BattleCubit()..loadExamAndSetupSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      final currentState = _cubit.state;
      if (currentState is BattleActive) {
        _cubit.disqualifyUser();
        AppNotifier.showSnackBar(
          context,
          'You have been disqualified for leaving the app during the battle!',
          type: MessageType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<BattleCubit, BattleState>(
        builder: (context, state) {
          final bool canPop = (state is BattleWaiting && state.waitingSecondsRemaining > 10) || state is BattleScoreboard;

          return PopScope(
            canPop: canPop,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                AppNotifier.showSnackBar(
                  context,
                  'You cannot exit the room during the live battle!',
                  type: MessageType.warning,
                );
              }
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
          child: Center(child: Loader()),
        ),
      );
    }

    if (state is BattleError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Battle')),
        body: GradientBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      );
    }

    if (state is BattleWaiting) {
      return WaitingRoomWidget(
        examTitle: state.examTitle,
        waitingSecondsRemaining: state.waitingSecondsRemaining,
      );
    }

    if (state is BattleActive) {
      return BattleArenaWidget(
        examTitle: state.examTitle,
        questions: state.questions,
        currentIndex: state.currentIndex,
        selectedOption: state.selectedOption,
        questionSecondsRemaining: state.questionSecondsRemaining,
        isSubmitting: false,
        onOptionSelected: (option) => context.read<BattleCubit>().selectOption(option),
        onSubmit: () => context.read<BattleCubit>().submitCurrentAnswerAndNext(),
      );
    }

    if (state is BattleAnalyzing) {
      return AnalyzingResultsWidget(
        examTitle: state.examTitle,
        analyzingSecondsRemaining: state.analyzingSecondsRemaining,
      );
    }

    if (state is BattleScoreboard) {
      return BattleScoreboardWidget(
        examTitle: state.examTitle,
        score: state.score,
        examRank: state.examRank,
        groupRank: state.groupRank,
        globalRank: state.globalRank,
        leaderboard: state.leaderboard,
        isDisqualified: state.isDisqualified,
        questions: state.questions,
        userAnswersList: state.userAnswersList,
        onExit: () => Navigator.pop(context),
      );
    }

    return const SizedBox.shrink();
  }
}
