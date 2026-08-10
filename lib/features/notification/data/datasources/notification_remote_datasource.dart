import 'package:target_ace/core/network/base_remote_datasource.dart';
import 'package:target_ace/features/notification/data/models/notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<void> storeFcmToken({required String userId, required String token});
  Future<List<NotificationModel>> fetchNotifications({required int page, required int limit});
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> deleteAllNotifications();
}

class NotificationRemoteDataSourceImpl extends BaseRemoteDataSource implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl(super.client);

  @override
  Future<void> storeFcmToken({required String userId, required String token}) async {
    try {
      await client.from('user_device_tokens').upsert({
        'user_id': userId,
        'device_token': token,
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'device_token');
    } catch (e) {
      handleException(e);
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

      final response = await client
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await client.from('notifications').update({'is_read': true}).eq('id', id);
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await client.from('notifications').delete().eq('id', id);
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;
      await client.from('notifications').delete().eq('user_id', userId);
    } catch (e) {
      handleException(e);
    }
  }
}