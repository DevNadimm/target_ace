import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/features/notification/data/models/notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<void> storeFcmToken({required String userId, required String token});
  Future<List<NotificationModel>> fetchNotifications({required int page, required int limit});
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> deleteAllNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient _client;
  const NotificationRemoteDataSourceImpl(this._client);

  @override
  Future<void> storeFcmToken({required String userId, required String token}) async {
    try {
      await _client.from('user_device_tokens').upsert({
        'user_id': userId,
        'device_token': token,
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'device_token');
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<NotificationModel>> fetchNotifications({
    required int page,
    required int limit,
  }) async {
    try {
      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final response = await _client
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _client.from('notifications').update({'is_read': true}).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _client.from('notifications').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      await _client.from('notifications').delete().eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
