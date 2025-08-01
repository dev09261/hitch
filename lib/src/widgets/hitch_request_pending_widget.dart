import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hitch/src/features/paywalls/filter_subscription_paywall.dart';
import 'package:hitch/src/helpers/ad_helper.dart';
import 'package:hitch/src/models/hitches_model.dart';
import 'package:hitch/src/providers/subscription_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/services/hitches_service.dart';
import 'package:hitch/src/widgets/ad_video.dart';
import 'package:provider/provider.dart';

class HitchRequestPendingWidget extends StatefulWidget{
  final HitchesModel hitchRequest;
  const HitchRequestPendingWidget({super.key, required this.hitchRequest});

  @override
  State<HitchRequestPendingWidget> createState() => _HitchRequestPendingWidgetState();
}

class _HitchRequestPendingWidgetState extends State<HitchRequestPendingWidget> {
  final userAuthService = UserAuthService.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {

          // bool isFreeConnectsCompleted = contactedPlayersProvider.contactedPlayers.isNotEmpty;
          final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen:  false);

          // bool isFreeConnectsCompleted = contactedPlayersProvider.contactedPlayers.isNotEmpty;
          final isSubscribed = subscriptionProvider.getIsSubscribed;

          if (!isSubscribed) {
            int _hitcherCount = await HitchesService.getAllHitchesCount();
            if (_hitcherCount >= 3) {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>  const FilterSubscriptionPaywall()));
              return;
            }
          }

          HitchesService.onAcceptRejectHitchTap(
              context: context,
              hitchRequest: widget.hitchRequest, hitchStatus: hitchesStateAccepted);
        } ,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(color: AppColors.primaryColorVariant1, borderRadius: BorderRadius.circular(99),),
          child: const Text("Accept Hitch", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),),));
  }
}