import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';

class PlayerCoachInfoItemWidget extends StatelessWidget {
  const PlayerCoachInfoItemWidget({
    super.key,
    required this.title,
    required this.value
  });
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(title, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: const TextStyle(fontSize: 14, color: AppColors.greyTextColor, fontWeight: FontWeight.w400),)),
          const SizedBox(width: 20,),
          Expanded(
              flex: 2,
              child: Text(value, overflow: TextOverflow.ellipsis,  textAlign: TextAlign.start,maxLines: 2, style: const TextStyle(fontSize: 14,),))
        ],
      ),
    );
  }
}