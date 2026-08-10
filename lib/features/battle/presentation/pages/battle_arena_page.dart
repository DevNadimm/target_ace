import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/shared/widgets/error_state_widget.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battle_questions.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';
import 'package:target_ace/features/battle/presentation/bloc/arena/battle_arena_bloc.dart';
import 'package:target_ace/features/battle/presentation/pages/battle_review_page.dart';
import 'package:target_ace/features/battle/presentation/widgets/arena/battle_history_section.dart';
import 'package:target_ace/features/battle/presentation/widgets/arena/upcoming_battles_section.dart';
import 'package:target_ace/features/battle/presentation/widgets/arena/featured_battle_card.dart';

class BattleArenaPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const BattleArenaPage());

  const BattleArenaPage({super.key});

  @override
  State<BattleArenaPage> createState() => _BattleArenaPageState();
}

class _BattleArenaPageState extends State<BattleArenaPage> {
  final ValueNotifier<bool> _isFetchingQuestions = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    context.read<BattleArenaBloc>().add(BattleArenaFetchRequested());
  }

  @override
  void dispose() {
    _isFetchingQuestions.dispose();
    super.dispose();
  }

  Future<void> _navigateToReview(String examId, List<dynamic> answers) async {
    if (_isFetchingQuestions.value) return;
    _isFetchingQuestions.value = true;

    try {
      final getBattleQuestions = sl<GetBattleQuestions>();
      final eitherQuestions = await getBattleQuestions(examId);

      List<QuestionEntity> fetchedQuestions = [];
      await eitherQuestions.fold(
        (failure) async => throw Exception(failure.message),
        (questions) async => fetchedQuestions = questions,
      );
      _isFetchingQuestions.value = false;

      if (mounted) {
        final List<Map<String, dynamic>> userAnswers = answers
            .map((a) => Map<String, dynamic>.from(a as Map))
            .toList();

        Navigator.push(
          context,
          BattleReviewPage.route(
            questions: fetchedQuestions,
            userAnswers: userAnswers,
          ),
        );
      }
    } catch (e) {
      _isFetchingQuestions.value = false;
      if (mounted) {
        AppNotifier.showSnackBar(
          context,
          'Error fetching exam questions: $e',
          type: MessageType.error,
        );
      }
    }
  }

  bool _hasActiveFeatured(BattleArenaSuccess state) {
    final activeExam = state.todayExams.isNotEmpty
        ? state.todayExams.first
        : (state.upcomingExams.isNotEmpty ? state.upcomingExams.first : null);
    if (activeExam == null) return false;
    if (activeExam.startTime.isNotEmpty) {
      final endTime = DateTime.parse(activeExam.startTime).toLocal().add(
        Duration(minutes: activeExam.durationMinutes),
      );
      if (DateTime.now().isAfter(endTime)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Battle Arena')),
      body: Stack(
        children: [
          GradientBackground(
            child: BlocBuilder<BattleArenaBloc, BattleArenaState>(
              builder: (context, state) {
                if (state is BattleArenaLoading || state is BattleArenaInitial) {
                  return const Center(child: Loader());
                }

                if (state is BattleArenaFailure) {
                  return ErrorStateWidget(
                    message: state.errorMessage, 
                    errorType: state.errorType,
                    onRetry: () => context.read<BattleArenaBloc>().add(
                      BattleArenaFetchRequested(isSilent: true),
                    ),
                  );
                }

                if (state is BattleArenaSuccess) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      final bloc = context.read<BattleArenaBloc>();
                      bloc.add(
                        BattleArenaFetchRequested(isSilent: true),
                      );
                      await bloc.stream.firstWhere((state) =>
                          state is BattleArenaSuccess ||
                          state is BattleArenaFailure);
                    },
                    color: AppColors.primary,
                    backgroundColor: AppColors.card,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          FeaturedBattleCard(
                            state: state,
                            onRefresh: () {
                              context.read<BattleArenaBloc>().add(
                                BattleArenaFetchRequested(isSilent: true),
                              );
                            },
                          ),
                          if (_hasActiveFeatured(state))
                            const SizedBox(height: 20),
                          UpcomingBattlesSection(
                            upcomingExams: state.upcomingExams,
                          ),
                          const SizedBox(height: 20),
                          BattleHistorySection(
                            pastSubmissions: state.pastSubmissions,
                            onReviewTap: _navigateToReview,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Loading Overlay
          ValueListenableBuilder<bool>(
            valueListenable: _isFetchingQuestions,
            builder: (context, isLoading, _) {
              if (!isLoading) return const SizedBox.shrink();
              return Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(child: Loader()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}