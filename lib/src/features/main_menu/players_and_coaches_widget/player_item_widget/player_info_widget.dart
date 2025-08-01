import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitch/src/bloc_cubit/players_coaches_cubit/players_coaches_cubit.dart';
import 'package:hitch/src/features/main_menu/hitches_page/hitch_request_widget.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/widgets/lets_play_button.dart';
import 'package:hitch/src/widgets/primary_btn.dart';
import 'package:hitch/src/widgets/secondary_btn.dart';

import '../../../../models/hitches_model.dart';
import '../../../../res/app_colors.dart';
import '../../../../services/hitches_service.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/player_hitches_count_widget.dart';
import '../../../user_profile/user_info_page.dart';
import '../player_coach_info_item_widget.dart';

class PlayerInfoWidget extends StatelessWidget{
  const PlayerInfoWidget({super.key, required this.player, required this.distanceInMiles,});
  final UserModel player;
  final double distanceInMiles;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlayerHitchesCountWidget(userID: player.userID,),
        Text(player.userName, style: const TextStyle(fontSize: 24, color: AppColors.primaryColor),),
        const SizedBox(height: 10,),
        PlayerCoachInfoItemWidget(title: "Bio", value: player.bio),
        // PlayerCoachInfoItemWidget(title: "Player Type", value: 'Tennis: ${player.playerTypeTennis}\nPickle:${player.playerTypePickle}\nCoach: ${player.playerTypeCoach}'),
        const SizedBox(height: 10,),
        player.playerTypeCoach
            ? PlayerCoachInfoItemWidget(
            title: 'Experience',
            value: Utils.getCoachExperienceDetails(player))
            : PlayerCoachInfoItemWidget(title: "Age", value: (player.age == null || player.age!.isEmpty) ? '-' : player.age!),
        const SizedBox(height: 10,),
        if(!player.playerTypeCoach)
          PlayerCoachInfoItemWidget(title: "Level", value: Utils.getPlayerLevelText(player)),
        const SizedBox(height: 10,),
        _buildLocationWidget(distanceInMiles),

        const Spacer(),
        TextButton(onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> UserInfoPage(player: player.userID)));
        }, child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Show more", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.primaryColor,),),
            SizedBox(width: 5,),
            Icon(Icons.navigate_next_rounded, color: AppColors.primaryColor,)
          ],
        )),
        const Spacer(),

        Align(
          alignment: Alignment.center,
          child: StreamBuilder(stream: HitchesService.getUserHitchRequest(),builder: (ctx, snapshot){
            if(snapshot.hasData && snapshot.requireData.isNotEmpty){
              List<HitchesModel> hitches = snapshot.requireData;
              late HitchesModel hitchRequest;

              if(hitches.isNotEmpty){
                hitches  = hitches.where((hitchItem)=> hitchItem.user.userID == player.userID).toList();
                if(hitches.isNotEmpty){
                  hitchRequest =  hitches.last;
                  return HitchRequestStatusWidget(hitchRequest: hitchRequest,);
                }
              }
            }

            //Lets Play Button Here
            if (player.playerTypeCoach)
              return LetsPlayButton(player: player);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 80,
                    child: SecondaryBtn(btnText: 'Hide', onTap: () {
                      HitchesService.addHideUser(hider: player);
                      final playersCoachesCubit = context.read<PlayersCoachesCubit>();
                      playersCoachesCubit.carouselCtrl.jumpToPage(0);
                })),
                const SizedBox(width: 10,),
                SizedBox(
                    width: 130,
                    child: LetsPlayButton(player: player)),
              ],
            );
          }),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildLocationWidget(double distanceInMiles) {
    if(player.latitude != null && player.longitude != null){
      return FutureBuilder(future: Utils.getUserLocationFromLatLng(player.latitude!, player.longitude!), builder: (ctx, snapshot){
        if(snapshot.hasData){
          return PlayerCoachInfoItemWidget(title: "Location", value: '${distanceInMiles.toStringAsFixed(2)} miles away (${snapshot.requireData})');
        }
        return PlayerCoachInfoItemWidget(title: "Location", value: '${distanceInMiles.toStringAsFixed(2)} miles away(...)');
      });
    }else {
      return const PlayerCoachInfoItemWidget(title: "Location", value: 'Unknown');
    }
  }
}
