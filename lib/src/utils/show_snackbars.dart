import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_text_styles.dart';

class ShowSnackbars {
  static void showErrorSnackBar(BuildContext context, {required String errorMsgTitle, required String errorMsgTxt}){
    ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          backgroundColor: Colors.red,
          duration: const Duration(
            seconds: 2
          ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMsgTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),),
            const SizedBox(height: 5,),
            Text(errorMsgTxt, style: AppTextStyles.regularTextStyle.copyWith(color: Colors.white),)
          ],
    )));
  }
}