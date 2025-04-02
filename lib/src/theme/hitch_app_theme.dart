import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';

class HitchAppTheme{
  static ThemeData hitchAppTheme = ThemeData(
    fontFamily: 'Inter',
    brightness: Brightness.light,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
    useMaterial3: true,
  );
}