import 'package:target_ace/core/utils/enums/error_type.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:target_ace/core/utils/helpers/device_info_helper.dart';
import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_entry_entity.dart';
import 'package:target_ace/features/battle/domain/services/battle_score_calculator.dart';
import 'package:target_ace/features/battle/domain/usecases/calculate_battle_score.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battles.dart';
import 'package:target_ace/features/battle/domain/usecases/check_submission.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battle_questions.dart';
import 'package:target_ace/features/battle/domain/usecases/submit_battle.dart';
import 'package:target_ace/features/battle/domain/usecases/get_leaderboard_and_ranks.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

part 'battle_event.dart';
part 'battle_state.dart';

class BattleBloc extends Bloc<BattleEvent, BattleState> {
  final GetBattles _getBattles;
  final CheckSubmission _checkSubmission;
  final GetBattleQuestions _getBattleQuestions;
  final SubmitBattle _submitBattle;
  final GetLeaderboardAndRanks _getLeaderboardAndRanks;
  final CalculateBattleScore _calculateBattleScore;

  Timer? _countdownTimer;

  BattleBloc({
    required GetBattles getBattles,
    required CheckSubmission checkSubmission,
    required GetBattleQuestions getBattleQuestions,
    required SubmitBattle submitBattle,
    required GetLeaderboardAndRanks getLeaderboardAndRanks,
    required CalculateBattleScore calculateBattleScore,
  })  : _getBattles = getBattles,
        _checkSubmission = checkSubmission,
        _getBattleQuestions = getBattleQuestions,
        _submitBattle = submitBattle,
        _getLeaderboardAndRanks = getLeaderboardAndRanks,
        _calculateBattleScore = calculateBattleScore,
        super(BattleInitial()) {
    on<BattleLoadRequested>(_onLoadBattle);
    on<BattleOptionSelected>(_onOptionSelected);
    on<BattleAnswerSubmitted>(_onAnswerSubmitted);
    on<BattleQuestionJumped>(_onQuestionJumped);
    on<BattleForceSubmitRequested>(_onForceSubmit);
    on<BattleDisqualificationRequested>(_onDisqualify);
    on<BattleTimeTicked>(_onTimeTicked);
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoadBattle(BattleLoadRequested event, Emitter<BattleState> emit) async {
    emit(BattleLoading());
    try {
      final goalId = await UserLocalDataSource.getUserGoal();
      final groupId = await UserLocalDataSource.getUserGroupId();
      if (goalId.isEmpty) {
        emit(BattleError('No goals selected. Please select a goal first.'));
        return;
      }

      final examRes = await _getBattles(GetBattlesParams(goalId: goalId, groupId: groupId));
      
      final examsList = examRes.fold(
        (failure) {
          emit(BattleError(failure.message, failure.type));
          return <BattleEntity>[];
        },
        (list) => list,
      );

      if (examsList.isEmpty) {
        if (state is! BattleError) {
          emit(BattleError('No battles scheduled for your group today.'));
        }
        return;
      }

      final nowUtc = DateTime.now().toUtc();
      BattleEntity? selectedExam;
      for (final exam in examsList) {
        final startTime = DateTime.parse(exam.startTime).toUtc();
        final endTime = startTime.add(Duration(minutes: exam.durationMinutes));

        if (endTime.isAfter(nowUtc)) {
          selectedExam = exam;
          break;
        }
      }

      selectedExam ??= examsList.last;

      final String examId = selectedExam.id;
      final String examTitle = selectedExam.title;
      final DateTime examStartTime = DateTime.parse(selectedExam.startTime);
      final int examDurationMinutes = selectedExam.durationMinutes;
      final double perQuestionMark = selectedExam.perQuestionMark;
      final double negativeMark = selectedExam.negativeMark;

      final userId = await UserLocalDataSource.getUserId();
      final subCheckRes = await _checkSubmission(CheckSubmissionParams(examId: examId, userId: userId));

      bool isSubCheckFailed = false;
      final submissionCheck = subCheckRes.fold(
        (failure) {
          emit(BattleError(failure.message, failure.type));
          isSubCheckFailed = true;
          return null;
        },
        (sub) => sub,
      );

      if (isSubCheckFailed) return;

      final questionRes = await _getBattleQuestions(
        GetBattleQuestionsParams(examId: examId, fetchAll: true),
      );

      bool isQuestionsFailed = false;
      final questions = questionRes.fold(
        (failure) {
          emit(BattleError(failure.message, failure.type));
          isQuestionsFailed = true;
          return <QuestionEntity>[];
        },
        (qList) => qList,
      );

      if (isQuestionsFailed) return;

      if (questions.isEmpty) {
        emit(BattleError('No questions found for this exam.'));
        return;
      }

      if (submissionCheck != null) {
        await _loadLeaderboardAndResults(
          emit: emit,
          examId: examId,
          examTitle: examTitle,
          score: submissionCheck.score,
          isDisqualified: submissionCheck.disqualified,
          questions: questions,
          userAnswersList: submissionCheck.answers.map((a) => Map<String, dynamic>.from(a as Map)).toList(),
        );
        return;
      }

      final startTimeUtc = examStartTime.toUtc();
      final difference = startTimeUtc.difference(nowUtc);

      if (difference.inSeconds > 0) {
        if (difference.inSeconds > 900) {
          final localStartTimeStr = DateFormat('hh:mm a').format(examStartTime.toLocal());
          emit(BattleError('Tonight\'s live battle starts at $localStartTimeStr. The waiting room opens 15 minutes before the start.'));
          return;
        }
        emit(BattleWaiting(
          examId: examId,
          examTitle: examTitle,
          examStartTime: examStartTime,
          durationMinutes: examDurationMinutes,
          waitingSecondsRemaining: difference.inSeconds,
        ));
        _startDeadlineCountdown(startTimeUtc);
      } else {
        final elapsedSeconds = nowUtc.difference(startTimeUtc).inSeconds;
        final totalExamSeconds = examDurationMinutes * 60;

        if (elapsedSeconds >= totalExamSeconds) {
          await _loadLeaderboardAndResults(
            emit: emit,
            examId: examId,
            examTitle: examTitle,
            score: 0.0,
            isDisqualified: false,
            questions: questions,
            userAnswersList: const [],
          );
        } else {
          final int secondsRemaining = totalExamSeconds - elapsedSeconds;
          final examEndTimeUtc = startTimeUtc.add(Duration(minutes: examDurationMinutes));

          emit(BattleActive(
            examId: examId,
            examTitle: examTitle,
            questions: questions,
            currentIndex: 0,
            selectedOption: '',
            questionSecondsRemaining: secondsRemaining,
            userAnswersList: const [],
            score: 0.0,
            perQuestionMark: perQuestionMark,
            negativeMark: negativeMark,
            examDurationMinutes: examDurationMinutes,
            examStartTime: examStartTime,
          ));
          _startDeadlineCountdown(examEndTimeUtc);
        }
      }
    } catch (e) {
      emit(BattleError('Error joining battle room: $e'));
    }
  }

  void _onOptionSelected(BattleOptionSelected event, Emitter<BattleState> emit) {
    final currentState = state;
    if (currentState is BattleActive) {
      emit(currentState.copyWith(selectedOption: event.option));
    }
  }

  void _onQuestionJumped(BattleQuestionJumped event, Emitter<BattleState> emit) {
    final currentState = state;
    if (currentState is BattleActive) {
      final targetIndex = event.targetIndex;
      if (targetIndex < 0 || targetIndex >= currentState.questions.length || targetIndex == currentState.currentIndex) {
        return;
      }

      final currentQuestion = currentState.questions[currentState.currentIndex];
      final Map<String, Map<String, dynamic>> answersMap = {};
      for (final ans in currentState.userAnswersList) {
        final qId = ans['question_id'] as String?;
        if (qId != null) {
          answersMap[qId] = Map<String, dynamic>.from(ans);
        }
      }

      // ONLY save/update if an option was actually selected when jumping!
      if (currentState.selectedOption.isNotEmpty) {
        answersMap[currentQuestion.id] = {
          'question_id': currentQuestion.id,
          'selected': currentState.selectedOption,
          'correct': currentQuestion.correctOption,
          'is_correct': currentState.selectedOption == currentQuestion.correctOption,
          'status': 'answered',
        };
      }

      final updatedAnswers = currentState.questions.map((q) {
        return answersMap[q.id] ?? {
          'question_id': q.id,
          'selected': '',
          'correct': q.correctOption,
          'is_correct': false,
          'status': 'unvisited',
        };
      }).toList();

      final targetQuestion = currentState.questions[targetIndex];
      final targetSavedOption = answersMap[targetQuestion.id]?['selected'] as String? ?? '';

      emit(currentState.copyWith(
        currentIndex: targetIndex,
        selectedOption: targetSavedOption,
        userAnswersList: updatedAnswers,
      ));
    }
  }

  Future<void> _onAnswerSubmitted(BattleAnswerSubmitted event, Emitter<BattleState> emit) async {
    final currentState = state;
    if (currentState is BattleActive) {
      final currentQuestion = currentState.questions[currentState.currentIndex];
      final correctAnswer = currentQuestion.correctOption;
      final questionId = currentQuestion.id;
      final isCorrect = currentState.selectedOption == correctAnswer;

      final Map<String, Map<String, dynamic>> answersMap = {};
      for (final ans in currentState.userAnswersList) {
        final qId = ans['question_id'] as String?;
        if (qId != null) {
          answersMap[qId] = Map<String, dynamic>.from(ans);
        }
      }

      final String currentStatus = currentState.selectedOption.isNotEmpty ? 'answered' : 'skipped';
      answersMap[questionId] = {
        'question_id': questionId,
        'selected': currentState.selectedOption,
        'correct': correctAnswer,
        'is_correct': isCorrect,
        'status': currentStatus,
      };

      final updatedAnswers = currentState.questions.map((q) {
        return answersMap[q.id] ?? {
          'question_id': q.id,
          'selected': '',
          'correct': q.correctOption,
          'is_correct': false,
          'status': 'unvisited',
        };
      }).toList();

      if (currentState.currentIndex < currentState.questions.length - 1) {
        final nextIndex = currentState.currentIndex + 1;
        final nextQuestion = currentState.questions[nextIndex];
        final nextSavedOption = answersMap[nextQuestion.id]?['selected'] as String? ?? '';

        emit(currentState.copyWith(
          currentIndex: nextIndex,
          selectedOption: nextSavedOption,
          userAnswersList: updatedAnswers,
        ));
      } else {
        await _finishAndStartAnalyzing(
          emit: emit,
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

  Future<void> _onForceSubmit(BattleForceSubmitRequested event, Emitter<BattleState> emit) async {
    final currentState = state;
    if (currentState is BattleActive) {
      await _finishAndStartAnalyzing(
        emit: emit,
        examId: currentState.examId,
        examTitle: currentState.examTitle,
        examStartTime: currentState.examStartTime,
        examDurationMinutes: currentState.examDurationMinutes,
        questions: currentState.questions,
        userAnswersList: currentState.userAnswersList,
        perQuestionMark: currentState.perQuestionMark,
        negativeMark: currentState.negativeMark,
      );
    }
  }

  Future<void> _onDisqualify(BattleDisqualificationRequested event, Emitter<BattleState> emit) async {
    final currentState = state;
    if (currentState is BattleActive) {
      _countdownTimer?.cancel();

      final scoreRes = await _calculateBattleScore(CalculateBattleScoreParams(
        questions: currentState.questions,
        userAnswersList: currentState.userAnswersList,
        perQuestionMark: currentState.perQuestionMark,
        negativeMark: currentState.negativeMark,
        forceFillUnanswered: true,
      ));

      final result = scoreRes.fold(
        (failure) => const BattleScoreCalculationResult(
          score: 0.0,
          correctCount: 0,
          wrongCount: 0,
          unansweredCount: 0,
          answers: [],
        ),
        (res) => res,
      );

      emit(BattleLoading());

      try {
        final userId = await UserLocalDataSource.getUserId();
        if (userId.isNotEmpty) {
          final now = DateTime.now().toUtc();
          final startedAt = currentState.examStartTime.toUtc();
          final timeTakenSeconds = now.difference(startedAt).inSeconds.clamp(0, 86400);

          final res = await _submitBattle(SubmitBattleParams(
            examId: currentState.examId,
            userId: userId,
            score: result.score,
            correctCount: result.correctCount,
            wrongCount: result.wrongCount,
            unansweredCount: result.unansweredCount,
            answers: result.answers,
            disqualified: true,
            startedAt: startedAt,
            completedAt: now,
            timeTakenSeconds: timeTakenSeconds,
            deviceInfo: DeviceInfoHelper.getDeviceInfo(),
            appVersion: DeviceInfoHelper.getAppVersion(),
          ));
          res.fold(
            (failure) => debugPrint('Disqualification submit failed: ${failure.message}'),
            (_) => debugPrint('Disqualification submit succeeded'),
          );
        }
      } catch (e) {
        debugPrint('Error inserting disqualification: $e');
      }

      emit(BattleAnalyzing(
        examId: currentState.examId,
        examTitle: currentState.examTitle,
        examStartTime: currentState.examStartTime,
        examDurationMinutes: currentState.examDurationMinutes,
        analyzingSecondsRemaining: 60,
        score: result.score,
        questions: currentState.questions,
        userAnswersList: result.answers,
        isDisqualified: true,
      ));

      final revealDeadlineUtc = DateTime.now().toUtc().add(const Duration(seconds: 60));
      _startDeadlineCountdown(revealDeadlineUtc);
    }
  }

  Future<void> _onTimeTicked(BattleTimeTicked event, Emitter<BattleState> emit) async {
    final currentState = state;
    if (currentState is BattleWaiting) {
      if (event.secondsRemaining > 0) {
        emit(BattleWaiting(
          examId: currentState.examId,
          examTitle: currentState.examTitle,
          examStartTime: currentState.examStartTime,
          durationMinutes: currentState.durationMinutes,
          waitingSecondsRemaining: event.secondsRemaining,
        ));
      } else {
        _countdownTimer?.cancel();
        emit(BattleLoading());
        add(BattleLoadRequested());
      }
    } else if (currentState is BattleActive) {
      if (event.secondsRemaining > 0) {
        emit(currentState.copyWith(
          questionSecondsRemaining: event.secondsRemaining,
        ));
      } else {
        _countdownTimer?.cancel();
        add(BattleForceSubmitRequested());
      }
    } else if (currentState is BattleAnalyzing) {
      if (event.secondsRemaining > 0) {
        emit(BattleAnalyzing(
          examId: currentState.examId,
          examTitle: currentState.examTitle,
          examStartTime: currentState.examStartTime,
          examDurationMinutes: currentState.examDurationMinutes,
          analyzingSecondsRemaining: event.secondsRemaining,
          score: currentState.score,
          questions: currentState.questions,
          userAnswersList: currentState.userAnswersList,
          isDisqualified: currentState.isDisqualified,
        ));
      } else {
        _countdownTimer?.cancel();
        await _loadLeaderboardAndResults(
          emit: emit,
          examId: currentState.examId,
          examTitle: currentState.examTitle,
          score: currentState.score,
          isDisqualified: currentState.isDisqualified,
          questions: currentState.questions,
          userAnswersList: currentState.userAnswersList,
        );
      }
    }
  }

  void _startDeadlineCountdown(DateTime targetDeadlineUtc) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now().toUtc();
      final remaining = targetDeadlineUtc.difference(now).inSeconds;
      add(BattleTimeTicked(remaining));
      if (remaining <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _finishAndStartAnalyzing({
    required Emitter<BattleState> emit,
    required String examId,
    required String examTitle,
    required DateTime examStartTime,
    required int examDurationMinutes,
    required List<QuestionEntity> questions,
    required List<Map<String, dynamic>> userAnswersList,
    required double perQuestionMark,
    required double negativeMark,
  }) async {
    _countdownTimer?.cancel();

    final scoreRes = await _calculateBattleScore(CalculateBattleScoreParams(
      questions: questions,
      userAnswersList: userAnswersList,
      perQuestionMark: perQuestionMark,
      negativeMark: negativeMark,
    ));

    final result = scoreRes.fold(
      (failure) => const BattleScoreCalculationResult(
        score: 0.0,
        correctCount: 0,
        wrongCount: 0,
        unansweredCount: 0,
        answers: [],
      ),
      (res) => res,
    );

    final now = DateTime.now().toUtc();
    final examEndTime = examStartTime.toUtc().add(Duration(minutes: examDurationMinutes));
    int remaining = examEndTime.difference(now).inSeconds + 10;
    if (remaining < 10) {
      remaining = 10;
    }

    emit(BattleAnalyzing(
      examId: examId,
      examTitle: examTitle,
      examStartTime: examStartTime,
      examDurationMinutes: examDurationMinutes,
      analyzingSecondsRemaining: remaining,
      score: result.score,
      questions: questions,
      userAnswersList: result.answers,
    ));

    try {
      final userId = await UserLocalDataSource.getUserId();
      if (userId.isNotEmpty) {
        final startedAt = examStartTime.toUtc();
        final timeTakenSeconds = now.difference(startedAt).inSeconds.clamp(0, 86400);

        final res = await _submitBattle(SubmitBattleParams(
          examId: examId,
          userId: userId,
          score: result.score,
          correctCount: result.correctCount,
          wrongCount: result.wrongCount,
          unansweredCount: result.unansweredCount,
          answers: result.answers,
          disqualified: false,
          startedAt: startedAt,
          completedAt: now,
          timeTakenSeconds: timeTakenSeconds,
          deviceInfo: DeviceInfoHelper.getDeviceInfo(),
          appVersion: DeviceInfoHelper.getAppVersion(),
        ));
        res.fold(
          (failure) => debugPrint('Submission failed: ${failure.message}'),
          (_) => debugPrint('Submission succeeded'),
        );
      }
    } catch (e) {
      debugPrint('Error inserting submission: $e');
    }

    final revealDeadlineUtc = examEndTime.add(const Duration(seconds: 10));
    _startDeadlineCountdown(revealDeadlineUtc);
  }

  Future<void> _loadLeaderboardAndResults({
    required Emitter<BattleState> emit,
    required String examId,
    required String examTitle,
    required double score,
    required bool isDisqualified,
    required List<QuestionEntity> questions,
    required List<Map<String, dynamic>> userAnswersList,
  }) async {
    emit(BattleLoading());
    try {
      final userId = await UserLocalDataSource.getUserId();
      final activeGroupId = await UserLocalDataSource.getUserGroupId();

      final rpcRes = await _getLeaderboardAndRanks(GetLeaderboardAndRanksParams(
        examId: examId,
        userId: userId,
        activeGroupId: activeGroupId,
      ));

      rpcRes.fold(
        (failure) {
          emit(BattleScoreboard(
            examId: examId,
            examTitle: examTitle,
            score: score,
            examRank: 0,
            groupRank: 0,
            globalRank: 0,
            leaderboard: const [],
            isDisqualified: isDisqualified,
            questions: questions,
            userAnswersList: userAnswersList,
          ));
        },
        (leaderboardData) {
          emit(BattleScoreboard(
            examId: examId,
            examTitle: examTitle,
            score: score,
            examRank: leaderboardData.examRank,
            groupRank: leaderboardData.groupRank,
            globalRank: leaderboardData.globalRank,
            leaderboard: leaderboardData.leaderboard,
            isDisqualified: isDisqualified,
            questions: questions,
            userAnswersList: userAnswersList,
          ));
        },
      );
    } catch (e) {
      emit(BattleScoreboard(
        examId: examId,
        examTitle: examTitle,
        score: score,
        examRank: 0,
        groupRank: 0,
        globalRank: 0,
        leaderboard: const [],
        isDisqualified: isDisqualified,
        questions: questions,
        userAnswersList: userAnswersList,
      ));
    }
  }
}