import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/core/shared/widgets/fade_wave_animation.dart';
import 'package:target_ace/core/shared/widgets/error_state_widget.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';
import 'package:target_ace/features/practice/presentation/bloc/dashboard/practice_dashboard_cubit.dart';
import 'package:target_ace/features/practice/presentation/pages/subjects_page.dart';
import 'package:target_ace/features/practice/presentation/pages/bookmarked_questions_page.dart';
import 'package:target_ace/features/practice/presentation/pages/practice_session_page.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/components/under_development_widget.dart';

class PracticeDashboardPage extends StatelessWidget {
  const PracticeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<PracticeDashboardCubit>()..loadDashboardData(),
      child: const PracticeDashboardView(),
    );
  }
}

class PracticeDashboardView extends StatefulWidget {
  const PracticeDashboardView({super.key});

  @override
  State<PracticeDashboardView> createState() => _PracticeDashboardViewState();
}

class _PracticeDashboardViewState extends State<PracticeDashboardView> {
  bool _showSyncingAnim = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Practice'),
      ),
      body: GradientBackground(
        child: AppConfig.isPracticeUnderDevelopment
            ? const UnderDevelopmentWidget()
            : RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.card,
                onRefresh: () async {
                  await context.read<PracticeDashboardCubit>().loadDashboardData(force: true);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // 1. Overall Practice Stats Banner
                BlocConsumer<PracticeDashboardCubit, PracticeDashboardState>(
                  listener: (context, state) {
                    if (state is PracticeDashboardLoaded) {
                      if (state.isRefreshing && !_showSyncingAnim) {
                        setState(() => _showSyncingAnim = true);
                      } else if (!state.isRefreshing && _showSyncingAnim) {
                        // Enforce a minimum animation duration so it looks nice
                        Future.delayed(const Duration(milliseconds: 1500), () {
                          if (mounted) setState(() => _showSyncingAnim = false);
                        });
                      }
                    }
                  },
                  builder: (context, state) {
                    int attempted = 0;
                    double accuracy = 0.0;
                    int today = 0;

                    if (state is PracticeDashboardLoaded) {
                      attempted = state.totalAttempted;
                      accuracy = state.accuracyRate;
                      today = state.todayCount;
                    }

                    if (state is PracticeDashboardLoading) {
                      return const CustomContainer(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Loader(isShowContainer: false)),
                      );
                    }

                    if (state is PracticeDashboardError) {
                      return ErrorStateWidget(
                        message: state.message,
                        errorType: state.errorType,
                        onRetry: () => context.read<PracticeDashboardCubit>().loadDashboardData(force: true, isSilent: true),
                      );
                    }

                    return CustomContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
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
                                    'PRACTICE OVERVIEW',
                                    style: AppFonts.body(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              if (_showSyncingAnim)
                                FadeWaveAnimation(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.sync,
                                        color: AppColors.primary,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'SYNCING...',
                                        style: AppFonts.body(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Practiced', '$attempted', _showSyncingAnim),
                              _buildVerticalDivider(),
                              _buildStatItem('Accuracy', '${accuracy.toStringAsFixed(0)}%', _showSyncingAnim),
                              _buildVerticalDivider(),
                              _buildStatItem('Today', '$today', _showSyncingAnim),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 2. Continue Last Practice Session (if available)
                BlocBuilder<PracticeDashboardCubit, PracticeDashboardState>(
                  builder: (context, state) {
                    if (state is PracticeDashboardLoaded &&
                        state.lastSubjectId != null &&
                        state.lastSubjectName != null) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            final subject = SubjectEntity(
                              id: state.lastSubjectId!,
                              groupId: '',
                              name: state.lastSubjectName!,
                              displayOrder: 0,
                            );
                            Navigator.push(
                              context,
                              PracticeSessionPage.route(subject: subject),
                            ).then((_) {
                              if (context.mounted) {
                                context.read<PracticeDashboardCubit>().loadDashboardData(force: true);
                              }
                            });
                          },
                          child: CustomContainer(
                            padding: const EdgeInsets.all(16),
                            borderColor: AppColors.primary.withValues(alpha: 0.3),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const HugeIcon(
                                    icon: HugeIcons.strokeRoundedBookOpen01,
                                    color: AppColors.background,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Continue Practice',
                                        style: AppFonts.body(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (_showSyncingAnim)
                                        FadeWaveAnimation(
                                          child: Text(
                                            state.lastSubjectName!,
                                            style: AppFonts.body(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        )
                                      else
                                        Text(
                                          state.lastSubjectName!,
                                          style: AppFonts.body(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // 3. Practice Modes Menu
                CustomContainer(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
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
                              'PRACTICE MODES',
                              style: AppFonts.body(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _PracticeModeTile(
                        icon: HugeIcons.strokeRoundedBookOpen01,
                        title: "Subject Practice",
                        subtitle: "Practice by subject and chapter",
                        color: AppColors.primary,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            SubjectsPage.route(
                              showBackButton: true,
                            ),
                          );
                          if (context.mounted) {
                            context.read<PracticeDashboardCubit>().loadDashboardData(force: true);
                          }
                        },
                      ),
                      const CustomDivider.dotted(),
                      _PracticeModeTile(
                        icon: HugeIcons.strokeRoundedBookmark02,
                        title: "Bookmarked Questions",
                        subtitle: "Review your saved questions",
                        color: AppColors.warning,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            BookmarkedQuestionsPage.route(),
                          );
                          if (context.mounted) {
                            context.read<PracticeDashboardCubit>().loadDashboardData(force: true);
                          }
                        },
                      ),
                      const CustomDivider.dotted(),
                      _PracticeModeTile(
                        icon: HugeIcons.strokeRoundedAlertCircle,
                        title: "Weak Topics",
                        subtitle: "Revise topics where you make the most mistakes",
                        color: AppColors.error,
                        onTap: () {
                          AppNotifier.showSnackBar(
                            context,
                            "Weak Topics analysis coming soon!",
                            type: MessageType.info,
                          );
                        },
                      ),
                      const CustomDivider.dotted(),
                      _PracticeModeTile(
                        icon: HugeIcons.strokeRoundedMagicWand01,
                        title: "Random Quiz",
                        subtitle: "Solve random questions from all subjects",
                        color: AppColors.success,
                        onTap: () {
                          AppNotifier.showSnackBar(
                            context,
                            "Random Quiz coming soon!",
                            type: MessageType.info,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isRefreshing) {
    Widget content = Column(
      children: [
        Text(
          value,
          style: AppFonts.body(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppFonts.body(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );

    if (isRefreshing) {
      return FadeWaveAnimation(
        child: content,
      );
    }
    
    return content;
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 28,
      width: 1,
      color: AppColors.divider,
    );
  }
}

class _PracticeModeTile extends StatefulWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PracticeModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PracticeModeTile> createState() => _PracticeModeTileState();
}

class _PracticeModeTileState extends State<_PracticeModeTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value && mounted) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _pressed ? widget.color.withValues(alpha: 0.05) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(
                  icon: widget.icon,
                  size: 20,
                  color: widget.color,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: AppFonts.body(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}