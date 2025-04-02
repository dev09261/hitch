import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';

class AvailabilitySwitch extends StatelessWidget{
  const AvailabilitySwitch({super.key, required this.onEveryDayChange, required this.onMorningChange, required this.isAvailableDay, required this.isAvailableInMorning});
  final Function(bool val) onEveryDayChange;
  final Function(bool val) onMorningChange;
  final bool isAvailableDay;
  final bool isAvailableInMorning;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Transform.scale(scale: 0.85,
              child: CupertinoSwitch(
                value: isAvailableDay,
                thumbColor: Colors.white,
                inactiveTrackColor: isAvailableDay ? AppColors.primaryColor : AppColors.inActiveTrackColor,
                activeTrackColor: AppColors.primaryColor,
                onChanged: onEveryDayChange,
              ),
            ),
            const SizedBox(width: 5,),
            const Text("Everyday", style: TextStyle(fontSize: 16),)
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Transform.scale(scale: 0.85,
              child: CupertinoSwitch(
                value: isAvailableInMorning,
                thumbColor: Colors.white,
                trackColor: isAvailableInMorning ? AppColors.primaryColor : AppColors.inActiveTrackColor,
                activeColor: AppColors.primaryColor,
                onChanged: onMorningChange,
                // onChanged: (value)=> Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
              ),
            ),
            const SizedBox(width: 5,),
            const Text("Mornings", style: TextStyle(fontSize: 16),),
          ],
        ),
      ],
    );
  }

}