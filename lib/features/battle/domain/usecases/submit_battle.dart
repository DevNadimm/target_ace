import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';

class SubmitBattle implements UseCase<void, SubmitBattleParams> {
  final BattleRepository repository;
  const SubmitBattle(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitBattleParams params) async {
    return await repository.submitBattle(
      examId: params.examId,
      userId: params.userId,
      score: params.score,
      correctCount: params.correctCount,
      wrongCount: params.wrongCount,
      unansweredCount: params.unansweredCount,
      answers: params.answers,
      disqualified: params.disqualified,
      startedAt: params.startedAt,
      completedAt: params.completedAt,
      timeTakenSeconds: params.timeTakenSeconds,
      deviceInfo: params.deviceInfo,
      appVersion: params.appVersion,
      isAutoSubmitted: params.isAutoSubmitted,
    );
  }
}

class SubmitBattleParams {
  final String examId;
  final String userId;
  final double score;
  final int correctCount;
  final int wrongCount;
  final int unansweredCount;
  final List<Map<String, dynamic>> answers;
  final bool disqualified;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? timeTakenSeconds;
  final Map<String, dynamic>? deviceInfo;
  final String? appVersion;
  final bool isAutoSubmitted;

  const SubmitBattleParams({
    required this.examId,
    required this.userId,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.unansweredCount,
    required this.answers,
    required this.disqualified,
    this.startedAt,
    this.completedAt,
    this.timeTakenSeconds,
    this.deviceInfo,
    this.appVersion,
    this.isAutoSubmitted = false,
  });
}
