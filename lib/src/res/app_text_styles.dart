import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';

class AppTextStyles {
  //Light theme colors
  static const subHeadingTextStyle = TextStyle(fontSize: 26, fontWeight: FontWeight.w300, color: AppColors.primaryColorVariant1);
  static const headingTextStyle = TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: AppColors.textPrimaryColor);
  static const pageHeadingStyle = TextStyle(fontSize: 26, fontWeight: FontWeight.w500, fontFamily: 'Inter', color: AppColors.primaryColor);
  static const regularTextStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.greyTextColor);
  static const textFieldHeadingStyle = TextStyle(fontSize: 16, color: AppColors.headingColor);
}