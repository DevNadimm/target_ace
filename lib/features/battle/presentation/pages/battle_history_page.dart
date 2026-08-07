import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/messages.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';
import 'package:target_ace/core/shared/widgets/error_state_widget.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';
import 'package:target_ace/features/battle/presentation/pages/battle_review_page.dart';
import 'package:target_ace/features/battle/presentation/widgets/arena/history_detail_bottom_sheet.dart';
import 'package:target_ace/features/battle/presentation/widgets/arena/battle_history_card.dart';
import 'package:target_ace/features/battle/presentation/bloc/history/battle_history_bloc.dart';

class BattleHistoryPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<BattleHistoryBloc>()..add(FetchBattleHistoryEvent()),
          child: const BattleHistoryPage(),
        ),
      );

  const BattleHistoryPage({super.key});

  @override
  State<BattleHistoryPage> createState() => _BattleHistoryPageState();
}

class _BattleHistoryPageState extends State<BattleHistoryPage> {
  void _loadHistory({bool isRefresh = false}) {
    context.read<BattleHistoryBloc>().add(FetchBattleHistoryEvent(isRefresh: isRefresh));
  }

  void _navigateToReview(String examId, List<dynamic> answers) {
    context.read<BattleHistoryBloc>().add(FetchBattleQuestionsEvent(
          examId: examId,
          userAnswers: answers,
        ));
  }

  void _showHistoryDetailSheet(UserSubmissionEntity sub) {
    HistoryDetailBottomSheet.show(
      context,
      submission: sub,
      onReviewTap: _navigateToReview,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Battle History"),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: BlocConsumer<BattleHistoryBloc, BattleHistoryState>(
            listenWhen: (previous, current) {
              return current is BattleHistoryReviewReady ||
                  current is BattleHistoryReviewError;
            },
            listener: (context, state) {
              if (state is BattleHistoryReviewReady) {
                Navigator.push(
                  context,
                  BattleReviewPage.route(
                    questions: state.questions,
                    userAnswers: state.userAnswers.map((a) => Map<String, dynamic>.from(a as Map)).toList(),
                  ),
                );
              } else if (state is BattleHistoryReviewError) {
                AppNotifier.showSnackBar(context, state.message, type: MessageType.error);
              }
            },
            builder: (context, state) {
              final isLoadingMain = state is BattleHistoryInitial || (state is BattleHistoryLoading);
              final isFetchingQuestions = state is BattleHistoryReviewLoading;

              return Stack(
                children: [
                  if (isLoadingMain)
                    const Center(child: Loader())
                  else if (state is BattleHistoryError)
                    ErrorStateWidget(
                      message: state.message,
                      onRetry: () => _loadHistory(isRefresh: true),
                    )
                  else if (state.submissions.isEmpty)
                    RefreshIndicator(
                      onRefresh: () async => _loadHistory(isRefresh: true),
                      color: AppColors.primary,
                      backgroundColor: AppColors.card,
                      child: const CustomScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyStateWidget(
                              isCenter: true,
                              title: AppMessages.emptyBattleHistoryTitle,
                              message: AppMessages.emptyBattleHistoryMessage,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    RefreshIndicator(
                      onRefresh: () async => _loadHistory(isRefresh: true),
                      backgroundColor: AppColors.card,
                      color: AppColors.primary,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                        itemCount: state.submissions.length,
                        itemBuilder: (context, index) {
                          final sub = state.submissions[index];
                          return BattleHistoryCard(
                            submission: sub,
                            onTap: () => _showHistoryDetailSheet(sub),
                          );
                        },
                      ),
                    ),

                  if (isFetchingQuestions)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(child: Loader()),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
