import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';

class PrimaryBtn extends StatelessWidget{
  final String btnText;
  final VoidCallback onTap;
  final bool isLoading;
  final Color bgColor;
  final Color? borderColor;
  final bool isPremium;
  final Color textColor;

  const PrimaryBtn(
      {super.key,
      required this.btnText,
      required this.onTap,
      this.isLoading = false,
      this.bgColor = AppColors.primaryColor,
        this.textColor = Colors.white,
      this.borderColor,
      this.isPremium = false});
  @override
  Widget build(BuildContext context) {
    return isLoading ?  Center(child: CircularProgressIndicator(color: bgColor,),) : ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shadowColor: Colors.transparent,
          elevation: 0,
          side: borderColor != null ? BorderSide(color: borderColor!, width: 2) : null
        ),
        onPressed: onTap, child: Padding(
          padding:  isPremium ? const EdgeInsets.symmetric(vertical: 5,): EdgeInsets.zero,
          child: Text(
                btnText,
                textAlign: TextAlign.center,
                style:  TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: textColor),
              ),
        ));
  }

}