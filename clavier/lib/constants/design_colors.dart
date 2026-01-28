import 'package:flutter/material.dart';

abstract class DesignColors {
  // Main Backgrounds
  static const Color scaffoldBackground = Color(0xFFFFFFFF);
  static const Color sheetBackground = Color(0xFFFFFFFF);
  static const Color keyBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color primaryText = Color(0xFF4C4F54); // Dark Grey
  static const Color secondaryText = Color(0xFF7F7F7F); // Light Grey
  static const Color placeholderText = Color(0xFFAAAAAA);

  // Accents & Actions
  static const Color primaryAction = Color(0xFFFD602E); // Photomath Red/Orange
  static const Color selectionRed = Color(0xFFDA291C); // For matrix selection

  // Borders & Separators
  static const Color keyBorder = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Key States
  static const Color keyPressed = Color(0xFFF3F3F3);

  // Segmented Control
  static const Color segmentActive = Color(0xFF000000); // Black
  static const Color segmentActiveText = Color(0xFFFFFFFF); // White
  static const Color segmentInactive = Color(0xFFFFFFFF); // White
  static const Color segmentInactiveText = Color(0xFF7F7F7F); // Grey
}
