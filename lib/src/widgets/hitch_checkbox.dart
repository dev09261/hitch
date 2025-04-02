import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_text_styles.dart';

class HitchCheckbox extends StatelessWidget{
  final String text;
  final Function(bool? value) onChange;
  final bool value;
  const HitchCheckbox({super.key, required this.text, required this.onChange,required this.value});
  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
        horizontalTitleGap: 0,
        child:CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(text, overflow: TextOverflow.ellipsis, style: AppTextStyles.regularTextStyle,),
            controlAffinity: ListTileControlAffinity.leading,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
            activeColor: AppColors.primaryDarkColor,
            checkColor: AppColors.primaryDarkColor,
            checkboxShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            fillColor: WidgetStateProperty.all(value ? AppColors.primaryDarkColor : AppColors.checkboxFillColor),
            side: const BorderSide(color: AppColors.checkboxFillColor),
            value: value, onChanged: onChange),
    );
  }

}