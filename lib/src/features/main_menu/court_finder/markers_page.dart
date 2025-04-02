import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_icons.dart';
import 'package:hitch/src/res/app_text_styles.dart';

class TextOnImage extends StatelessWidget {
  const TextOnImage({
    super.key,
    required this.text,
  });
  final String text;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(AppIcons.icPickleBallMap, height: 50,),
        Text(text, style: AppTextStyles.subHeadingTextStyle.copyWith(fontWeight: FontWeight.w700, color: Colors.black))
      ],
    );
  }
}