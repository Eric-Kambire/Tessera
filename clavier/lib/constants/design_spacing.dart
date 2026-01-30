abstract class DesignSpacing {
  // Global Layout
  static const double horizontalPadding = 8.0;
  static const double bottomPadding = 8.0;
  static const double inputAreaPadding = 16.0;
  static const double modalRadius = 16.0;

  // Keys
  static const double keySpacing = 6.0;
  static const double keyRadius = 8.0;
  static const double keyHeight = 52.0; // Fallback default

  // Red Dot
  static const double redDotSize = 4.0;
  static const double redDotPadding = 5.0;

  // Segmented Control
  static const double segmentHeight = 44.0;
  static const double segmentRadius = 22.0;

  // Popup
  static const double popupElevation = 8.0;
  static const double popupRadius = 12.0;

  /// Compute key height based on available width and column count.
  /// Maintains a consistent aspect ratio so keys scale with screen size.
  static double adaptiveKeyHeight(double availableWidth, int colCount) {
    final keyWidth = (availableWidth - keySpacing * colCount) / colCount;
    // Aspect ratio ~1.1 (slightly taller than wide), clamped to reasonable bounds
    final height = (keyWidth * 1.05).clamp(36.0, 64.0);
    return height;
  }

  /// Compute font size based on available width and column count.
  static double adaptiveFontSize(double availableWidth, int colCount) {
    final keyWidth = (availableWidth - keySpacing * colCount) / colCount;
    // Font scales with key width, clamped to readable range
    return (keyWidth * 0.32).clamp(10.0, 22.0);
  }
}
