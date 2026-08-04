import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';
import 'package:target_ace/features/practice/presentation/bloc/topics/practice_topics_cubit.dart';
import 'package:target_ace/features/practice/presentation/pages/live_practice_page.dart';

class TopicSelectionPage extends StatelessWidget {
  final SubjectEntity subject;

  static Route route({required SubjectEntity subject}) {
    return MaterialPageRoute(
      builder: (_) => TopicSelectionPage(subject: subject),
    );
  }

  const TopicSelectionPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PracticeTopicsCubit>()..fetchTopics(subject.id),
      child: TopicSelectionView(subject: subject),
    );
  }
}

class TopicSelectionView extends StatelessWidget {
  final SubjectEntity subject;

  const TopicSelectionView({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(subject.name),
      ),
      body: GradientBackground(
        child: BlocBuilder<PracticeTopicsCubit, PracticeTopicsState>(
          builder: (context, state) {
            if (state is PracticeTopicsLoading || state is PracticeTopicsInitial) {
              return const Center(child: Loader());
            }

            if (state is PracticeTopicsError) {
              return Center(
                child: Text(
                  state.message,
                  style: AppFonts.body(color: AppColors.error),
                ),
              );
            }

            if (state is PracticeTopicsLoaded) {
              final topics = state.topics;
              
              if (topics.isEmpty) {
                return Center(
                  child: Text(
                    'No topics found for this subject.',
                    style: AppFonts.body(color: AppColors.textSecondary),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: topics.length + 1, // +1 for the Practice All button
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            LivePracticePage.route(subject: subject),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: CustomContainer(
                          padding: const EdgeInsets.all(16),
                          borderColor: AppColors.primary,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedTarget01,
                                  color: AppColors.background,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Practice All Topics',
                                      style: AppFonts.heading(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Mix questions from all chapters',
                                      style: AppFonts.body(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final topic = topics[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          LivePracticePage.route(
                            subject: subject,
                            topicId: topic.id,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: CustomContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedBookOpen01,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topic.name,
                                    style: AppFonts.heading(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (topic.description != null && topic.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      topic.description!,
                                      style: AppFonts.body(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
