import 'package:flutter/material.dart';

abstract class DesignColors {
  // Main Backgrounds
  static const Color scaffoldBackground = Color(0xFFF7F7F7); // Slightly off-white for contrast
  static const Color keyBackground = Color(0xFFFFFFFF);
  static const Color keyBackgroundPressed = Color(0xFFF2F2F2);
  
  // Text Colors
  static const Color primaryText = Color(0xFF1E1E1E); // Nearly black, soft
  static const Color mathSymbolText = Color(0xFF000000); 
  static const Color secondaryText = Color(0xFF555555); // For labels like 'abc'
  static const Color placeholderText = Color(0xFF9E9E9E); // Grey for empty input
  
  // Special Keys
  static const Color operatorText = Color(0xFF1E1E1E); 
  
  // Accents & Actions
  static const Color primaryAction = Color(0xFFFD602E); // Main action color
  static const Color redAccent = Color(0xFFFD602E); // Photomath Red (Cursor, Dots)
  static const Color redDot = Color(0xFFFD602E);
  
  // Segmented Control
  static const Color segmentActiveBackground = Color(0xFF1E1E1E); // Black bubble
  static const Color segmentActiveText = Color(0xFFFFFFFF);
  static const Color segmentInactiveText = Color(0xFF7F7F7F);
  static const Color segmentBorder = Color(0xFFE0E0E0);

  // Borders & Separators
  static const Color keyBorder = Color(0xFFE5E5E5); // Subtle border
  static const Color gridSeparator = Colors.transparent; // We use gaps instead
  
  // Popups
  static const Color popupBackground = Color(0xFFFFFFFF);
  static const Color popupShadow = Color(0x1A000000); // Black 10%
}
