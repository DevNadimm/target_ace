import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/services/notification_service.dart';
import 'package:target_ace/features/auth/data/models/auth_model.dart';
import 'package:target_ace/features/profile/data/repos/profile_repo.dart';
import 'package:target_ace/features/subscription/data/repos/subscription_repo.dart';

class AuthRepo {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Google Sign-In: authenticates with Supabase and saves session/profile.
  static Future<AuthModel> googleSignIn() async {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(serverClientId: AppConfig.googleWebClientId);

    GoogleSignInAccount? googleUser;
    try {
      final lightweightFuture = googleSignIn.attemptLightweightAuthentication();
      googleUser = lightweightFuture != null ? await lightweightFuture : null;
    } catch (_) {}

    googleUser ??= await googleSignIn.authenticate();

    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw const AuthException('Could not retrieve ID token from Google.');
    }

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    if (response.user == null) {
      throw const AuthException('Google Sign-In authentication failed.');
    }

    // Wait briefly for the DB trigger to populate public.profiles
    await Future.delayed(const Duration(milliseconds: 600));

    final profile = await _client.from('profiles').select().eq('id', response.user!.id).single();

    final userModel = UserModel(
      id: response.user!.id,
      name: profile['name'] as String? ?? response.user!.userMetadata?['name'] as String? ?? 'Student',
      email: response.user!.email ?? '',
      isAdmin: profile['is_admin'] as bool? ?? false,
      avatarUrl: profile['avatar_url'] as String?,
    );

    // Save user details locally
    await AppPreferences.setUserId(userModel.id);
    await AppPreferences.setUserName(userModel.name);
    await AppPreferences.setUserEmail(userModel.email);
    if (userModel.avatarUrl != null) {
      await AppPreferences.setUserAvatarUrl(userModel.avatarUrl!);
    }

    final goal = profile['goal'] as String? ?? '';
    final group = profile['group_id'] as String? ?? '';
    final institution = profile['institution'] as String? ?? '';
    final district = profile['district'] as String? ?? '';
    
    // Extract phone, gender, dob from profile DB or user metadata (e.g. Google auth metadata)
    final metadata = response.user!.userMetadata ?? {};
    final phone = profile['phone'] as String? ?? response.user!.phone ?? metadata['phone'] as String? ?? '';
    final gender = profile['gender'] as String? ?? metadata['gender'] as String? ?? '';
    final dob = profile['dob'] as String? ?? metadata['dob'] as String? ?? metadata['birthday'] as String? ?? metadata['birthdate'] as String? ?? '';


    await AppPreferences.setUserGoal(goal);
    await AppPreferences.setUserGroup(group);
    await AppPreferences.setUserInstitution(institution);
    await AppPreferences.setUserDistrict(district);
    await AppPreferences.setUserPhone(phone);
    await AppPreferences.setUserGender(gender);
    await AppPreferences.setUserDob(dob);

    // Fetch active group membership details
    try {
      final membership = await _client
          .from('group_memberships')
          .select('group_id, locked_until, battle_groups(title)')
          .eq('user_id', response.user!.id)
          .eq('is_active', true)
          .maybeSingle();

      if (membership != null) {
        final gId = membership['group_id'] as String;
        final lockedUntil = membership['locked_until'] as String;
        final bg = membership['battle_groups'] as Map<String, dynamic>?;
        final gTitle = bg != null ? (bg['title'] as String? ?? 'General') : 'General';

        await AppPreferences.saveGroupMembership(
          groupId: gId,
          groupTitle: gTitle,
          lockedUntil: lockedUntil,
        );
      } else if (group.isNotEmpty) {
        // Fallback or backfill
        await AppPreferences.saveGroupMembership(
          groupId: group,
          groupTitle: 'General',
          lockedUntil: '',
        );
      }
    } catch (_) {
      if (group.isNotEmpty) {
        await AppPreferences.saveGroupMembership(
          groupId: group,
          groupTitle: 'General',
          lockedUntil: '',
        );
      }
    }

    // Save subscription status
    final subscription = await SubscriptionRepo.fetchMySubscription();
    if (subscription != null) {
      await AppPreferences.saveSubscription(
        planId: int.tryParse(subscription.planId ?? '0') ?? 0,
        planName: subscription.planName ?? '',
        startDate: subscription.startDate ?? '',
        expiryDate: subscription.endDate ?? '',
        status: subscription.status,
      );
    } else {
      await AppPreferences.setSubscriptionStatus('none');
    }

    // Store FCM token after successful login
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await ProfileRepo.storeFcmToken(userId: response.user!.id, token: token);
      }
    } catch (_) {}

    return AuthModel(
      success: true,
      message: 'Sign-in successful',
      token: response.session?.accessToken ?? '',
      user: userModel,
      subscription: subscription,
    );
  }

  /// Logs the user out of Supabase and clears local preferences.
  static Future<void> logout() async {
    try {
      await NotificationService.instance.handleLogout();
    } catch (_) {}
    try {
      await _client.auth.signOut();
    } catch (_) {}
    await AppPreferences.clearAll();
  }

  /// Synchronizes local preferences with user profile data in Supabase.
  static Future<void> syncProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await _client.from('profiles').select().eq('id', user.id).single();

      final name = profile['name'] as String? ?? user.userMetadata?['name'] as String? ?? 'Student';
      final email = user.email ?? '';
      final avatarUrl = profile['avatar_url'] as String?;

      await AppPreferences.setUserId(user.id);
      await AppPreferences.setUserName(name);
      await AppPreferences.setUserEmail(email);
      if (avatarUrl != null) {
        await AppPreferences.setUserAvatarUrl(avatarUrl);
      }

      final goal = profile['goal'] as String? ?? '';
      final group = profile['group_id'] as String? ?? '';
      final institution = profile['institution'] as String? ?? '';
      final district = profile['district'] as String? ?? '';
      
      final metadata = user.userMetadata ?? {};
      final phone = profile['phone'] as String? ?? user.phone ?? metadata['phone'] as String? ?? '';
      final gender = profile['gender'] as String? ?? metadata['gender'] as String? ?? '';
      final dob = profile['dob'] as String? ?? metadata['dob'] as String? ?? metadata['birthday'] as String? ?? metadata['birthdate'] as String? ?? '';


      await AppPreferences.setUserGoal(goal);
      await AppPreferences.setUserGroup(group);
      await AppPreferences.setUserInstitution(institution);
      await AppPreferences.setUserDistrict(district);
      await AppPreferences.setUserPhone(phone);
      await AppPreferences.setUserGender(gender);
      await AppPreferences.setUserDob(dob);

      // Fetch active group membership details
      try {
        final membership = await _client
            .from('group_memberships')
            .select('group_id, locked_until, battle_groups(title)')
            .eq('user_id', user.id)
            .eq('is_active', true)
            .maybeSingle();

        if (membership != null) {
          final gId = membership['group_id'] as String;
          final lockedUntil = membership['locked_until'] as String;
          final bg = membership['battle_groups'] as Map<String, dynamic>?;
          final gTitle = bg != null ? (bg['title'] as String? ?? 'General') : 'General';

          await AppPreferences.saveGroupMembership(
            groupId: gId,
            groupTitle: gTitle,
            lockedUntil: lockedUntil,
          );
        } else if (group.isNotEmpty) {
          await AppPreferences.saveGroupMembership(
            groupId: group,
            groupTitle: 'General',
            lockedUntil: '',
          );
        }
      } catch (_) {}
    } catch (_) {}
  }
}

