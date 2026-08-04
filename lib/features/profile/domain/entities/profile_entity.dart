class ProfileEntity {
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String dob;
  final String institution;
  final String district;
  final String avatarUrl;
  final String subscriptionPlanName;
  final String subscriptionStatus;
  final String subscriptionExpiry;
  final String activeGroupTitle;

  const ProfileEntity({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.institution,
    required this.district,
    required this.avatarUrl,
    required this.subscriptionPlanName,
    required this.subscriptionStatus,
    required this.subscriptionExpiry,
    required this.activeGroupTitle,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileEntity &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          gender == other.gender &&
          dob == other.dob &&
          institution == other.institution &&
          district == other.district &&
          avatarUrl == other.avatarUrl &&
          subscriptionPlanName == other.subscriptionPlanName &&
          subscriptionStatus == other.subscriptionStatus &&
          subscriptionExpiry == other.subscriptionExpiry &&
          activeGroupTitle == other.activeGroupTitle;

  @override
  int get hashCode =>
      name.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      gender.hashCode ^
      dob.hashCode ^
      institution.hashCode ^
      district.hashCode ^
      avatarUrl.hashCode ^
      subscriptionPlanName.hashCode ^
      subscriptionStatus.hashCode ^
      subscriptionExpiry.hashCode ^
      activeGroupTitle.hashCode;
}
