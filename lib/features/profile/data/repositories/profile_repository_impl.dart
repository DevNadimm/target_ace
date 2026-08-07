import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/network/connection_checker.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:target_ace/features/profile/data/models/profile_model.dart';
import 'package:target_ace/features/profile/domain/entities/profile_entity.dart';
import 'package:target_ace/features/profile/domain/repository/profile_repository.dart';
import 'package:target_ace/features/profile/domain/entities/onboarding_goal_entity.dart';
import 'package:target_ace/features/profile/domain/entities/battle_group_entity.dart';
import 'package:target_ace/features/profile/data/models/onboarding_goal_model.dart';
import 'package:target_ace/features/profile/data/models/battle_group_model.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  const ProfileRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, List<OnboardingGoalEntity>>> getOnboardingGoals() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(type: ErrorType.network));
      }
      final goalsData = await remoteDataSource.getOnboardingGoals();
      final goals = goalsData.map((e) => OnboardingGoalModel.fromJson(e)).toList();
      return right(goals);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  @override
  Future<Either<Failure, List<BattleGroupEntity>>> getBattleGroups(String goalId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(type: ErrorType.network));
      }
      final groupsData = await remoteDataSource.getBattleGroups(goalId);
      final groups = groupsData.map((e) => BattleGroupModel.fromJson(e)).toList();
      return right(groups);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  @override
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
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(type: ErrorType.network));
      }

      // 1. Build metadata map for Supabase Auth (only include non-empty values)
      final Map<String, dynamic> metadataMap = {};
      if (phone.isNotEmpty) metadataMap['phone'] = phone;
      if (gender.isNotEmpty) metadataMap['gender'] = gender;
      if (dob.isNotEmpty) metadataMap['dob'] = dob;
      if (institution.isNotEmpty) metadataMap['institution'] = institution;
      if (district.isNotEmpty) metadataMap['district'] = district;
      if (howDidYouHear.isNotEmpty) metadataMap['how_did_you_hear'] = howDidYouHear;
      if (dailyGoal.isNotEmpty) metadataMap['daily_goal'] = dailyGoal;
      if (learningModes.isNotEmpty) metadataMap['learning_modes'] = learningModes;

      // 2. Run Auth metadata update & Atomic Database RPC concurrently
      final results = await Future.wait([
        if (metadataMap.isNotEmpty)
          remoteDataSource.updateAuthUserMetadata(metadataMap).catchError((_) {})
        else
          Future.value(null),
        remoteDataSource.completeProfileSetup({
          'p_user_id': userId,
          'p_goal': goalId,
          'p_group_id': groupId,
          'p_institution': institution.isEmpty ? null : institution,
          'p_district': district.isEmpty ? null : district,
          'p_phone': phone.isEmpty ? null : phone,
          'p_gender': gender.isEmpty ? null : gender,
          'p_dob': dob.isEmpty ? null : dob,
          'p_how_did_you_hear': howDidYouHear.isEmpty ? null : howDidYouHear,
          'p_daily_goal': dailyGoal.isEmpty ? null : dailyGoal,
          'p_learning_modes': learningModes.isEmpty ? null : learningModes,
        }),
      ]);

      final rpcResult = results[1] as Map<String, dynamic>;
      final lockedUntil = rpcResult['locked_until'] as String;

      // 3. Update local cache (only include non-empty values)
      final Map<String, dynamic> localUpdates = {
        'goal': goalId,
        'group_id': groupId,
        'group_locked_until': lockedUntil,
      };
      if (institution.isNotEmpty) localUpdates['institution'] = institution;
      if (district.isNotEmpty) localUpdates['district'] = district;
      if (phone.isNotEmpty) localUpdates['phone'] = phone;
      if (gender.isNotEmpty) localUpdates['gender'] = gender;
      if (dob.isNotEmpty) localUpdates['dob'] = dob;
      if (howDidYouHear.isNotEmpty) localUpdates['how_did_you_hear'] = howDidYouHear;
      if (dailyGoal.isNotEmpty) localUpdates['daily_goal'] = dailyGoal;
      if (learningModes.isNotEmpty) localUpdates['learning_modes'] = learningModes;

      try {
        await UserLocalDataSource.updateFields(localUpdates);
      } catch (_) {}

      return right(lockedUntil);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  // â”€â”€â”€ Legacy Compatibility for GroupSwitchCubit â”€â”€â”€
  // Since other features use this directly from ProfileRepo, we keep this method inside the implementation class
  // to avoid breaking existing code. Once we migrate GroupSwitch, this will go away.
  @override
  Future<Either<Failure, String>> switchGroup({
    required String userId,
    required String goalId,
    required String groupId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(type: ErrorType.network));
      }
      await remoteDataSource.upsertProfile({
        'goal': goalId,
        'group_id': groupId,
        'id': userId,
      });
      try {
        await remoteDataSource.deactivateActiveMemberships(userId);
      } catch (_) {}
      final membership = await remoteDataSource.insertGroupMembership({
        'user_id': userId,
        'group_id': groupId,
        'is_active': true,
      });
      return right(membership['locked_until'] as String);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  Future<ProfileEntity> _readLocalProfile() async {
    final cachedUser = await UserLocalDataSource.readUser();

    final name = cachedUser?.name ?? 'User';
    final email = cachedUser?.email ?? '';
    final planName = cachedUser?.subscriptionPlanName ?? '';
    final status = cachedUser?.subscriptionStatus ?? 'none';
    final displayPlan = planName.isNotEmpty
        ? planName
        : (status == 'active' ? 'Premium Plan' : 'Free Member');
    final groupTitle = cachedUser?.groupTitle ?? '';

    return ProfileModel(
      name: name,
      email: email,
      phone: cachedUser?.phone ?? '',
      gender: cachedUser?.gender ?? '',
      dob: cachedUser?.dob ?? '',
      institution: cachedUser?.institution ?? '',
      district: cachedUser?.district ?? '',
      avatarUrl: cachedUser?.avatarUrl ?? '',
      subscriptionPlanName: displayPlan,
      subscriptionStatus: status,
      subscriptionExpiry: cachedUser?.subscriptionExpiryDate ?? '',
      activeGroupTitle: groupTitle.isNotEmpty ? groupTitle : 'Not Selected',
    );
  }

  @override
  Stream<Either<Failure, ProfileEntity>> getProfileData() async* {
    // Read-only: yield local cached data immediately.
    // Network sync is handled at explicit sync points only
    // (Splash, Login, Profile Update, Manual Refresh).
    try {
      final cachedProfile = await _readLocalProfile();
      yield right(cachedProfile);
    } catch (e) {
      yield left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPhoneUnique(String phone) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(type: ErrorType.network));
      }
      final isUnique = await remoteDataSource.checkPhoneUnique(phone);
      return right(isUnique);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }
}