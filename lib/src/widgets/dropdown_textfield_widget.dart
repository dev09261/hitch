import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import '../models/player_level_model.dart';

class PlayerLevelDropdownTextfieldWidget extends StatelessWidget{
  const PlayerLevelDropdownTextfieldWidget(
      {super.key,
      required this.isEmpty,
      required this.selectedValue,
      required this.onChanged,
      required this.playerLevels,
      required this.width,
        required this.hintText,
      });

  final bool isEmpty;
  final PlayerLevelModel? selectedValue;
  final Function(PlayerLevelModel? newValue) onChanged;
  final List<PlayerLevelModel> playerLevels;
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
            child: DropdownButton<PlayerLevelModel >(
              value: selectedValue,
              hint: Text(hintText),
              isDense: true,
              elevation: 0,
              dropdownColor: Colors.white,
              /*onChanged: (PlayerLevelModel? newValue) {
                setState(()=> _selectedPickleBallPlayerLevel = newValue);
              },*/
              onChanged: onChanged,
              items: playerLevels.map((PlayerLevelModel value) {

                String levelLabel = value.levelRank;

                if (levelLabel == '2.0') {
                  levelLabel = '0.0 - 2.99';
                } else if (levelLabel == '3.0') {
                  levelLabel = '3.0 - 3.99';
                } else if (levelLabel == '4.0') {
                  levelLabel = '4.0 - 4.99';
                } else if (levelLabel == '5.0') {
                  levelLabel = '5.0 - 5.99';
                } else if (levelLabel == '6.0') {
                  levelLabel = '6.0 - 6.99';
                } else if (levelLabel == '7.0') {
                  levelLabel = '7.0 - 7.99';
                } else if (levelLabel == '8.0') {
                  levelLabel = '8.0 - ';
                }

                return DropdownMenuItem<PlayerLevelModel>(
                  value: value,
                  child: SizedBox(
                    width: width,
                    child: Row(
                      children: [
                        Text(levelLabel),
                        const SizedBox(width: 20,),
                        Expanded(child: Text(value.levelTitle),),
                      ],
                    ),
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