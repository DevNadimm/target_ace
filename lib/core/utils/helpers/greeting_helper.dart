class GreetingHelper {
  GreetingHelper._();

  static String getGreeting() {
    final hour = DateTime.now().hour;

    switch (hour) {
      case >= 5 && < 12:
        return 'Good Morning';
      case >= 12 && < 17:
        return 'Good Afternoon';
      default:
        return 'Good Evening';
    }
  }
}