import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/features/practice/domain/entities/topic_entity.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';
import 'package:target_ace/features/practice/domain/repository/practice_repository.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

part 'practice_session_state.dart';

class PracticeSessionCubit extends Cubit<PracticeSessionState> {
  final PracticeRepository _repository;
  final List<Map<String, dynamic>> _pendingAttempts = [];
  final List<Map<String, dynamic>> _sessionAttempts = [];
  DateTime? _sessionStartTime;

  PracticeSessionCubit({
    required PracticeRepository repository,
  })  : _repository = repository,
        super(const PracticeSessionState());

  Future<void> loadSession({required String subjectId, String? topicId}) async {
    _sessionStartTime = DateTime.now();
    _sessionAttempts.clear();
    _pendingAttempts.clear();

    emit(state.copyWith(
      status: PracticeSessionStatus.loading,
      selectedTopicId: topicId,
      errorMessage: null,
    ));

    try {
      final sessionRes = await _repository.startPracticeSession(
        subjectId: subjectId,
        topicId: topicId,
      );

      sessionRes.fold(
        (failure) => emit(state.copyWith(
          status: PracticeSessionStatus.failure,
          errorMessage: failure.message,
        )),
        (data) {
          final topicsData = List<dynamic>.from(data['topics'] ?? []);
          final topics = topicsData.map((e) => TopicEntity(
            id: e['id'],
            subjectId: e['subject_id'],
            name: e['name'],
            description: e['description'] ?? '',
            displayOrder: e['display_order'] ?? 0,
          )).toList();

          final bookmarkedIds = Set<String>.from(data['bookmarked_ids'] ?? []);
          
          final previousAttemptsData = List<dynamic>.from(data['previous_attempts'] ?? []);
          final previousAttempts = <String, bool>{};
          for (var item in previousAttemptsData) {
            previousAttempts[item['question_id']] = item['is_correct'] as bool;
          }
          
          final attemptedIds = Set<String>.from(data['attempted_ids'] ?? previousAttempts.keys);
          
          final questionsData = List<dynamic>.from(data['questions'] ?? []);
          final questions = questionsData.map((e) => QuestionEntity(
            id: e['id'],
            subjectId: e['subject_id'],
            topicId: e['topic_id'],
            questionText: e['question_text'],
            optionA: e['option_a'],
            optionB: e['option_b'],
            optionC: e['option_c'],
            optionD: e['option_d'],
            correctOption: e['correct_option'],
            explanation: e['explanation'],
            difficulty: e['difficulty'] ?? 'easy',
            tags: List<String>.from(e['tags'] ?? []),
            difficultyLevel: e['difficulty_level'] ?? 1,
            usedCount: e['used_count'] ?? 0,
          )).toList();

          int startIndex = 0;
          for (int i = 0; i < questions.length; i++) {
            if (!attemptedIds.contains(questions[i].id)) {
              startIndex = i;
              break;
            }
          }

          emit(state.copyWith(
            status: PracticeSessionStatus.loaded,
            topics: topics,
            questions: questions,
            currentIndex: startIndex,
            selectedOption: null,
            selectedTopicId: topicId,
            bookmarkedIds: bookmarkedIds,
            previousAttempts: previousAttempts,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: PracticeSessionStatus.failure,
        errorMessage: e.toString(),
      ));
    }


  }

  void selectOption(String option) {
    if (state.selectedOption != null) return;

    emit(state.copyWith(
      status: state.status,
      topics: state.topics,
      questions: state.questions,
      currentIndex: state.currentIndex,
      selectedTopicId: state.selectedTopicId,
      selectedOption: option,
      bookmarkedIds: state.bookmarkedIds,
    ));

    final q = state.currentQuestion;
    if (q != null) {
      final isCorrect = option.toUpperCase() == q.correctOption.toUpperCase();
      final attempt = {
        'question_id': q.id,
        'subject_id': q.subjectId,
        'topic_id': q.topicId,
        'selected_option': option,
        'is_correct': isCorrect,
      };
      _pendingAttempts.add(attempt);
      
      // Update session attempt if already exists (shouldn't happen since option is locked, but just in case)
      final existingIdx = _sessionAttempts.indexWhere((a) => a['question_id'] == q.id);
      if (existingIdx >= 0) {
        _sessionAttempts[existingIdx] = attempt;
      } else {
        _sessionAttempts.add(attempt);
      }
    }
  }

  Future<void> syncProgress() async {
    if (_pendingAttempts.isEmpty) return;
    final attemptsToSync = List<Map<String, dynamic>>.from(_pendingAttempts);
    _pendingAttempts.clear();
    
    final res = await _repository.recordAttempts(attemptsToSync);
    res.fold(
      (failure) {
        // If it fails, put them back so we can retry or log them
        _pendingAttempts.addAll(attemptsToSync);
      },
      (_) {},
    );
  }

  Future<String> toggleBookmark(String questionId) async {
    final isAdding = !state.bookmarkedIds.contains(questionId);
    
    if (isAdding) {
      final subStatus = await UserLocalDataSource.getSubscriptionStatus();
      if (subStatus != 'active' && subStatus != 'trial') {
        final res = await _repository.getBookmarkedQuestionIds();
        final count = res.fold((_) => 0, (ids) => ids.length);
        if (count >= 10) {
          return 'PAYWALL_$subStatus';
        }
      }
    }

    final res = await _repository.toggleBookmark(questionId);
    return res.fold(
      (failure) => 'ERROR_${failure.message}',
      (isBookmarked) {
        final newSet = Set<String>.from(state.bookmarkedIds);
        if (isBookmarked) {
          newSet.add(questionId);
        } else {
          newSet.remove(questionId);
        }
        emit(state.copyWith(
          status: state.status,
          topics: state.topics,
          questions: state.questions,
          currentIndex: state.currentIndex,
          selectedTopicId: state.selectedTopicId,
          selectedOption: state.selectedOption,
          bookmarkedIds: newSet,
        ));
        return isBookmarked ? 'ADDED' : 'REMOVED';
      },
    );
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      emit(state.copyWith(
        status: state.status,
        topics: state.topics,
        questions: state.questions,
        currentIndex: state.currentIndex + 1,
        selectedTopicId: state.selectedTopicId,
        selectedOption: null,
        bookmarkedIds: state.bookmarkedIds,
      ));
    } else {
      // Completed session
      syncProgress();
      emit(state.copyWith(
        status: PracticeSessionStatus.completed,
      ));
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      emit(state.copyWith(
        status: state.status,
        topics: state.topics,
        questions: state.questions,
        currentIndex: state.currentIndex - 1,
        selectedTopicId: state.selectedTopicId,
        selectedOption: null,
        bookmarkedIds: state.bookmarkedIds,
      ));
    }
  }

  Future<void> submitReport(String questionId, String reportText) async {
    final res = await _repository.submitReport(questionId, reportText);
    res.fold(
      (failure) {
        // Optionally, emit an error state or handle the failure
      },
      (_) {},
    );
  }

  // Session Results Data
  int get totalSessionQuestions => state.questions.length;
  int get correctAnswersCount => _sessionAttempts.where((a) => a['is_correct'] == true).length;
  int get wrongAnswersCount => _sessionAttempts.where((a) => a['is_correct'] == false).length;
  int get attemptedQuestionsCount => _sessionAttempts.length;
  double get sessionAccuracy => attemptedQuestionsCount == 0 ? 0 : (correctAnswersCount / attemptedQuestionsCount) * 100;
  
  Duration get sessionDuration {
    if (_sessionStartTime == null) return Duration.zero;
    return DateTime.now().difference(_sessionStartTime!);
  }

  List<Map<String, dynamic>> get sessionAttempts => List.unmodifiable(_sessionAttempts);

  void resetSession() {
    _sessionStartTime = DateTime.now();
    _sessionAttempts.clear();
    _pendingAttempts.clear();
    
    emit(state.copyWith(
      status: PracticeSessionStatus.loaded,
      currentIndex: 0,
      selectedOption: null,
    ));
  }
}