import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for checking internet connectivity at the repository level.
///
/// This is used inside RepositoryImpl to decide whether to fetch from
/// remote (Supabase) or local (cache) data source.
///
/// Unlike [NetworkMonitorMixin] (which is UI-level, stream-based),
/// this is a one-shot check used in data-flow decisions.
///
/// Example:
/// ```dart
/// class BlogRepositoryImpl implements BlogRepository {
///   final ConnectionChecker connectionChecker;
///
///   Future<Either<Failure, List<Blog>>> getAllBlogs() async {
///     if (!await connectionChecker.isConnected) {
///       return right(localDataSource.loadBlogs()); // Offline fallback
///     }
///     final blogs = await remoteDataSource.getAllBlogs();
///     return right(blogs);
///   }
/// }
/// ```
abstract interface class ConnectionChecker {
  Future<bool> get isConnected;
}

/// Implementation that uses [connectivity_plus] for network-type check,
/// then verifies actual internet access by looking up a DNS record.
class ConnectionCheckerImpl implements ConnectionChecker {
  final Connectivity _connectivity;

  const ConnectionCheckerImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();

    // No network interface at all
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return false;
    }

    // Network interface exists — verify actual internet access
    try {
      // Use raw IP socket connection to bypass OS DNS caching.
      // Connecting to Google Public DNS (8.8.8.8) on port 53 (DNS port).
      // This is the fastest and most reliable way to check actual external route.
      final socket = await Socket.connect('8.8.8.8', 53, timeout: const Duration(seconds: 3));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}