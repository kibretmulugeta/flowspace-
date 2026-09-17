import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/first_run_category_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/notes/presentation/screens/notes_list_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/reminders/presentation/screens/reminders_screen.dart';
import '../../features/schedules/presentation/schedules_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/analytics_screen.dart';
import '../../features/settings/presentation/screens/appearance_screen.dart';
import '../../features/settings/presentation/screens/backup_sync_screen.dart';
import '../../features/settings/presentation/screens/more_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../widgets/adaptive_scaffold.dart';

/// Main Shell holding the 5 primary tabs with adaptive navigation
class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({super.key, this.initialIndex = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    CalendarScreen(),
    TasksScreen(),
    NotesListScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: _currentIndex,
      onNavigationIndexChanged: (index) {
        setState(() => _currentIndex = index);
      },
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }
}

/// Centralized route generator
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
      case '/calendar':
        return MaterialPageRoute(builder: (_) => const MainShellScreen(initialIndex: 1));
      case '/tasks':
        return MaterialPageRoute(builder: (_) => const MainShellScreen(initialIndex: 2));
      case '/notes':
        return MaterialPageRoute(builder: (_) => const MainShellScreen(initialIndex: 3));
      case '/more':
        return MaterialPageRoute(builder: (_) => const MainShellScreen(initialIndex: 4));
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/first-run-setup':
        return MaterialPageRoute(builder: (_) => const FirstRunCategoryScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case '/reminders':
        return MaterialPageRoute(builder: (_) => const RemindersScreen());
      case '/schedules':
        return MaterialPageRoute(builder: (_) => const SchedulesScreen());
      case '/projects':
        return MaterialPageRoute(builder: (_) => const ProjectsScreen());
      case '/categories':
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());
      case '/analytics':
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
      case '/appearance':
        return MaterialPageRoute(builder: (_) => const AppearanceScreen());
      case '/backup-sync':
        return MaterialPageRoute(builder: (_) => const BackupSyncScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
