import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/services/battle_score_calculator.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';

class CalculateBattleScore implements UseCase<BattleScoreCalculationResult, CalculateBattleScoreParams> {
  const CalculateBattleScore();

  @override
  Future<Either<Failure, BattleScoreCalculationResult>> call(CalculateBattleScoreParams params) async {
    try {
      final result = BattleScoreCalculator.calculate(
        questions: params.questions,
        userAnswersList: params.userAnswersList,
        perQuestionMark: params.perQuestionMark,
        negativeMark: params.negativeMark,
        forceFillUnanswered: params.forceFillUnanswered,
      );
      return Right(result);
    } catch (e) {
      return Left(Failure(message: 'Score calculation error: $e'));
    }
  }
}

class CalculateBattleScoreParams {
  final List<QuestionEntity> questions;
  final List<Map<String, dynamic>> userAnswersList;
  final double perQuestionMark;
  final double negativeMark;
  final bool forceFillUnanswered;

  const CalculateBattleScoreParams({
    required this.questions,
    required this.userAnswersList,
    required this.perQuestionMark,
    required this.negativeMark,
    this.forceFillUnanswered = false,
  });
}