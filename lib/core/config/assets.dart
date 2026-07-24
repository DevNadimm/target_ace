class Assets {
  Assets._();

  /// ── Base Paths ──────────────────────────────────────────────────────────
  static const String _iconPath = 'assets/images/icons';
  static const String _flagPath = 'assets/images/flags';
  static const String _illustrationPath = 'assets/images/illustrations';
  static const String _logoPath = 'assets/logos';
  static const String _svgIconPath = 'assets/icons';
  static const String _animPath = 'assets/anim';

  /// ── Navigation Icons (SVGs) ──────────────────────────────────────────────
  static const String homeFilled = '$_svgIconPath/home_filled.svg';
  static const String homeOutlined = '$_svgIconPath/home_outlined.svg';
  static const String bookFilled = '$_svgIconPath/book_filled.svg';
  static const String bookOutlined = '$_svgIconPath/book_outlined.svg';
  static const String awardFilled = '$_svgIconPath/award_filled.svg';
  static const String awardOutlined = '$_svgIconPath/award_outlined.svg';
  static const String profileFilled = '$_svgIconPath/profile_filled.svg';
  static const String profileOutlined = '$_svgIconPath/profile_outlined.svg';
  static const String boltFilled = '$_svgIconPath/bolt_filled.svg';
  static const String boltOutlined = '$_svgIconPath/bolt_outlined.svg';
  static const String archiveOutlined = '$_svgIconPath/archive_outlined.svg';

  /// ── Badges ────────────────────────────────────────────────────────────────
  static const String firstBadge = '$_iconPath/1st_badge.png';
  static const String secondBadge = '$_iconPath/2nd_badge.png';
  static const String thirdBadge = '$_iconPath/3rd_badge.png';
  static const String knightMascot = '$_iconPath/knight_mascot.png';

  /// ── Flags ─────────────────────────────────────────────────────────────────
  static const String bnFlag = '$_flagPath/bn.png';
  static const String enFlag = '$_flagPath/en.png';

  /// ── Error & Placeholder States ────────────────────────────────────────────
  static const String error = '$_iconPath/error.png';
  static const String networkError = '$_iconPath/network_error.png';
  static const String serverError = '$_iconPath/server_error.png';
  static const String notFoundError = '$_iconPath/not_found_error.png';
  static const String noContent = '$_iconPath/no-content.png';
  static const String noNotification = '$_iconPath/no-notification.png';
  static const String noImage = '$_iconPath/no-image.png';

  /// ── Common Icons ──────────────────────────────────────────────────────────
  static const String search = '$_iconPath/search.png';
  static const String avatar = '$_iconPath/avatar.jpg';
  static const String gorilla = '$_iconPath/gorilla.png';
  static const String premium = '$_iconPath/premium.png';
  static const String google = '$_iconPath/google.png';
  static const String streakFlame = '$_iconPath/streak_flame.png';

  /// ── Logos ─────────────────────────────────────────────────────────────────
  static const String appLogo = '$_logoPath/app_logo.png';

  /// ── Illustrations ─────────────────────────────────────────────────────────
  static const String auth = '$_illustrationPath/auth.svg';
  static const String development = '$_illustrationPath/development.svg';

  /// ── Animations (Lottie) ───────────────────────────────────────────────────
  static const String flameAnim = '$_animPath/flame_anim.json';
}
