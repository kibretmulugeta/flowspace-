import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Responsive layout helper for phone, tablet, and desktop viewports
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.mobileBreakpoint && width < AppConstants.desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= AppConstants.desktopBreakpoint && desktop != null) {
      return desktop!;
    }
    if (width >= AppConstants.mobileBreakpoint && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}
