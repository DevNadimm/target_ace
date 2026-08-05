import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/app_list_tile.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/utils/helpers/date_formatter.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';
import 'package:target_ace/core/shared/widgets/section_empty_state.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/features/battle/domain/usecases/get_user_submissions.dart';
import 'package:target_ace/features/battle/domain/usecases/get_group_battles.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battle_questions.dart';
import 'package:target_ace/features/battle/data/models/battle_model.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';
import 'package:target_ace/features/battle/presentation/pages/battle_review_page.dart';
import 'package:target_ace/features/battle/presentation/pages/live_battle_page.dart';
import 'package:target_ace/features/battle/presentation/widgets/arena/history_detail_bottom_sheet.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

class BattleHistoryPage extends StatefulWidget {
  const BattleHistoryPage({super.key});

  @override
  State<BattleHistoryPage> createState() => _BattleHistoryPageState();
}

class _BattleHistoryPageState extends State<BattleHistoryPage> {
  bool _isLoading = true;
  bool _isFetchingQuestions = false;
  List<UserSubmissionEntity> _submissions = [];
  List<Map<String, dynamic>> _upcomingExams = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userId = await UserLocalDataSource.getUserId();
      final groupId = await UserLocalDataSource.getUserGroupId();
      if (userId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final getUserSubmissions = sl<GetUserSubmissions>();
      final getGroupBattles = sl<GetGroupBattles>();

      final results = await Future.wait([
        getUserSubmissions(userId),
        getGroupBattles(groupId),
      ]);

      final submissionsRes = results[0] as Either<Failure, List<UserSubmissionEntity>>;
      final examsRes = results[1] as Either<Failure, List<BattleEntity>>;

      final nowUtc = DateTime.now().toUtc();
      List<UserSubmissionEntity> submissionsList = [];
      List<BattleEntity> examsList = [];

      await submissionsRes.fold(
        (failure) async => throw Exception(failure.message),
        (submissions) async => submissionsList = submissions,
      );

      await examsRes.fold(
        (failure) async => throw Exception(failure.message),
        (exams) async => examsList = exams,
      );

      final examsMaps = examsList.map((e) => (e as BattleModel).toJson()).toList();

      final List<Map<String, dynamic>> upcomingFiltered = [];
      for (final exam in examsMaps) {
        final startTime = DateTime.parse(exam['start_time'] as String).toUtc();
        final durationMins = exam['duration_minutes'] as int? ?? 15;
        final endTime = startTime.add(Duration(minutes: durationMins));

        if (endTime.isAfter(nowUtc)) {
          upcomingFiltered.add(exam);
        }
      }

      if (mounted) {
        setState(() {
          _submissions = submissionsList;
          _upcomingExams = upcomingFiltered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppNotifier.showSnackBar(context, 'Error loading history: $e', type: MessageType.error);
      }
    }
  }

  Future<void> _navigateToReview(String examId, List<dynamic> answers) async {
    if (_isFetchingQuestions) return;
    setState(() => _isFetchingQuestions = true);

    try {
      final getBattleQuestions = sl<GetBattleQuestions>();
      final eitherQuestions = await getBattleQuestions(examId);

      List<QuestionEntity> fetchedQuestions = [];
      await eitherQuestions.fold(
        (failure) async => throw Exception(failure.message),
        (questions) async => fetchedQuestions = questions,
      );

      setState(() => _isFetchingQuestions = false);

      if (mounted) {
        final List<Map<String, dynamic>> userAnswers =
            answers.map((a) => Map<String, dynamic>.from(a as Map)).toList();

        Navigator.push(
          context,
          BattleReviewPage.route(
            questions: fetchedQuestions,
            userAnswers: userAnswers,
          ),
        );
      }
    } catch (e) {
      setState(() => _isFetchingQuestions = false);
      if (mounted) {
        AppNotifier.showSnackBar(context, 'Error fetching exam questions: $e', type: MessageType.error);
      }
    }
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
    final showEmptyState = _submissions.isEmpty && _upcomingExams.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Exam History"),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              _isLoading
                  ? const Center(child: Loader())
                  : showEmptyState
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          backgroundColor: AppColors.card,
                          color: AppColors.primary,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Upcoming & Live + History in one CustomContainer ──
                                CustomContainer(
                                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // ── 1. Upcoming & Live ──
                                      if (_upcomingExams.isNotEmpty) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: _SectionHeader(label: 'LIVE & UPCOMING'),
                                        ),
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: _upcomingExams.length,
                                          separatorBuilder: (_, _) => const CustomDivider.dotted(),
                                          itemBuilder: (context, index) {
                                            final exam = _upcomingExams[index];
                                            final title = exam['title'] as String? ?? 'Mock Exam';
                                            final startTimeStr = exam['start_time'] as String? ?? '';
                                            final duration = exam['duration_minutes'] as int? ?? 15;
                                            final isLive = _checkIfLive(startTimeStr, duration);
                                            final timeLabel = DateFormatter.formatUpcomingTime(startTimeStr);

                                            return AppListTile(
                                              onTap: () {
                                                if (isLive) {
                                                  Navigator.push(context, LiveBattlePage.route());
                                                } else {
                                                  AppNotifier.showSnackBar(
                                                    context,
                                                    'This exam has not started yet.',
                                                    type: MessageType.info,
                                                  );
                                                }
                                              },
                                              customIcon: isLive
                                                  ? Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    )
                                                  : null,
                                              icon: isLive ? null : HugeIcons.strokeRoundedCalendar04,
                                              title: title,
                                              subtitle: timeLabel,
                                              trailing: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: isLive
                                                      ? AppColors.primary.withValues(alpha: 0.15)
                                                      : AppColors.cardAlt,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  isLive ? 'LIVE' : '$duration min',
                                                  style: AppFonts.body(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: isLive ? AppColors.primary : AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // Dotted divider between sections
                                        const CustomDivider.dotted(),
                                        const SizedBox(height: 16),
                                      ],

                                      // ── 2. Exam History ──
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: _SectionHeader(label: 'EXAM HISTORY'),
                                      ),
                                      const SizedBox(height: 4),

                                      if (_submissions.isEmpty)
                                        _buildHistoryEmpty()
                                      else
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: _submissions.length,
                                          separatorBuilder: (_, _) => const CustomDivider.dotted(),
                                          itemBuilder: (context, index) {
                                            final sub = _submissions[index];
                                            return _HistoryItem(
                                              sub: sub,
                                              onTap: () => _showHistoryDetailSheet(sub),
                                            );
                                          },
                                        ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
              if (_isFetchingQuestions)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(child: Loader()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryEmpty() {
    return const SectionEmptyState(
      message: 'No exam history yet.',
      icon: HugeIcons.strokeRoundedInvestigation,
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 120.0),
        child: EmptyStateWidget(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedChampion,
            color: AppColors.primary,
            size: 64,
          ),
          title: 'No Completed Exams',
          message: 'Participate in live battles to see your performance history and detailed reviews here!',
        ),
      ),
    );
  }

