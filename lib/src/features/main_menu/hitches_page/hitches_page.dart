import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hitch/src/bloc_cubit/hitches_cubit/hitches_cubit.dart';
import 'package:hitch/src/features/main_menu/hitches_page/empty_hitches_page.dart';
import 'package:hitch/src/features/main_menu/hitches_page/hitches_item_widget.dart';
import 'package:hitch/src/models/hitches_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/providers/logged_in_user_provider.dart';
import 'package:hitch/src/providers/subscription_provider.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/hitches_service.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:hitch/src/widgets/ad_banner_video.dart';
import 'package:hitch/src/widgets/failed_to_locate_widget.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:hitch/src/widgets/user_not_found.dart';
import 'package:provider/provider.dart';

import '../../../helpers/ad_helper.dart';

class HitchesPage extends StatefulWidget{
  const HitchesPage({super.key});

  @override
  State<HitchesPage> createState() => _HitchesPageState();
}

class _HitchesPageState extends State<HitchesPage> {
  late UserModel currentUser;
  bool loadingUser = true;
  bool userNotFound = false;
  late HitchesCubit hitchesCubit;
  List<HitchesModel> hitchRequests = [];
  BannerAd? _bannerAd;
  bool isCananda = false;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    _loadBannerAd();
  }
  @override
  void dispose() {
    updateViewedRequest();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    hitchesCubit = BlocProvider.of<HitchesCubit>(context);
    final bool isSubscribed = Provider.of<SubscriptionProvider>(context).getIsSubscribed;

    return
      loadingUser
        ? const LoadingWidget()
        : userNotFound
        ? const UserNotFoundWidget()
        : BlocConsumer<HitchesCubit, HitchesState>(
          listener: (ctx, state){
            if(state is HitchesLocationPermissionDeniedForever){
              Utils.showPermissionRequestDialog(context, locationPermissionDescription);
            }
          },
          builder: (context, state) {
            if(state is HitchesLocationPermissionDeniedForever){
              return FailedToLocateUserWidget(onRefreshTap: () => hitchesCubit.checkLocPermission());
            }
            return Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(children: [
                if (isCananda)
                  Padding(padding: const EdgeInsets.only(bottom: 20.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: AdBannerVideo(user: currentUser,)
                    ),
                  ),

                if (_bannerAd != null && !isSubscribed && !isCananda)
                  Padding(padding: const EdgeInsets.only(bottom: 20.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  ),
                StreamBuilder(
                    stream: HitchesService.getUserHitchRequest(),
                    builder: (ctx, snapshot) {
                      if(snapshot.hasData){

                        hitchRequests = snapshot.requireData;
                        hitchRequests = HitchesService.sortHitches(hitchRequests);
                        hitchRequests.removeWhere((request)=> request.hitchesStatus == hitchesStateDeclined);
                        if(hitchRequests.isEmpty){
                          return const EmptyHitchesPage();
                        }else{
                          return Expanded(
                            child: ListView.builder(
                                itemCount: hitchRequests.length,
                                itemBuilder: (ctx, index){
                                  return HitchesItemWidget(
                                    hitchRequest: hitchRequests[index],
                                    isLastItem: index == hitchRequests.length-1,
                                  );
                                }),
                          );
                        }
                      }
                      return const SizedBox();
                    }),
              ],
              ),
            );
          }
      );
  }


  void _initUser() async{
    context.read<HitchesCubit>().checkLocPermission();
    currentUser = context.read<LoggedInUserProvider>().getUser;

    List<Placemark> placemarks = await placemarkFromCoordinates(currentUser.latitude!, currentUser.longitude!);
    if (placemarks.first.country == 'Canada') {
      isCananda = true;
    }

    setState(() {
      loadingUser = false;
    });
  }

  void _loadBannerAd(){
    // TODO: Load a banner ad
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  void updateViewedRequest()async{
     String currentUID = FirebaseAuth.instance.currentUser!.uid;
     for (var request in hitchRequests) {
       await FirebaseFirestore.instance
           .collection(userCollection)
           .doc(currentUID)
           .collection(hitchesCollection)
           .doc(request.hitchID)
           .update({'isRequestViewed': true});
     }
  }
}

