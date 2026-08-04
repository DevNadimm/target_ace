import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/profile/domain/repository/profile_repository.dart';

class DoSetupProfile implements UseCase<String, SetupProfileParams> {
  final ProfileRepository repository;
  const DoSetupProfile(this.repository);

  @override
  Future<Either<Failure, String>> call(SetupProfileParams params) async {
    return await repository.setupProfile(
      userId: params.userId,
      goalId: params.goalId,
      groupId: params.groupId,
      institution: params.institution,
      district: params.district,
      phone: params.phone,
      gender: params.gender,
      dob: params.dob,
      howDidYouHear: params.howDidYouHear,
      dailyGoal: params.dailyGoal,
      learningModes: params.learningModes,
    );
  }
}

class SetupProfileParams {
  final String userId;
  final String goalId;
  final String groupId;
  final String institution;
  final String district;
  final String phone;
  final String gender;
  final String dob;
  final String howDidYouHear;
  final String dailyGoal;
  final List<String> learningModes;

  SetupProfileParams({
    required this.userId,
    required this.goalId,
    required this.groupId,
    required this.institution,
    required this.district,
    required this.phone,
    required this.gender,
    required this.dob,
    this.howDidYouHear = '',
    this.dailyGoal = '',
    this.learningModes = const [],
  });
}
