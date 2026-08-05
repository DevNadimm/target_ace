import 'package:flutter/material.dart' hide BackButton;
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';
import 'package:target_ace/features/practice/presentation/widgets/subject_card.dart';
import 'package:target_ace/features/practice/presentation/pages/practice_session_page.dart';

class TopicsPage extends StatelessWidget {
  final SubjectEntity subject;

  static Route route({required SubjectEntity subject}) {
    return MaterialPageRoute(
      builder: (_) => TopicsPage(subject: subject),
    );
  }

  const TopicsPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(subject.name),
      ),
      body: GradientBackground(
        child: subject.topics.isEmpty
            ? Center(
                child: Text(
                  'No topics found.',
                  style: AppFonts.body(color: AppColors.textSecondary),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: subject.topics.length,
                itemBuilder: (context, index) {
                  final topic = subject.topics[index];
                  return SubjectCard(
                    title: topic.name,
                    description: topic.description,
                    practiced: topic.practicedCount,
                    total: topic.totalQuestions,
                    image: topic.imageUrl ?? subject.imageUrl,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        PracticeSessionPage.route(
                          subject: subject,
                          topicId: topic.id,
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}