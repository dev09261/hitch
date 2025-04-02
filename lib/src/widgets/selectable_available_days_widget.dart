import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_text_styles.dart';

class SelectableAvailableDaysWidget extends StatelessWidget{
  const SelectableAvailableDaysWidget({super.key, required this.daysAvailable, required this.onTap});

  final List<Map<String, dynamic>> daysAvailable;
  final Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.greyColor)
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // Number of columns
            childAspectRatio: 1.0, // Aspect ratio of each box
          ),
          itemCount: daysAvailable.length,
          itemBuilder: (context, index) {
            final dayItem = daysAvailable[index];
            return GestureDetector(
                onTap: ()=> onTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: dayItem['isSelected'] ? AppColors.primaryColor : null,
                  ),
                  child: Center(
                    child: Text(
                      dayItem['day'].toString()[0],
                      style:  AppTextStyles.regularTextStyle.copyWith(color:  dayItem['isSelected'] ? Colors.white : AppColors.unSelectedItemColor, fontWeight: FontWeight.w600) ,
                    ),
                  ),
                ));
          },
        )
    );
  }

}