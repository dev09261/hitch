import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_text_styles.dart';

class MatchGendertypeWidget extends StatelessWidget{
  const MatchGendertypeWidget(
      {super.key,
      required this.selectedType,
      required this.typeList,
      required this.onTap,
      required this.headingTitle,
        this.comingFromFilter = false,
      this.height = 50});
  final String selectedType;
  final List<String> typeList;
  final Function(int index) onTap;
  final String headingTitle;
  final double height;
  final bool comingFromFilter;

  @override
  Widget build(BuildContext context) {
    final headingTextStyle = comingFromFilter
        ? const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryDarkColor)
        : const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.headingColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headingTitle, style: headingTextStyle),
        const SizedBox(height: 5,),
        Container(
          height: height,
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.greyColor)
          ),
          child: Center(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: typeList.length, // Number of columns
                childAspectRatio: 2.4, // Aspect ratio of each box
              ),
              itemCount: typeList.length,
              itemBuilder: (context, index) {
                final typeItem = typeList[index];
                bool isSelected = selectedType == typeItem;

                return GestureDetector(
                    onTap: ()=> onTap(index),
                    child: Container(
                      color: isSelected ? AppColors.primaryColor : null,
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                typeItem,
                                style: AppTextStyles.regularTextStyle.copyWith(color: isSelected ? Colors.white : AppColors.primaryDarkColor, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if(index != typeList.length-1)
                              Container(
                                height: 50,
                                width: 1,
                                color: AppColors.unSelectedItemColor,
                              )
                          ],
                        ),
                      ),
                    )
                );

              },
            ),
          ),
        ),
      ],
    );
  }

}