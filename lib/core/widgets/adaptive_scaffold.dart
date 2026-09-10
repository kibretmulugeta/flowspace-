import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_layout.dart';

/// Navigation destination data model
class NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;

  const NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}

/// Adaptive scaffold switching between NavigationBar on mobile
/// and NavigationRail on tablet/desktop.
class AdaptiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigationIndexChanged;
  final Widget body;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;

  const AdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onNavigationIndexChanged,
    required this.body,
    this.floatingActionButton,
    this.appBar,
  });

  static const List<NavItem> navItems = [
    NavItem(
      label: AppStrings.navHome,
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      path: '/',
    ),
    NavItem(
      label: AppStrings.navCalendar,
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      path: '/calendar',
    ),
    NavItem(
      label: AppStrings.navTasks,
      icon: Icons.check_circle_outline,
      selectedIcon: Icons.check_circle,
      path: '/tasks',
    ),
    NavItem(
      label: AppStrings.navNotes,
      icon: Icons.article_outlined,
      selectedIcon: Icons.article,
      path: '/notes',
    ),
    NavItem(
      label: AppStrings.navMore,
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view,
      path: '/more',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isMobile) {
      return Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onNavigationIndexChanged,
          destinations: navItems.map((item) {
            return NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            );
          }).toList(),
        ),
      );
    }

    // Tablet & Desktop: NavigationRail on the left
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onNavigationIndexChanged,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.hub, color: Colors.white, size: 22),
                ),
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/search');
                    },
                    tooltip: 'Search',
                  ),
                ),
              ),
            ),
            destinations: navItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.label),
              );
            }).toList(),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
