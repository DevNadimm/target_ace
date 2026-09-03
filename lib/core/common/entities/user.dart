/// Core User entity shared across all features.
///
/// This is a domain entity -- pure Dart, no dependencies on any package.
/// Feature-specific user models (e.g., UserModel in auth/data) should
/// extend this class and add serialization methods.
///
/// Example:
/// ```dart
/// class UserModel extends User {
///   UserModel({required super.id, required super.email, required super.name});
///
///   factory UserModel.fromJson(Map<String, dynamic> json) { ... }
///   Map<String, dynamic> toJson() { ... }
/// }
/// ```
class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, email: $email, name: $name)';
}