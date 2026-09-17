/// Named route paths for FlowSpace navigation
class AppRoutes {
  // Shell tabs
  static const String home = '/';
  static const String calendar = '/calendar';
  static const String tasks = '/tasks';
  static const String notes = '/notes';
  static const String more = '/more';

  // Auth & Onboarding
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String firstRunSetup = '/first-run-setup';

  // Sub-routes
  static const String taskDetail = '/tasks/:id';
  static const String noteDetail = '/notes/:id';
  static const String projectDetail = '/projects/:id';
  static const String search = '/search';
  static const String reminders = '/reminders';
  static const String schedules = '/schedules';
  static const String projects = '/projects';
  static const String categories = '/categories';
  static const String settings = '/settings';
  static const String analytics = '/analytics';
  static const String appearance = '/appearance';
  static const String backupSync = '/backup-sync';
}
