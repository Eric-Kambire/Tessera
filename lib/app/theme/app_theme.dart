import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppTheme {
  static ThemeData light() {
    const textTheme = TextTheme(
      displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.blackText),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.blackText),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.blackText),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.blackText),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.neutralGray),
    );

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryGreen,
        background: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.white,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.blackText,
        ),
        iconTheme: IconThemeData(color: AppColors.blackText),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.neutralGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
      useMaterial3: true,
    );
  }
}
