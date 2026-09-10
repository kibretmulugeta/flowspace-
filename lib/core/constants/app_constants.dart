/// Global application constants for FlowSpace
class AppConstants {
  static const String appName = 'FlowSpace';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Unified Productivity Workspace';

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration standardAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Storage Keys
  static const String keyThemeMode = 'flowspace_theme_mode';
  static const String keyAccentColor = 'flowspace_accent_color';
  static const String keyOnboardingComplete = 'flowspace_onboarding_complete';
  static const String keyFirstRunComplete = 'flowspace_first_run_complete';
  static const String keyAuthToken = 'flowspace_auth_token';
  static const String keyCurrentUser = 'flowspace_current_user';
  static const String keySelectedWorkspace = 'flowspace_selected_workspace';

  // Default Time Intervals
  static const int defaultSnoozeMinutes = 15;
  static const int defaultTaskDurationMinutes = 30;
}
