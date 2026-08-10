import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/messages.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';
import 'package:target_ace/core/shared/widgets/error_state_widget.dart';
import 'package:target_ace/core/services/service_locator.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<BattleHistoryBloc>().add(FetchMoreBattleHistoryEvent());
    }
  }

  void _loadHistory({bool isRefresh = false}) {
    context.read<BattleHistoryBloc>().add(FetchBattleHistoryEvent(isRefresh: isRefresh));
  }

  void _navigateToReview(String examId, List<dynamic> answers) {
    final List<Map<String, dynamic>> userAnswers = answers
        .map((a) => Map<String, dynamic>.from(a as Map))
        .toList();

    Navigator.of(context).push(
      BattleReviewPage.route(
        examId: examId,
        userAnswers: userAnswers,
      ),
    );
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
          child: BlocBuilder<BattleHistoryBloc, BattleHistoryState>(
            builder: (context, state) {
              final isLoadingMain = state is BattleHistoryInitial || (state is BattleHistoryLoading);

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
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                        itemCount: state.submissions.length + (state is BattleHistoryLoaded && state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.submissions.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Loader(
                                isShowContainer: false,
                              ),
                            );
                          }
                          
                          final sub = state.submissions[index];
                          return BattleHistoryCard(
                            submission: sub,
                            onTap: () => _showHistoryDetailSheet(sub),
                          );
                        },
                      ),
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
