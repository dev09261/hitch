import 'package:flutter/material.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/res/string_constants.dart';

import 'large_screen_size_player_item_widget.dart';
import 'small_screen_size_player_item_widget.dart';

class PlayerCoachItemWidget extends StatefulWidget{
  final Map<String, dynamic> playerMap;
  final bool comingFromCoach;
  const PlayerCoachItemWidget({super.key, required this.playerMap, this.comingFromCoach = false});

  @override
  State<PlayerCoachItemWidget> createState() => _PlayerCoachItemWidgetState();
}

class _PlayerCoachItemWidgetState extends State<PlayerCoachItemWidget> with SingleTickerProviderStateMixin{
  late UserModel player;
  late double distanceInMiles;
  @override
  void initState() {
    player = widget.playerMap[playerKey];
    distanceInMiles = widget.playerMap[distanceKey];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return size.height <= 670
        ? SmallScreenSizePlayerItemWidget(player: player, distanceInMiles: distanceInMiles, )
        : LargeScreenSizePlayerItemWidget(player: player, distanceInMiles: distanceInMiles, size: size,);
  }
}