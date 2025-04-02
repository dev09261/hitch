import 'package:flutter/material.dart';
import 'package:hitch/src/features/main_menu/players_and_coaches_widget/player_item_widget/player_info_widget.dart';
import 'package:hitch/src/models/user_model.dart';
import '../../../../widgets/hitch_profile_image.dart';

class SmallScreenSizePlayerItemWidget  extends StatelessWidget{
  final UserModel player;
  final double distanceInMiles;
  const SmallScreenSizePlayerItemWidget({super.key, required this.player, required this.distanceInMiles,});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      child: Column(
        children: [
          Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey, spreadRadius: 2)],
              ),
              child: HitchProfileImage(
                profileUrl: player.profilePicture,
                size:  65.0,
              )),
          Expanded(
              child: PlayerInfoWidget(
            player: player,
            distanceInMiles: distanceInMiles,
          ))
        ],
      ),
    );
  }

}