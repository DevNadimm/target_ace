import 'package:flutter/material.dart' hide BackButton;
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';

import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';
import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';
import 'package:target_ace/features/practice/presentation/widgets/subject_card.dart';
import 'package:target_ace/features/practice/presentation/pages/practice_session_page.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/features/practice/domain/usecases/get_subjects.dart';

class TopicsPage extends StatefulWidget {
  final SubjectEntity subject;

  static Route route({required SubjectEntity subject}) {
    return MaterialPageRoute(
      builder: (_) => TopicsPage(subject: subject),
    );
  }

  const TopicsPage({super.key, required this.subject});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  late SubjectEntity _subject;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _subject = widget.subject;
  }

  Future<void> _refreshData() async {
    final userGoal = await UserLocalDataSource.getUserGoal();
    if (userGoal.isEmpty) return;
    
    if (mounted) setState(() => _isRefreshing = true);

    final res = await sl<GetSubjects>().call(userGoal.toLowerCase());
    res.fold(
      (l) => null,
      (subjects) {
        final updatedSubject = subjects.firstWhere(
          (s) => s.id == _subject.id, 
          orElse: () => _subject
        );
        if (mounted) {
          setState(() {
            _subject = updatedSubject;
            _isRefreshing = false;
          });
        }
      }
    );
    
    if (mounted && _isRefreshing) {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(_subject.name),
      ),
      body: GradientBackground(
        child: Builder(
          builder: (context) {
            if (_subject.topics.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshData,
                color: AppColors.primary,
                backgroundColor: AppColors.card,
                child: const CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateWidget(
                        isCenter: true,
                        title: 'No Topics Found',
                        message: 'There are no topics available for this subject yet.',
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshData,
              color: AppColors.primary,
              backgroundColor: AppColors.card,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _subject.topics.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return SubjectCard(
                      title: 'All Topics',
                      description: 'Practice questions from all topics in ${_subject.name}',
                      practiced: _subject.practicedCount,
                      total: _subject.totalQuestions,
                      isRefreshing: _isRefreshing,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          PracticeSessionPage.route(
                            subject: _subject,
                            topicId: null,
                          ),
                        );
                        _refreshData();
                      },
                    );
                  }
                  
                  final topic = _subject.topics[index - 1];
                  return SubjectCard(
                    title: topic.name,
                    description: topic.description,
                    practiced: topic.practicedCount,
                    total: topic.totalQuestions,
                    isRefreshing: _isRefreshing,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        PracticeSessionPage.route(
                          subject: _subject,
                          topicId: topic.id,
                        ),
                      );
                      _refreshData();
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}