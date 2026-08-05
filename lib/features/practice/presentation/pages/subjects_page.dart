import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';

import 'package:target_ace/features/practice/presentation/bloc/subjects/practice_subjects_cubit.dart';
import 'package:target_ace/features/practice/presentation/pages/topics_page.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/features/practice/presentation/widgets/subject_card.dart';

class SubjectsPage extends StatelessWidget {
  final bool showBackButton;

  static Route route({
    bool showBackButton = true,
  }) => MaterialPageRoute(
    builder: (_) => SubjectsPage(
      showBackButton: showBackButton,
    ),
  );

  const SubjectsPage({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PracticeSubjectsCubit>(),
      child: SubjectsPageView(
        showBackButton: showBackButton,
      ),
    );
  }
}

class SubjectsPageView extends StatefulWidget {
  final bool showBackButton;

  const SubjectsPageView({
    super.key,
    required this.showBackButton,
  });

  @override
  State<SubjectsPageView> createState() => _SubjectsPageViewState();
}

class _SubjectsPageViewState extends State<SubjectsPageView> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userGoal = await UserLocalDataSource.getUserGoal();
    if (userGoal.isEmpty) {
      debugPrint(
        'SubjectsPageView: active battle group configuration is empty, skipping subject fetch.',
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
        title: const Text('Subjects'),
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

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];

                return SubjectCard(
                  title: subject.name,
                  description: subject.description,
                  practiced: subject.practicedCount,
                  total: subject.totalQuestions,
                  image: subject.imageUrl,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      TopicsPage.route(subject: subject),
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