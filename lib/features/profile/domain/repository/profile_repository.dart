import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/features/profile/domain/entities/profile_entity.dart';

import 'package:target_ace/features/profile/domain/entities/onboarding_goal_entity.dart';
import 'package:target_ace/features/profile/domain/entities/battle_group_entity.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, List<OnboardingGoalEntity>>> getOnboardingGoals();
  Future<Either<Failure, List<BattleGroupEntity>>> getBattleGroups(String goalId);
  Future<Either<Failure, String>> setupProfile({
    required String userId,
    required String goalId,
    required String groupId,
    required String institution,
    required String district,
    required String phone,
    required String gender,
    required String dob,
    String howDidYouHear = '',
    String dailyGoal = '',
    List<String> learningModes = const [],
  });
  Future<Either<Failure, String>> switchGroup({
    required String userId,
    required String goalId,
    required String groupId,
  });
  Stream<Either<Failure, ProfileEntity>> getProfileData();
  Future<Either<Failure, bool>> checkPhoneUnique(String phone);
}
