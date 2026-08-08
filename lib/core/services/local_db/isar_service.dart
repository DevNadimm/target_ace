import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static late final Isar _db;

  /// Returns the Isar instance
  static Isar get db => _db;

  /// Initializes the Isar database.
  /// Call this in main.dart before runApp().
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    
    // NOTE: Isar requires at least one schema to open.
    // Since the feature is not finalized, the schema list is currently empty.
    // Uncomment and add schemas once they are created.
    
    /*
    _db = await Isar.open(
      [
        // TODO: Add your Collection schemas here
        // PracticeQuestionSchema,
        // UserProgressSchema,
      ],
      directory: dir.path,
    );
    */
  }
}
