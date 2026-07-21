import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/features/battle/data/repos/battle_repo.dart';

part 'battle_state.dart';

class BattleCubit extends Cubit<BattleState> {
  Timer? _waitingTimer;
  Timer? _questionTimer;
  Timer? _analyzingTimer;

  BattleCubit() : super(BattleInitial());

  @override
  Future<void> close() {
    _waitingTimer?.cancel();
    _questionTimer?.cancel();
    _analyzingTimer?.cancel();
    return super.close();
  }

  Future<void> loadExamAndSetupSync() async {
    emit(BattleLoading());
    try {
      final goalId = await AppPreferences.getUserGoal();
      final groupId = await AppPreferences.getUserGroup();
      if (goalId.isEmpty) {
        emit(BattleError('No goals selected. Please select a goal first.'));
        return;
      }

      // 1. Fetch current active or upcoming exam from Repository
      final examResponse = await BattleRepo.getExams(goalId, groupId);

      if (examResponse.isEmpty) {
        emit(BattleError('No battles scheduled for your group today.'));
        return;
      }

      // Find the first exam that is either currently live or upcoming
      final nowUtc = DateTime.now().toUtc();
      Map<String, dynamic>? selectedExam;
      for (final examMap in examResponse) {
        final startTime = DateTime.parse(examMap['start_time'] as String).toUtc();
        final durationMins = examMap['duration_minutes'] as int? ?? 15;
        final endTime = startTime.add(Duration(minutes: durationMins));

        if (endTime.isAfter(nowUtc)) {
          selectedExam = examMap;
          break;
        }
      }

      selectedExam ??= examResponse.last;

      final String examId = selectedExam['id'] as String;
      final String examTitle = selectedExam['title'] as String;
      final DateTime examStartTime = DateTime.parse(selectedExam['start_time'] as String);
      final int examDurationMinutes = selectedExam['duration_minutes'] as int? ?? 15;
      final double perQuestionMark = (selectedExam['per_question_mark'] as num?)?.toDouble() ?? 1.0;
      final double negativeMark = (selectedExam['negative_mark'] as num?)?.toDouble() ?? 0.25;

      // Check existing submission from Repository
      final userId = await AppPreferences.getUserId();
      final submissionCheck = await BattleRepo.checkSubmission(examId, userId);

      // Fetch questions with offline cache fallback via Repository
      List<Map<String, dynamic>> questions = [];
      try {
        questions = await BattleRepo.fetchQuestions(examId);

        if (questions.isNotEmpty) {
          await AppPreferences.saveCachedExamQuestions(examId, questions);
        }
      } catch (e) {
        debugPrint('Failed database fetch, trying cache: $e');
        questions = await AppPreferences.getCachedExamQuestions(examId);
      }

      if (submissionCheck.isNotEmpty) {
        final submission = submissionCheck.first;
        final bool isDisq = submission['disqualified'] as bool? ?? false;
        final double score = (submission['score'] as num?)?.toDouble() ?? 0.0;
        final rawAnswers = submission['answers'] as List? ?? [];
        final userAnswers = rawAnswers.map((a) => Map<String, dynamic>.from(a as Map)).toList();

        await _loadLeaderboardAndResults(
          examId: examId,
          examTitle: examTitle,
          score: score,
          isDisqualified: isDisq,
          questions: questions,
          userAnswersList: userAnswers,
        );
        return;
      }

      if (questions.isEmpty) {
        emit(BattleError('No questions associated with this exam.'));
        return;
      }

      // Calculate time gaps
      final now = DateTime.now().toUtc();
      final startTimeUtc = examStartTime.toUtc();
      final difference = startTimeUtc.difference(now);

      if (difference.inSeconds > 0) {
        // Waiting Room
        emit(BattleWaiting(
          examId: examId,
          examTitle: examTitle,
          examStartTime: examStartTime,
          durationMinutes: examDurationMinutes,
          waitingSecondsRemaining: difference.inSeconds,
        ));
        _startWaitingTimer();
      } else {
        final elapsedSeconds = now.difference(startTimeUtc).inSeconds;
        final totalExamSeconds = examDurationMinutes * 60;

        if (elapsedSeconds >= totalExamSeconds) {
          // Exam already ended, go straight to Scoreboard
          await _loadLeaderboardAndResults(
            examId: examId,
            examTitle: examTitle,
            score: 0.0,
            isDisqualified: false,
            questions: questions,
            userAnswersList: [],
          );
        } else {
          // Live Battle Active
          final int currentIndex = (elapsedSeconds / 30).floor().clamp(0, questions.length - 1);
          final int secondsRemaining = 30 - (elapsedSeconds % 30);

          emit(BattleActive(
            examId: examId,
            examTitle: examTitle,
            questions: questions,
            currentIndex: currentIndex,
            selectedOption: '',
            questionSecondsRemaining: secondsRemaining,
            userAnswersList: [],
            score: 0.0,
            perQuestionMark: perQuestionMark,
            negativeMark: negativeMark,
            examDurationMinutes: examDurationMinutes,
            examStartTime: examStartTime,
          ));
          _startQuestionTimer();
        }
      }
    } catch (e) {
      emit(BattleError('Error joining battle room: $e'));
    }
  }

