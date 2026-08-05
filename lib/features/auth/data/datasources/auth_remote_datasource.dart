import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/features/auth/data/models/user_model.dart';
import 'package:target_ace/features/subscription/data/models/subscription_model.dart';
import 'package:target_ace/features/subscription/data/datasources/subscription_remote_datasource.dart';

abstract interface class AuthRemoteDataSource {
  supabase.User? get currentUser;
  Session? get currentSession;
  Future<UserModel> googleSignIn();
  Future<void> logout();
  Future<Map<String, dynamic>> fetchProfile(String userId);
  Future<SubscriptionModel?> fetchSubscription();
  Future<void> saveFcmToken(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;
  final GoogleSignIn _googleSignIn;
  final SubscriptionRemoteDataSource _subscriptionRemoteDataSource;

  const AuthRemoteDataSourceImpl(
    this._supabaseClient,
    this._googleSignIn,
    this._subscriptionRemoteDataSource,
  );

  @override
  supabase.User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Session? get currentSession => _supabaseClient.auth.currentSession;

  @override
  Future<UserModel> googleSignIn() async {
    try {
      await _googleSignIn.initialize(serverClientId: AppConfig.googleWebClientId);

      GoogleSignInAccount? googleUser;
      try {
        final lightweightFuture = _googleSignIn.attemptLightweightAuthentication();
        googleUser = lightweightFuture != null ? await lightweightFuture : null;
      } catch (_) {}

      try {
        googleUser ??= await _googleSignIn.authenticate();
      } catch (e) {
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('canceled') || errorStr.contains('cancelled')) {
          throw const ServerException(message: 'CANCELED_BY_USER');
        }
        throw ServerException(message: 'Google Sign-In failed. Please try again: $e');
      }



      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw const ServerException(message: 'Could not retrieve account credentials.');
      }

      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (response.user == null) {
        throw const ServerException(message: 'Connection failed. Please check your internet.');
      }

      final metadata = response.user!.userMetadata ?? {};
      return UserModel(
        id: response.user!.id,
        name: metadata['name'] as String? ?? 'Student',
        email: response.user!.email ?? '',
        isAdmin: false, 
        avatarUrl: metadata['avatar_url'] as String?,
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Something went wrong. Please check your connection.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabaseClient.auth.signOut();
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect().catchError((_) => null);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    try {
      final response = await _supabaseClient.rpc(
        'get_user_profile_with_subscription',
        params: {'p_user_id': userId},
      );
      final payload = Map<String, dynamic>.from(response as Map);
      final profile = Map<String, dynamic>.from(payload['profile'] as Map);
      final subscription = payload['subscription'] as Map<String, dynamic>?;
      if (subscription != null) {
        profile['subscription'] = subscription;
      }
      return profile;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SubscriptionModel?> fetchSubscription() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return SubscriptionModel(status: 'none');

      final isPremium = await _subscriptionRemoteDataSource.fetchIsPremium(userId);

      if (isPremium) {
        final approvedSub = await _subscriptionRemoteDataSource.fetchLatestApprovedSubscription(userId);

        if (approvedSub != null) {
          return approvedSub;
        }

        return SubscriptionModel(
          status: 'active',
          planId: 'premium',
          planName: 'Premium Monthly',
          startDate: DateTime.now().toIso8601String(),
          endDate: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        );
      } else {
        final latestSub = await _subscriptionRemoteDataSource.fetchLatestSubscription(userId);

        if (latestSub != null && latestSub.status == 'pending') {
          return SubscriptionModel(
            status: 'pending_verification',
            planId: latestSub.planId,
            planName: latestSub.planName,
          );
        }
      }

      return SubscriptionModel(status: 'none');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> saveFcmToken(String userId) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _supabaseClient.from('user_device_tokens').upsert({
          'user_id': userId,
          'device_token': token,
          'last_seen_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'user_id,device_token');
      }
    } catch (_) {}
  }
}