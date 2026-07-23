import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/features/notification/data/models/notification_model.dart';

class NotificationRepo {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all notifications for the authenticated user, sorted by newest first.
  static Future<List<NotificationModel>> fetchNotifications() async {
    final response = await _client
        .from('notifications')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Mark a specific notification as read.
  static Future<void> markAsRead(String id) async {
    await _client.from('notifications').update({'is_read': true}).eq('id', id);
  }

  /// Mark all notifications for the user as read.
  static Future<void> markAllAsRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  /// Delete a single notification.
  static Future<void> deleteNotification(String id) async {
    await _client.from('notifications').delete().eq('id', id);
  }

  /// Delete all notifications for the user.
  static Future<void> deleteAllNotifications() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('notifications').delete().eq('user_id', userId);
  }
}
