import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/features/battle/data/repos/battle_repo.dart';
import 'package:target_ace/features/battle/presentation/bloc/live_battle_hub_bloc.dart';
import 'package:target_ace/features/battle/presentation/pages/exam_review_page.dart';
import 'package:target_ace/features/battle/presentation/widgets/live_battle_hero_card.dart';
import 'package:target_ace/features/battle/presentation/widgets/upcoming_battles_section.dart';
import 'package:target_ace/features/battle/presentation/widgets/recent_exam_history_section.dart';

class LiveBattleHubPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const LiveBattleHubPage());

  const LiveBattleHubPage({super.key});

  @override
  State<LiveBattleHubPage> createState() => _LiveBattleHubPageState();
}

class _LiveBattleHubPageState extends State<LiveBattleHubPage> {
  final ValueNotifier<bool> _isFetchingQuestions = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    context.read<LiveBattleHubBloc>().add(LiveBattleHubFetchRequested());
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
      final fetchedQuestions = await BattleRepo.fetchQuestions(examId);
      _isFetchingQuestions.value = false;

      if (mounted) {
        final List<Map<String, dynamic>> userAnswers =
            answers.map((a) => Map<String, dynamic>.from(a as Map)).toList();

        Navigator.push(
          context,
          ExamReviewPage.route(
            questions: fetchedQuestions,
            userAnswers: userAnswers,
          ),
        );
      }
    } catch (e) {
      _isFetchingQuestions.value = false;
      if (mounted) {
        AppNotifier.showSnackBar(context, 'Error fetching exam questions: $e', type: MessageType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              'Live Battle Hub',
              style: AppFonts.heading(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: GradientBackground(
            child: BlocBuilder<LiveBattleHubBloc, LiveBattleHubState>(
              builder: (context, state) {
                if (state is LiveBattleHubLoading || state is LiveBattleHubInitial) {
                  return const Center(child: Loader());
                }

                if (state is LiveBattleHubFailure) {
                  return Center(
                    child: Text(
                      state.errorMessage,
                      style: AppFonts.body(color: AppColors.error),
                    ),
                  );
                }

                if (state is LiveBattleHubSuccess) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<LiveBattleHubBloc>().add(LiveBattleHubFetchRequested(isSilent: true));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LiveBattleHeroCard(
                            state: state,
                            onRefresh: () {
                              context.read<LiveBattleHubBloc>().add(LiveBattleHubFetchRequested(isSilent: true));
                            },
                          ),
                          const SizedBox(height: 24),
                          UpcomingBattlesSection(
                            upcomingExams: state.upcomingExams,
                          ),
                          if (state.upcomingExams.isNotEmpty) const SizedBox(height: 24),
                          RecentExamHistorySection(
                            pastSubmissions: state.pastSubmissions,
                            onReviewTap: _navigateToReview,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
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
    );
  }
}
