import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/network/connection_checker.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:target_ace/features/profile/data/models/profile_model.dart';
import 'package:target_ace/features/profile/domain/entities/profile_entity.dart';
import 'package:target_ace/features/profile/domain/repository/profile_repository.dart';

import 'package:target_ace/features/profile/domain/entities/onboarding_goal_entity.dart';
import 'package:target_ace/features/profile/domain/entities/battle_group_entity.dart';
import 'package:target_ace/features/profile/data/models/onboarding_goal_model.dart';
import 'package:target_ace/features/profile/data/models/battle_group_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  const ProfileRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, List<OnboardingGoalEntity>>> getOnboardingGoals() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final goalsData = await remoteDataSource.getOnboardingGoals();
      final goals = goalsData.map((e) => OnboardingGoalModel.fromJson(e)).toList();
      return right(goals);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<BattleGroupEntity>>> getBattleGroups(String goalId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final groupsData = await remoteDataSource.getBattleGroups(goalId);
      final groups = groupsData.map((e) => BattleGroupModel.fromJson(e)).toList();
      return right(groups);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
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
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }

      // 1. Update Auth metadata
      try {
        await remoteDataSource.updateAuthUserMetadata({
          'phone': phone,
          'gender': gender,
          'dob': dob,
          'institution': institution,
          'district': district,
        });
      } catch (_) {}

      // 2. Fetch profile single and Upsert profiles table
      try {
        final existingProfile = await remoteDataSource.fetchProfileSingle(userId);
        
        // Supabase client instance reference mapping fallback
        // We will fetch from client as we are in data layer implementation
        final name = existingProfile?['name'] as String? ?? 'Student';
        final email = existingProfile?['email'] as String? ?? '';
        final avatarUrl = existingProfile?['avatar_url'] as String?;

        await remoteDataSource.upsertProfile({
          'id': userId,
          'name': name,
          'email': email,
          'avatar_url': avatarUrl,
          'goal': goalId,
          'group_id': groupId,
          'institution': institution,
          'district': district,
          'phone': phone,
          'gender': gender,
          'dob': dob,
        });
      } catch (_) {
        await remoteDataSource.upsertProfile({
          'id': userId,
          'goal': goalId,
          'group_id': groupId,
          'institution': institution,
          'district': district,
        });
      }

      // 3. Deactivate previous memberships
      try {
        await remoteDataSource.deactivateActiveMemberships(userId);
      } catch (_) {}

      // 4. Insert new active group membership
      final membership = await remoteDataSource.insertGroupMembership({
        'user_id': userId,
        'group_id': groupId,
        'is_active': true,
      });

      return right(membership['locked_until'] as String);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  // ─── Legacy Compatibility for GroupSwitchCubit ───
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
        return left(Failure(message: 'No internet connection. Please check your network.'));
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
      return left(Failure(message: e.message));
    }
  }

  Future<ProfileEntity> _readLocalProfile() async {
    final name = await AppPreferences.getUserName();
    final email = await AppPreferences.getUserEmail();
    final phone = await AppPreferences.getUserPhone();
    final gender = await AppPreferences.getUserGender();
    final dob = await AppPreferences.getUserDob();
    final institution = await AppPreferences.getUserInstitution();
    final district = await AppPreferences.getUserDistrict();
    final avatarUrl = await AppPreferences.getUserAvatarUrl();
    final planName = await AppPreferences.getSubscriptionPlanName();
    final status = await AppPreferences.getSubscriptionStatus();
    final expiry = await AppPreferences.getSubscriptionExpiryDate();
    final groupTitle = await AppPreferences.getActiveGroupTitle();

    final displayPlan = planName.isNotEmpty ? planName : (status == 'active' ? 'TargetAce+ Pro' : 'Free Member');

    return ProfileModel(
      name: name,
      email: email,
      phone: phone,
      gender: gender,
      dob: dob,
      institution: institution,
      district: district,
      avatarUrl: avatarUrl,
      subscriptionPlanName: displayPlan,
      subscriptionStatus: status,
      subscriptionExpiry: expiry ?? '',
      activeGroupTitle: (groupTitle != null && groupTitle.isNotEmpty) ? groupTitle : 'Not Selected',
    );
  }

  @override
  Stream<Either<Failure, ProfileEntity>> getProfileData() async* {
    // 1. Yield local cached data immediately
    try {
      final cachedProfile = await _readLocalProfile();
      yield right(cachedProfile);
    } catch (e) {
      yield left(Failure(message: e.toString()));
    }

    // 2. Perform background network sync
    try {
      final userId = await AppPreferences.getUserId();
      if (userId.isNotEmpty) {
        final payload = await remoteDataSource.fetchProfileWithSubscription(userId);
        if (payload != null) {
          final profileData = payload['profile'] as Map<String, dynamic>?;
          final latestSub = payload['subscription'] as Map<String, dynamic>?;

          if (profileData != null) {
            // Save updated profile fields to Local DB (AppPreferences)
            if (profileData['name'] != null) await AppPreferences.setUserName(profileData['name'] as String);
            if (profileData['email'] != null) await AppPreferences.setUserEmail(profileData['email'] as String);
            if (profileData['phone'] != null) await AppPreferences.setUserPhone(profileData['phone'] as String);
            if (profileData['gender'] != null) await AppPreferences.setUserGender(profileData['gender'] as String);
            if (profileData['dob'] != null) await AppPreferences.setUserDob(profileData['dob'] as String);
            if (profileData['institution'] != null) await AppPreferences.setUserInstitution(profileData['institution'] as String);
            if (profileData['district'] != null) await AppPreferences.setUserDistrict(profileData['district'] as String);
            if (profileData['avatar_url'] != null) await AppPreferences.setUserAvatarUrl(profileData['avatar_url'] as String);

            final isPremium = profileData['is_premium'] as bool? ?? false;
            final expiryStr = profileData['premium_expires_at'] as String?;
            final bool isExpired = expiryStr != null && DateTime.tryParse(expiryStr)?.isBefore(DateTime.now()) == true;

            final latestSubStatus = latestSub?['status'] as String?;
            final latestSubPlanId = latestSub?['plan_id'] as String?;
            final latestSubPlanName = latestSub?['plan_name'] as String?;

            String subStatus = 'none';

            if (isPremium && !isExpired) {
              final isTrial = latestSubPlanId == 'free_trial' || latestSubPlanName == 'Free Trial';
              subStatus = isTrial ? 'trial' : 'active';
            } else {
              if (latestSubStatus == 'pending') {
                subStatus = 'pending_verification';
              } else if (isExpired) {
                subStatus = 'expired';
              }
            }

            await AppPreferences.setSubscriptionStatus(subStatus);
            if (expiryStr != null) {
              await AppPreferences.setSubscriptionExpiryDate(expiryStr);
            } else {
              await AppPreferences.setSubscriptionExpiryDate('');
            }
          }

          if (latestSub != null && latestSub['plan_name'] != null) {
            await AppPreferences.setSubscriptionPlanName(latestSub['plan_name'] as String);
          } else {
            await AppPreferences.setSubscriptionPlanName('Free Member');
          }

          // Yield the updated data
          final updatedProfile = await _readLocalProfile();
          yield right(updatedProfile);
        }
      }
    } catch (_) {
      // Ignore background sync failure to avoid breaking offline experience
    }
  }
}
