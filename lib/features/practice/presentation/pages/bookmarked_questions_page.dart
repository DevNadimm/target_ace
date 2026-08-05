import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_icon_button.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/widgets/app_confirmation_dialog.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/practice/presentation/bloc/bookmarks/bookmarked_questions_cubit.dart';
import 'package:target_ace/features/practice/presentation/widgets/question_practice_view.dart';

class BookmarkedQuestionsPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute(builder: (_) => const BookmarkedQuestionsPage());

  const BookmarkedQuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookmarkedQuestionsCubit>()..loadBookmarks(),
      child: const BookmarkedQuestionsView(),
    );
  }
}

class BookmarkedQuestionsView extends StatelessWidget {
  const BookmarkedQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Bookmarked Questions'),
        actions: [
          BlocBuilder<BookmarkedQuestionsCubit, BookmarkedQuestionsState>(
            builder: (context, state) {
              if (state is BookmarkedQuestionsLoaded && state.questions.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CustomIconButton(
                    onTap: () {
                      final cubit = context.read<BookmarkedQuestionsCubit>();
                      final q = state.questions[state.currentIndex];
                      AppConfirmationDialog.show(
                        context,
                        title: 'Remove Bookmark',
                        message: 'Remove this question from your bookmarks?',
                        confirmText: 'Remove',
                        cancelText: 'Cancel',
                        isDestructive: true,
                        onConfirm: () => cubit.removeBookmark(q.id),
                      );
                    },
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete02),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: GradientBackground(
        child: BlocBuilder<BookmarkedQuestionsCubit, BookmarkedQuestionsState>(
          builder: (context, state) {
            if (state is BookmarkedQuestionsLoading) {
              return const Center(child: Loader());
            }

            if (state is BookmarkedQuestionsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomContainer(
                    child: EmptyStateWidget(
                      isCenter: false,
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedAlertCircle,
                        color: AppColors.error,
                        size: 50,
                      ),
                      title: 'Error',
                      message: state.message,
                    ),
                  ),
                ),
              );
            }

            if (state is BookmarkedQuestionsLoaded) {
              if (state.questions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomContainer(
                      child: EmptyStateWidget(
                        isCenter: false,
                        icon: SvgPicture.asset(
                          Assets.archiveOutlined,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primaryLight,
                            BlendMode.srcIn,
                          ),
                          height: 70,
                        ),
                        title: 'No Bookmarks Yet',
                        message:
                            'You haven\'t bookmarked any questions yet. Tap the bookmark icon during practice to save questions for later review.',
                      ),
                    ),
                  ),
                );
              }

              return QuestionPracticeView(
                questions: state.questions,
                currentIndex: state.currentIndex,
                selectedOption: state.selectedOption,
                isBookmarked: true,
                onOptionSelected: (option) {
                  context.read<BookmarkedQuestionsCubit>().selectOption(option);
                },
                onNext: () {
                  context.read<BookmarkedQuestionsCubit>().nextQuestion();
                },
                onPrevious: () {
                  context.read<BookmarkedQuestionsCubit>().previousQuestion();
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
