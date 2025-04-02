import 'package:flutter/material.dart';

import '../res/app_colors.dart';
import '../services/hitches_service.dart';

class PlayerHitchesCountWidget extends StatelessWidget {
  const PlayerHitchesCountWidget({
    super.key,
    required this.userID,
  });

  final String userID;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: HitchesService.getPlayerHitchCount(userID), builder: (ctx, snapshot){
      if(snapshot.hasData && snapshot.requireData > 0){
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: RichText(text: TextSpan(
              children: [
                TextSpan(
                    text: '${snapshot.requireData} ',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: AppColors.darkGreyTextColor)
                ),
                const TextSpan(
                    text: 'Hitches',
                    style: TextStyle(fontSize: 14, fontFamily: 'Inter', color: AppColors.darkGreyTextColor)
                )
              ]
          ),),
        );
      }
      return const SizedBox();
    });
  }
}