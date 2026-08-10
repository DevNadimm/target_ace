import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';
import 'package:target_ace/features/practice/presentation/bloc/session/practice_session_cubit.dart';
import 'package:target_ace/features/practice/presentation/widgets/question_practice_view.dart';
import 'package:target_ace/features/practice/presentation/widgets/report_error_bottom_sheet.dart';

class PracticeSessionPage extends StatelessWidget {
  final SubjectEntity subject;
  final String? topicId;

  static Route route({required SubjectEntity subject, String? topicId}) {
    return MaterialPageRoute(
      builder: (_) => PracticeSessionPage(subject: subject, topicId: topicId),
    );
  }

  const PracticeSessionPage({super.key, required this.subject, this.topicId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PracticeSessionCubit>()..loadSession(
        subjectId: subject.id,
        topicId: topicId,
      ),
      child: PracticeSessionPageView(subject: subject),
    );
  }
}

class PracticeSessionPageView extends StatefulWidget {
  final SubjectEntity subject;
  const PracticeSessionPageView({super.key, required this.subject});

  @override
  State<PracticeSessionPageView> createState() => _PracticeSessionPageViewState();
}

class _PracticeSessionPageViewState extends State<PracticeSessionPageView> {
  void _handlePop(bool didPop) {
    if (didPop) return;
    
    // Fire and forget the sync process
    context.read<PracticeSessionCubit>().syncProgress();
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic result) => _handlePop(didPop),
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(widget.subject.name),
        ),
        body: GradientBackground(child: BlocBuilder<PracticeSessionCubit, PracticeSessionState>(
          builder: (context, state) {
            final questions = state.questions;

            return Column(
              children: [
                // 2. Main Content Area
                Expanded(
                  child: Builder(
                    builder: (context) {
                      // Initial Loader (Before questions or topics are fetched for the first time)
                      if (state.status == PracticeSessionStatus.loading && questions.isEmpty) {
                        return const Center(child: Loader());
                      }

                      // Failure State
                      if (state.status == PracticeSessionStatus.failure && questions.isEmpty) {
                        return Center(
                          child: Text(
                            state.errorMessage ?? 'An error occurred',
                            style: AppFonts.body(color: AppColors.error),
                          ),
                        );
                      }

                      // Empty Questions State (Centered)
                      if (questions.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CustomContainer(
                              child: EmptyStateWidget(
                                isCenter: false, // Prevent full height stretch
                                icon: SvgPicture.asset(
                                  Assets.archiveOutlined,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.primaryLight,
                                    BlendMode.srcIn,
                                  ),
                                  height: 70,
                                ),
                                title: 'No Questions Available',
                                message: 'No practice questions have been uploaded for this chapter yet. Please try another chapter.',
                              ),
                            ),
                          ),
                        );
                      }

                      // Active Practice View
                      return Stack(
                        children: [
                          QuestionPracticeView(
                            questions: questions,
                            currentIndex: state.currentIndex,
                            selectedOption: state.selectedOption,
                            isBookmarked: state.isBookmarked(questions[state.currentIndex].id),
                            previousAttemptIsCorrect: state.previousAttempts[questions[state.currentIndex].id],
                            onOptionSelected: (option) {
                              context.read<PracticeSessionCubit>().selectOption(option);
                            },
                            onToggleBookmark: () {
                              final q = state.currentQuestion;
                              if (q != null) {
                                context.read<PracticeSessionCubit>().toggleBookmark(q.id);
                              }
                            },
                            onReportError: () {
                              final q = state.currentQuestion;
                              if (q != null) {
                                ReportErrorBottomSheet.show(
                                  context,
                                  questionId: q.id,
                                  onSubmit: (reportText) async {
                                    await context.read<PracticeSessionCubit>().submitReport(q.id, reportText);
                                    if (context.mounted) {
                                      AppNotifier.showSnackBar(
                                        context,
                                        'Report submitted successfully! Thank you for your feedback.',
                                        type: MessageType.success,
                                      );
                                    }
                                  },
                                );
                              }
                            },
                            onNext: () {
                              context.read<PracticeSessionCubit>().nextQuestion();
                            },
                            onPrevious: () {
                              context.read<PracticeSessionCubit>().previousQuestion();
                            },
                          ),
                          // Transparent loading overlay to prevent interface flicker when switching chapters
                          if (state.status == PracticeSessionStatus.loading)
                            Container(
                              color: Colors.black.withValues(alpha: 0.25),
                              child: const Center(child: Loader()),
                            ),
                        ],
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