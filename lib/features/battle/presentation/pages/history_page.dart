import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/features/battle/data/repos/battle_repo.dart';
import 'package:target_ace/features/battle/presentation/pages/exam_review_page.dart';
import 'package:target_ace/features/battle/presentation/pages/live_battle_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = true;
  bool _isFetchingQuestions = false;
  List<Map<String, dynamic>> _submissions = [];
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
      final userId = await AppPreferences.getUserId();
      final groupId = await AppPreferences.getActiveGroupId();
      if (userId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Parallel fetch for optimal startup performance
      final results = await Future.wait([
        BattleRepo.getUserSubmissions(userId),
        BattleRepo.getGroupExams(groupId),
      ]);

      final nowUtc = DateTime.now().toUtc();
      final submissionsList = List<Map<String, dynamic>>.from(results[0]);
      final examsList = List<Map<String, dynamic>>.from(results[1]);

      // Filter exams that are live or upcoming
      final List<Map<String, dynamic>> upcomingFiltered = [];
      for (final exam in examsList) {
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
      final fetchedQuestions = await BattleRepo.fetchQuestions(examId);

      setState(() => _isFetchingQuestions = false);

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
      setState(() => _isFetchingQuestions = false);
      if (mounted) {
        AppNotifier.showSnackBar(context, 'Error fetching exam questions: $e', type: MessageType.error);
      }
    }
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
                                // ── 1. Upcoming & Live Section ──
                                if (_upcomingExams.isNotEmpty) ...[
                                  Text(
                                    "Live & Upcoming Battles",
                                    style: AppFonts.heading(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 125,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _upcomingExams.length,
                                      itemBuilder: (context, index) {
                                        final exam = _upcomingExams[index];
                                        final title = exam['title'] as String? ?? 'Mock Exam';
                                        final startTimeStr = exam['start_time'] as String? ?? '';
                                        final duration = exam['duration_minutes'] as int? ?? 15;
                                        
                                        final isLive = _checkIfLive(startTimeStr, duration);
                                        final timeLabel = _formatUpcomingTime(startTimeStr);

                                        return Container(
                                          width: 240,
                                          margin: const EdgeInsets.only(right: 12),
                                          child: InkWell(
                                            onTap: () {
                                              if (isLive) {
                                                Navigator.push(context, LiveBattlePage.route());
                                              } else {
                                                AppNotifier.showSnackBar(
                                                  context, 
                                                  'This exam has not started yet. Please wait until scheduled start.', 
                                                  type: MessageType.info
                                                );
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(16),
                                                                            child: CustomContainer(
                                              padding: const EdgeInsets.all(14),
                                              borderColor: isLive ? AppColors.primary : AppColors.divider,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: isLive 
                                                              ? AppColors.primary.withValues(alpha: 0.15)
                                                              : AppColors.cardAlt,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            if (isLive) ...[
                                                              Container(
                                                                width: 6,
                                                                height: 6,
                                                                decoration: const BoxDecoration(
                                                                  color: Colors.red,
                                                                  shape: BoxShape.circle,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 5),
                                                            ],
                                                              Text(
                                                                isLive ? "LIVE NOW" : "UPCOMING",
                                                                style: AppFonts.body(
                                                                  fontSize: 8.5,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: isLive ? AppColors.primary : AppColors.textSecondary,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text(
                                                        '$duration min',
                                                        style: AppFonts.body(fontSize: 10, color: AppColors.textLight),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AppFonts.heading(
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      HugeIcon(
                                                        icon: HugeIcons.strokeRoundedClock01,
                                                        color: AppColors.primaryLight,
                                                        size: 13,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        child: Text(
                                                          timeLabel,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: AppFonts.body(
                                                            fontSize: 10.5,
                                                            color: AppColors.textSecondary,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Divider(color: AppColors.divider, height: 1),
                                  const SizedBox(height: 20),
                                ],

                                // ── 2. Exam History Section ──
                                Text(
                                  "Exam History",
                                  style: AppFonts.heading(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_submissions.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.divider),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "You have not submitted any exams yet.",
                                        style: AppFonts.body(color: AppColors.textSecondary),
                                      ),
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _submissions.length,
                                    itemBuilder: (context, index) {
                                      final sub = _submissions[index];
                                      final examTitle = sub['exam_title'] as String? ?? 'Mock Exam';
                                      final score = (sub['score'] as num?)?.toDouble() ?? 0.0;
                                      final correct = sub['correct_count'] as int? ?? 0;
                                      final wrong = sub['wrong_count'] as int? ?? 0;
                                      final skipped = sub['unanswered_count'] as int? ?? 0;
                                      final submittedAtStr = sub['submitted_at'] as String? ?? '';
                                      final dateStr = _formatDateTime(submittedAtStr);
                                      final answers = sub['answers'] as List? ?? [];
                                      final examId = sub['exam_id'] as String? ?? '';

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: InkWell(
                                          onTap: () => _navigateToReview(examId, answers),
                                          borderRadius: BorderRadius.circular(20),
                                          child: CustomContainer(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            examTitle,
                                                            style: AppFonts.heading(
                                                              fontSize: 14.5,
                                                              fontWeight: FontWeight.bold,
                                                              color: AppColors.textPrimary,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Row(
                                                            children: [
                                                              HugeIcon(
                                                                icon: HugeIcons.strokeRoundedCalendar01,
                                                                color: AppColors.textLight,
                                                                size: 13,
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                dateStr,
                                                                style: AppFonts.body(
                                                                  fontSize: 11,
                                                                  color: AppColors.textLight,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary.withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                       child: Text(
                                                         '${score.toStringAsFixed(1)}%',
                                                         style: AppFonts.body(
                                                           fontSize: 12,
                                                           fontWeight: FontWeight.bold,
                                                           color: AppColors.primary,
                                                         ),
                                                       ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 14),
                                                Row(
                                                  children: [
                                                    _buildStatPill('Correct', correct, AppColors.success),
                                                    const SizedBox(width: 8),
                                                    _buildStatPill('Wrong', wrong, AppColors.error),
                                                    const SizedBox(width: 8),
                                                    _buildStatPill('Skipped', skipped, AppColors.textLight),
                                                    const Spacer(),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Review',
                                                          style: AppFonts.body(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: AppColors.primary,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 2),
                                                        const Icon(
                                                          Icons.chevron_right_rounded,
                                                          color: AppColors.primary,
                                                          size: 16,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
              if (_isFetchingQuestions)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Loader(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
           Text(
            '$label: $count',
            style: AppFonts.body(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 120.0),
        child: EmptyStateWidget(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedAward01,
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

  String _formatUpcomingTime(String startStr) {
    if (startStr.isEmpty) return '';
    try {
      final start = DateTime.parse(startStr).toLocal();
      final now = DateTime.now();
      final diff = start.difference(now);

      if (diff.isNegative) {
        return "Live Now";
      } else if (diff.inMinutes < 60) {
        return "Starts in ${diff.inMinutes} mins";
      } else if (diff.inHours < 24) {
        return "Starts in ${diff.inHours} hours";
      } else {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final ampm = start.hour >= 12 ? 'PM' : 'AM';
        final hour = start.hour > 12 ? start.hour - 12 : (start.hour == 0 ? 12 : start.hour);
        final minute = start.minute.toString().padLeft(2, '0');
        return '${start.day} ${months[start.month - 1]}, $hour:$minute $ampm';
      }
    } catch (_) {
      return startStr;
    }
  }

  String _formatDateTime(String isoStr) {
    if (isoStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoStr).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $ampm';
    } catch (_) {
      return isoStr;
    }
  }
}
