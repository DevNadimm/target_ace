import 'package:target_ace/features/practice/domain/entities/question_entity.dart';

class BattleScoreCalculationResult {
  final double score;
  final int correctCount;
  final int wrongCount;
  final int unansweredCount;
  final List<Map<String, dynamic>> answers;

  const BattleScoreCalculationResult({
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.unansweredCount,
    required this.answers,
  });
}

class BattleScoreCalculator {
  static BattleScoreCalculationResult calculate({
    required List<QuestionEntity> questions,
    required List<Map<String, dynamic>> userAnswersList,
    required double perQuestionMark,
    required double negativeMark,
    bool forceFillUnanswered = false,
  }) {
    final answeredIds = userAnswersList.map((a) => a['question_id'] as String).toSet();
    final List<Map<String, dynamic>> finalAnswersList = List<Map<String, dynamic>>.from(userAnswersList);

    if (forceFillUnanswered) {
      for (final q in questions) {
        final qId = q.id;
        if (!answeredIds.contains(qId)) {
          finalAnswersList.add({
            'question_id': qId,
            'selected': '',
            'correct': q.correctOption,
            'is_correct': false,
          });
        }
      }
    }

    final correctCount = finalAnswersList.where((a) => a['is_correct'] == true).length;
    final wrongCount = finalAnswersList.where((a) => a['selected'] != '' && a['is_correct'] == false).length;
    final unansweredCount = questions.length - correctCount - wrongCount;

    final rawScore = (correctCount * perQuestionMark) - (wrongCount * negativeMark);
    final maxPossibleScore = questions.length * perQuestionMark;
    final finalScaledScore = maxPossibleScore > 0
        ? ((rawScore / maxPossibleScore) * 100).clamp(0.0, 100.0)
        : 0.0;

    return BattleScoreCalculationResult(
      score: finalScaledScore,
      correctCount: correctCount,
      wrongCount: wrongCount,
      unansweredCount: unansweredCount,
      answers: finalAnswersList,
    );
  }
}
