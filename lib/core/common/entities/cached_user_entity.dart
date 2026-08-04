/// Unified cached user entity that holds all user-related data
/// stored locally in SharedPreferences as a single JSON blob.
///
/// This is the domain layer entity — pure Dart, no dependencies.
/// All user profile, group membership, and subscription data lives here.
class CachedUserEntity {
  // ── Required Fields ──
  final String id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String dob;

  // ── Optional Fields ──
  final String avatarUrl;
  final String institution;
  final String district;
  final String goal;

  // ── Onboarding Profiling Fields ──
  final String howDidYouHear;
  final String dailyGoal;
  final List<String> learningModes;

  // ── Group Membership ──
  final String groupId;
  final String groupTitle;
  final String groupLockedUntil;

  // ── Subscription ──
  final String subscriptionStatus;
  final String subscriptionPlanName;
  final String subscriptionExpiryDate;

  const CachedUserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.gender = '',
    this.dob = '',
    this.avatarUrl = '',
    this.institution = '',
    this.district = '',
    this.goal = '',
    this.howDidYouHear = '',
    this.dailyGoal = '',
    this.learningModes = const [],
    this.groupId = '',
    this.groupTitle = '',
    this.groupLockedUntil = '',
    this.subscriptionStatus = 'none',
    this.subscriptionPlanName = '',
    this.subscriptionExpiryDate = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedUserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          gender == other.gender &&
          dob == other.dob &&
          avatarUrl == other.avatarUrl &&
          institution == other.institution &&
          district == other.district &&
          goal == other.goal &&
          howDidYouHear == other.howDidYouHear &&
          dailyGoal == other.dailyGoal &&
          groupId == other.groupId &&
          groupTitle == other.groupTitle &&
          groupLockedUntil == other.groupLockedUntil &&
          subscriptionStatus == other.subscriptionStatus &&
          subscriptionPlanName == other.subscriptionPlanName &&
          subscriptionExpiryDate == other.subscriptionExpiryDate;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        email,
        phone,
        gender,
        dob,
        avatarUrl,
        institution,
        district,
        goal,
        howDidYouHear,
        dailyGoal,
        Object.hashAll(learningModes),
        groupId,
        groupTitle,
        groupLockedUntil,
        subscriptionStatus,
        subscriptionPlanName,
        subscriptionExpiryDate,
      );
}
