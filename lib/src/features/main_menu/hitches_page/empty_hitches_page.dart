import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_icons.dart';

class EmptyHitchesPage extends StatelessWidget{
  const EmptyHitchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No Hitches", style: TextStyle(fontSize: 21, color: AppColors.darkGreyTextColor),),
            const SizedBox(height: 10,),
            SvgPicture.asset(AppIcons.navIcons[3]['off']!),
            const SizedBox(height: 10,),
            RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
              children: [
                TextSpan(text: "Send requests by tapping\n", style: TextStyle(fontSize: 21, color: AppColors.darkGreyTextColor, fontFamily: 'Inter'),),
                TextSpan(text: '“Lets Play”\n', style: TextStyle(fontSize: 21, color: AppColors.darkGreyTextColor, fontFamily: 'Inter', fontWeight: FontWeight.w600),),
                TextSpan(text: "for new connections.", style: TextStyle(fontSize: 21, color: AppColors.darkGreyTextColor, fontFamily: 'Inter'),),
              ]
            ))
          ],
        ),
      ),
    );
  }

}