  // Waiting Room Countdown
  void _startWaitingTimer() {
    _waitingTimer?.cancel();
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is BattleWaiting) {
        if (currentState.waitingSecondsRemaining > 0) {
          emit(BattleWaiting(
            examId: currentState.examId,
            examTitle: currentState.examTitle,
            examStartTime: currentState.examStartTime,
            durationMinutes: currentState.durationMinutes,
            waitingSecondsRemaining: currentState.waitingSecondsRemaining - 1,
          ));
        } else {
          _waitingTimer?.cancel();
          emit(BattleLoading());
          loadExamAndSetupSync();
        }
      } else {
        _waitingTimer?.cancel();
      }
    });
  }

  // Active Gameplay Timer
  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is BattleActive) {
        if (currentState.questionSecondsRemaining > 0) {
          emit(currentState.copyWith(
            questionSecondsRemaining: currentState.questionSecondsRemaining - 1,
          ));
        } else {
          _questionTimer?.cancel();
          submitCurrentAnswerAndNext();
        }
      } else {
        _questionTimer?.cancel();
      }
    });
  }

  void selectOption(String option) {
    final currentState = state;
    if (currentState is BattleActive) {
      emit(currentState.copyWith(selectedOption: option));
    }
  }

  void submitCurrentAnswerAndNext() {
    final currentState = state;
    if (currentState is BattleActive) {
      final currentQuestion = currentState.questions[currentState.currentIndex];
      final correctAnswer = currentQuestion['correct_option'] as String;
      final questionId = currentQuestion['id'] as String;

      final isCorrect = currentState.selectedOption == correctAnswer;

      final updatedAnswers = List<Map<String, dynamic>>.from(currentState.userAnswersList)
        ..add({
          'question_id': questionId,
          'selected': currentState.selectedOption,
          'correct': correctAnswer,
          'is_correct': isCorrect,
        });

      if (currentState.currentIndex < currentState.questions.length - 1) {
        emit(currentState.copyWith(
          currentIndex: currentState.currentIndex + 1,
          selectedOption: '',
          questionSecondsRemaining: 30,
          userAnswersList: updatedAnswers,
        ));
        _startQuestionTimer();
      } else {
        _finishAndStartAnalyzing(
          examId: currentState.examId,
          examTitle: currentState.examTitle,
          examStartTime: currentState.examStartTime,
          examDurationMinutes: currentState.examDurationMinutes,
          questions: currentState.questions,
          userAnswersList: updatedAnswers,
          perQuestionMark: currentState.perQuestionMark,
          negativeMark: currentState.negativeMark,
        );
      }
    }
  }

  Future<void> _finishAndStartAnalyzing({
    required String examId,
    required String examTitle,
    required DateTime examStartTime,
    required int examDurationMinutes,
    required List<Map<String, dynamic>> questions,
    required List<Map<String, dynamic>> userAnswersList,
    required double perQuestionMark,
    required double negativeMark,
  }) async {
    _questionTimer?.cancel();

    final correctCount = userAnswersList.where((a) => a['is_correct'] == true).length;
    final wrongCount = userAnswersList.where((a) => a['selected'] != '' && a['is_correct'] == false).length;
    final unansweredCount = userAnswersList.where((a) => a['selected'] == '').length;

    final rawScore = (correctCount * perQuestionMark) - (wrongCount * negativeMark);
    final maxPossibleScore = questions.length * perQuestionMark;
    final finalScaledScore = maxPossibleScore > 0
        ? ((rawScore / maxPossibleScore) * 100).clamp(0.0, 100.0)
        : 0.0;

    emit(BattleAnalyzing(
      examId: examId,
      examTitle: examTitle,
      examStartTime: examStartTime,
      examDurationMinutes: examDurationMinutes,
      analyzingSecondsRemaining: 60,
      score: finalScaledScore,
      questions: questions,
      userAnswersList: userAnswersList,
    ));

    try {
      final userId = await AppPreferences.getUserId();
      if (userId.isNotEmpty) {
        await BattleRepo.submitExam(
          examId: examId,
          userId: userId,
          score: finalScaledScore,
          correctCount: correctCount,
          wrongCount: wrongCount,
          unansweredCount: unansweredCount,
          answers: userAnswersList,
          disqualified: false,
        );
      }
    } catch (e) {
      debugPrint('Error inserting submission: $e');
    }

    _startAnalyzingTimer();
  }

  void _startAnalyzingTimer() {
    _analyzingTimer?.cancel();
    final currentState = state;
    if (currentState is BattleAnalyzing) {
      final now = DateTime.now().toUtc();
      final examEndTime = currentState.examStartTime.toUtc().add(Duration(minutes: currentState.examDurationMinutes));
      int remaining = examEndTime.difference(now).inSeconds + 10;
      if (remaining < 10) {
        remaining = 10;
      }

      emit(BattleAnalyzing(
        examId: currentState.examId,
        examTitle: currentState.examTitle,
        examStartTime: currentState.examStartTime,
        examDurationMinutes: currentState.examDurationMinutes,
        analyzingSecondsRemaining: remaining,
        score: currentState.score,
        questions: currentState.questions,
        userAnswersList: currentState.userAnswersList,
      ));

      _analyzingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final innerState = state;
        if (innerState is BattleAnalyzing) {
          if (innerState.analyzingSecondsRemaining > 0) {
            emit(BattleAnalyzing(
              examId: innerState.examId,
              examTitle: innerState.examTitle,
              examStartTime: innerState.examStartTime,
              examDurationMinutes: innerState.examDurationMinutes,
              analyzingSecondsRemaining: innerState.analyzingSecondsRemaining - 1,
              score: innerState.score,
              questions: innerState.questions,
              userAnswersList: innerState.userAnswersList,
            ));
          } else {
            _analyzingTimer?.cancel();
            _loadLeaderboardAndResults(
              examId: innerState.examId,
              examTitle: innerState.examTitle,
              score: innerState.score,
              isDisqualified: false,
              questions: innerState.questions,
              userAnswersList: innerState.userAnswersList,
            );
          }
        } else {
          _analyzingTimer?.cancel();
        }
      });
    }
  }

  Future<void> disqualifyUser() async {
    final currentState = state;
    if (currentState is BattleActive) {
      _waitingTimer?.cancel();
      _questionTimer?.cancel();
      _analyzingTimer?.cancel();

      final String examId = currentState.examId;
      final String examTitle = currentState.examTitle;
      final List<Map<String, dynamic>> questions = currentState.questions;

      emit(BattleLoading());

      try {
        final userId = await AppPreferences.getUserId();
        if (userId.isNotEmpty) {
          await BattleRepo.submitExam(
            examId: examId,
            userId: userId,
            score: 0.0,
            correctCount: 0,
            wrongCount: 0,
            unansweredCount: questions.length,
            answers: [],
            disqualified: true,
          );
        }
      } catch (e) {
        debugPrint('Error inserting disqualification: $e');
      }

      await _loadLeaderboardAndResults(
        examId: examId,
        examTitle: examTitle,
        score: 0.0,
        isDisqualified: true,
        questions: questions,
        userAnswersList: [],
      );
    }
  }

  Future<void> _loadLeaderboardAndResults({
    required String examId,
    required String examTitle,
    required double score,
    required bool isDisqualified,
    required List<Map<String, dynamic>> questions,
    required List<Map<String, dynamic>> userAnswersList,
  }) async {
    emit(BattleLoading());
    try {
      final userId = await AppPreferences.getUserId();
      final activeGroupId = await AppPreferences.getActiveGroupId();

      // Call parallel functions from Repository
      final rpcResults = await BattleRepo.fetchLeaderboardAndRanks(
        examId: examId,
        userId: userId,
        activeGroupId: activeGroupId,
      );

      final jsonResponse = rpcResults[0];
      List<Map<String, dynamic>> leaderboardList = [];
      int myRank = 0;

      if (jsonResponse != null) {
        final data = jsonResponse as Map<String, dynamic>;
        myRank = data['my_rank'] as int? ?? 0;
        final list = data['leaderboard'] as List?;
        if (list != null) {
          for (final item in list) {
            leaderboardList.add({
              'rank': item['rank'] as int? ?? 0,
              'name': item['name'] as String? ?? 'Student',
              'avatar_url': item['avatar_url'] as String? ?? '',
              'score': (item['score'] as num?)?.toDouble() ?? 0.0,
              'is_current_user': item['is_current_user'] as bool? ?? false,
            });
          }
        }
      }

      final int groupRank = (rpcResults[1] as num?)?.toInt() ?? 0;
      final int globalRank = (rpcResults[2] as num?)?.toInt() ?? 0;

      emit(BattleScoreboard(
        examId: examId,
        examTitle: examTitle,
        score: score,
        examRank: myRank,
        groupRank: groupRank,
        globalRank: globalRank,
        leaderboard: leaderboardList,
        isDisqualified: isDisqualified,
        questions: questions,
        userAnswersList: userAnswersList,
      ));
    } catch (e) {
      emit(BattleScoreboard(
        examId: examId,
        examTitle: examTitle,
        score: score,
        examRank: 0,
        groupRank: 0,
        globalRank: 0,
        leaderboard: [],
        isDisqualified: isDisqualified,
        questions: questions,
        userAnswersList: userAnswersList,
      ));
    }
  }
}
