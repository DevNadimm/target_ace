import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';
import 'package:target_ace/features/practice/presentation/bloc/hub/practice_hub_cubit.dart';
import 'package:target_ace/features/practice/presentation/bloc/subjects/practice_subjects_cubit.dart';
import 'package:target_ace/features/practice/presentation/pages/topic_selection_page.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/features/practice/presentation/widgets/subject_card.dart';

class SubjectListPage extends StatelessWidget {
  final bool showBackButton;

  static Route route({
    bool showBackButton = true,
  }) => MaterialPageRoute(
    builder: (_) => SubjectListPage(
      showBackButton: showBackButton,
    ),
  );

  const SubjectListPage({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<PracticeSubjectsCubit>(),
        ),
        BlocProvider.value(
          value: sl<PracticeHubCubit>()..loadHubData(),
        ),
      ],
      child: PracticePageView(
        showBackButton: showBackButton,
      ),
    );
  }
}

class PracticePageView extends StatefulWidget {
  final bool showBackButton;

  const PracticePageView({
    super.key,
    required this.showBackButton,
  });

  @override
  State<PracticePageView> createState() => _PracticePageViewState();
}

class _PracticePageViewState extends State<PracticePageView> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userGoal = await UserLocalDataSource.getUserGoal();
    if (userGoal.isEmpty) {
      debugPrint(
        'PracticePageView: active battle group configuration is empty, skipping subject fetch.',
      );
      return;
    }
    if (mounted) {
      context.read<PracticeSubjectsCubit>().fetchSubjects(
        userGoal.toLowerCase(),
      );
    }
  }

  // Removed _getIcon as we use imageUrl now

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.showBackButton ? const BackButton() : null,
        title: const Text('Subject Practice'),
      ),
      body: GradientBackground(
        child: BlocBuilder<PracticeSubjectsCubit, PracticeSubjectsState>(
          builder: (context, state) {
            if (state is PracticeSubjectsLoading ||
                state is PracticeSubjectsInitial) {
              return const Center(child: Loader());
            }

            if (state is PracticeSubjectsFailure) {
              return Center(
                child: Text(
                  state.error,
                  style: AppFonts.body(color: AppColors.error),
                ),
              );
            }

            final subjectsData = (state as PracticeSubjectsLoaded).subjects;
            final List<SubjectEntity> subjects = subjectsData;

            if (subjects.isEmpty) {
              return Center(
                child: Text(
                  'No subjects found.',
                  style: AppFonts.body(color: AppColors.textSecondary),
                ),
              );
            }

            return BlocBuilder<PracticeHubCubit, PracticeHubState>(
              builder: (context, hubState) {
                final List<dynamic> currentSubjectProgress = 
                    hubState is PracticeHubLoaded ? hubState.subjectProgress : [];

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return SubjectCard(
                      title: subject.name,
                      image: subject.imageUrl,
                      subtitle: Builder(
                        builder: (context) {
                          final progressData = currentSubjectProgress
                              .cast<Map<String, dynamic>>()
                              .firstWhere(
                                (p) => p['subject_id'] == subject.id,
                                orElse: () => {
                                  'practiced_count': 0,
                                  'total_questions': 0,
                                },
                              );
                      final int practiced =
                          progressData['practiced_count'] ?? 0;
                      final int total = progressData['total_questions'] ?? 0;

                      final double progress = total > 0 ? practiced / total : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (subject.description != null && subject.description!.isNotEmpty) ...[
                              Text(
                                subject.description!,
                                style: AppFonts.body(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: AppColors.divider,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$practiced / $total questions',
                              style: AppFonts.body(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      TopicSelectionPage.route(subject: subject),
                    );
                  },
                );
              },
            );
              },
            );
          },
        ),
      ),
    );
  }
}