  bool _checkIfLive(String startTimeStr, int durationMins) {
    if (startTimeStr.isEmpty) return false;
    try {
      final nowUtc = DateTime.now().toUtc();
      final startTime = DateTime.parse(startTimeStr).toUtc();
      final endTime = startTime.add(Duration(minutes: durationMins));
      return nowUtc.isAfter(startTime) && nowUtc.isBefore(endTime);
    } catch (_) {
      return false;
    }
  }
}

// ─── Shared Section Header ───────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: AppFonts.body(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ─── History Item ────────────────────────────────────────────────────────────

class _HistoryItem extends StatelessWidget {
  final UserSubmissionEntity sub;
  final VoidCallback onTap;

  const _HistoryItem({required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = sub.examTitle;
    final score = sub.score;
    final totalParticipants = sub.totalParticipants > 0 ? sub.totalParticipants : 1;
    final rank = sub.rank > 0 ? sub.rank : 1;



    final String scoreDisplay = score == score.roundToDouble()
        ? score.toStringAsFixed(0)
        : score.toStringAsFixed(1);

    return AppListTile(
      onTap: onTap,
      icon: HugeIcons.strokeRoundedChampion,
      title: title,
      subtitle: '$scoreDisplay pts  •  Rank $rank/$totalParticipants',
    );
  }
}
