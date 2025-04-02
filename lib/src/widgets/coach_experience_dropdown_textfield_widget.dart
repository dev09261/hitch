import 'package:flutter/material.dart';
import 'package:hitch/src/models/coach_experience_model.dart';
import 'package:hitch/src/res/app_text_styles.dart';

class CoachExperienceLevelsDropDownWidget extends StatelessWidget{
  const CoachExperienceLevelsDropDownWidget(
      {super.key,
      required this.isEmpty,
      required this.selectedValue,
      required this.onChanged,
      required this.experienceLevels,
      required this.width,
        required this.hintText,
      });

  final bool isEmpty;
  final CoachExperienceModel? selectedValue;
  final Function(CoachExperienceModel? newValue) onChanged;
  final List<CoachExperienceModel> experienceLevels;
  final double width;
  final String hintText;
  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelStyle: AppTextStyles.regularTextStyle,
            hintStyle: AppTextStyles.regularTextStyle.copyWith(color: Colors.grey),
            contentPadding: EdgeInsets.zero,
            errorStyle: AppTextStyles.regularTextStyle.copyWith(color: Colors.red),
            // hintText: 'Please select expense',
          ),
          isEmpty: isEmpty,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CoachExperienceModel >(
              value: selectedValue,
              hint: Text(hintText),
              isDense: true,
              elevation: 0,
              dropdownColor: Colors.white,
              /*onChanged: (PlayerLevelModel? newValue) {
                setState(()=> _selectedPickleBallPlayerLevel = newValue);
              },*/
              onChanged: onChanged,
              items: experienceLevels.map((CoachExperienceModel value) {
                return DropdownMenuItem<CoachExperienceModel>(
                  value: value,
                  child: SizedBox(
                    width: width,
                    child: Text('${value.experienceInYears} (${value.gameTitle})'),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

}