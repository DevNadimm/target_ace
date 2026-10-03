import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/shared/widgets/error_state_widget.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/battle/presentation/bloc/arena/battle_arena_bloc.dart';
import 'package:target_ace/features/battle/presentation/pages/battle_review_page.dart';
import 'package:target_ace/features/battle/presentation/pages/live_battle_page.dart';
import 'package:target_ace/features/battle/presentation/widgets/arena/battle_history_section.dart';
import 'package:target_ace/features/home/presentation/bloc/home_bloc.dart';
import 'package:target_ace/features/battle/presentation/widgets/arena/upcoming_battles_section.dart';
import 'package:target_ace/features/battle/presentation/widgets/arena/featured_battle_card.dart';
import 'package:target_ace/features/subscription/presentation/widgets/subscription_paywall_bottom_sheet.dart';

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

  void _navigateToReview(String examId, List<dynamic> answers) {
    context.read<BattleArenaBloc>().add(
          BattleArenaReviewRequested(examId, answers),
        );
  }

  bool _hasActiveFeatured(BattleArenaSuccess state) {
    final activeExam = state.todayExams.isNotEmpty
        ? state.todayExams.first
        : null;
    if (activeExam == null) return false;
    
    // Ignore exams in past for featured section if past duration
    final endTime = DateTime.parse(activeExam.startTime).toUtc().add(
      Duration(minutes: activeExam.durationMinutes),
    );
    return DateTime.now().toUtc().isBefore(endTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Battle Arena')),
      body: BlocListener<BattleArenaBloc, BattleArenaState>(
        listener: (context, state) {
          if (state is BattleArenaAccessDenied) {
            SubscriptionPaywallBottomSheet.show(
              context, 
              status: state.status,
              customTitle: 'Live Battle Access',
              customDescription: 'Live daily battles require an active TargetAce membership. Verify your account status to join the arena.',
              customButtonText: 'Activate Membership',
            );
          } else if (state is BattleArenaReviewAccessGranted) {
            final List<Map<String, dynamic>> userAnswers = state.answers
                .map((a) => Map<String, dynamic>.from(a as Map))
                .toList();
            Navigator.of(context).push(
              BattleReviewPage.route(
                examId: state.examId,
                userAnswers: userAnswers,
              ),
            );
          } else if (state is BattleArenaEnterAccessGranted) {
            Navigator.of(context).push(LiveBattlePage.route()).then((_) {
              if (context.mounted) {
                context.read<BattleArenaBloc>().add(BattleArenaFetchRequested(isSilent: true, force: true));
                context.read<HomeBloc>().add(HomeFetchRequested(isSilent: true, force: true));
              }
            });
          }
        },
        child: Stack(
          children: [
            GradientBackground(
              child: BlocBuilder<BattleArenaBloc, BattleArenaState>(
                buildWhen: (previous, current) {
                  // Only rebuild on states that have UI representation
                  return current is BattleArenaInitial ||
                         current is BattleArenaLoading ||
                         current is BattleArenaFailure ||
                         current is BattleArenaSuccess;
                },
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
                          BattleArenaFetchRequested(isSilent: true, force: true),
                        );
                        await bloc.stream.firstWhere((s) =>
                            s is BattleArenaSuccess ||
                            s is BattleArenaFailure);
                      },
                      color: AppColors.primary,
                      backgroundColor: AppColors.card,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
      ),
    );
  }
}