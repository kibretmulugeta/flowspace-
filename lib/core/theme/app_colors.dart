import 'package:flutter/material.dart';

/// Centralized color palette for FlowSpace
/// Calibrated for calm, minimalist, high-contrast productivity aesthetics.
class AppColors {
  // Light Palette
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightBorderSubtle = Color(0xFFF3F4F6);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextMuted = Color(0xFF9CA3AF);

  // Dark Palette
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF161922);
  static const Color darkSurfaceVariant = Color(0xFF1E2330);
  static const Color darkCard = Color(0xFF181B26);
  static const Color darkBorder = Color(0xFF272D3D);
  static const Color darkBorderSubtle = Color(0xFF1E2330);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Accent Color Presets
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentOrange = Color(0xFFF97316);

  // Priority Colors
  static const Color priorityUrgent = Color(0xFFEF4444);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF3B82F6);
  static const Color priorityNone = Color(0xFF94A3B8);

  // Status Colors
  static const Color statusPlanning = Color(0xFF8B5CF6);
  static const Color statusActive = Color(0xFF10B981);
  static const Color statusOnHold = Color(0xFFF59E0B);
  static const Color statusCompleted = Color(0xFF3B82F6);
  static const Color statusArchived = Color(0xFF64748B);

  // Notion-style Block / Tag Highlights
  static const List<Color> categoryPalette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFF84CC16), // Lime
  ];
}
