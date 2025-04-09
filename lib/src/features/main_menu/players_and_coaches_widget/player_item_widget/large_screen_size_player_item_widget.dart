import 'package:flutter/material.dart';
import 'package:hitch/src/features/main_menu/players_and_coaches_widget/player_item_widget/player_info_widget.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/providers/subscription_provider.dart';
import 'package:provider/provider.dart';
import '../../../../widgets/hitch_profile_image.dart';

class LargeScreenSizePlayerItemWidget  extends StatelessWidget{
  final UserModel player;
  final double distanceInMiles;
  final Size size;

  const LargeScreenSizePlayerItemWidget({
    super.key,
    required this.player,
    required this.distanceInMiles,
    required this.size,
  });
  @override
  Widget build(BuildContext context) {
    bool isSubscribed = Provider.of<SubscriptionProvider>(context).getIsSubscribed;
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Stack(
        children: [
          Card(
            margin:  EdgeInsets.only(top: 75, bottom: isSubscribed ? 40 : 20),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
            child:Container(
              decoration:  BoxDecoration(
                color: Colors.white,
                // shape: BoxShape.circle,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.grey, spreadRadius: 1)],
              ),
              child: Container(
                  padding:  EdgeInsets.only(top: size.height*0.08),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffBFBCBC)),

                  ),
                  child: PlayerInfoWidget(player: player, distanceInMiles: distanceInMiles,)
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 15,
            child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey, spreadRadius: 2)],
                ),
                child: HitchProfileImage(profileUrl: player.profilePicture, size:  size.height > 760 ? 125.0 : 100.0,)
            ),
          ),
        ],
      ),
    );
  }

}