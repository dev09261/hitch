// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hitch/src/bloc_cubit/players_coaches_cubit/players_coaches_cubit.dart';
import 'package:hitch/src/features/filter_page.dart';
import 'package:hitch/src/features/paywalls/subscription_paywall.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/providers/subscription_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_icons.dart';
import 'package:provider/provider.dart';
import '../../../notifications/notification_service.dart';
import '../../../res/string_constants.dart';
import '../../../services/players_coaches_service.dart';
import '../../../utils/utils.dart';
import '../../../widgets/loading_widget.dart';
import 'player_item_widget/player_item_widget.dart';

class CoachesWidget extends StatefulWidget{
  const CoachesWidget({super.key});

  @override
  State<CoachesWidget> createState() => _CoachesWidgetState();
}

class _CoachesWidgetState extends State<CoachesWidget> {
  bool showNoPeopleFound = false;
  late StreamSubscription<DocumentSnapshot> _subscription;
  late PlayersCoachesCubit playersCoachesCubit;

  UserModel? currentUser;
  @override
  void initState() {
    super.initState();
    _initCurrentUser();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    playersCoachesCubit = BlocProvider.of<PlayersCoachesCubit>(context);
    bool isSubscribed = Provider.of<SubscriptionProvider>(context).getIsSubscribed;
    debugPrint("isSubscribed: $isSubscribed");
    return Stack(
      children: [
        StreamBuilder(stream: PlayersCoachesService().getCoaches(), builder: (ctx,snapshot){
          if(snapshot.hasData){
            List<UserModel> coaches = snapshot.data!;

            List<Map<String, dynamic>> coachesMap = [];
            if(currentUser != null && currentUser!.latitude != null){
              for (var coach in coaches) {
                double startLatitude = currentUser!.latitude!;
                double startLongitude = currentUser!.longitude!;
                double endLatitude = coach.latitude!;
                double endLongitude = coach.longitude!;
                double distanceInMeters = Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
                double distanceInMiles = Utils.getDistanceInMiles(distanceInMeters);

                if(distanceInMiles <= currentUser!.distanceFromCurrentLocation){
                  coachesMap.add({
                    playerKey: coach,
                    distanceKey: distanceInMiles,
                  });
                }

              }
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: coachesMap.isEmpty  ?  RichText(
                            text: const TextSpan(
                                children: [
                                  TextSpan(text: "0 ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryColor, fontFamily: 'Inter')),
                                  TextSpan(text: "results", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.greyTextColor, fontFamily: 'Inter')),

                                ]
                            )) : RichText(
                            text: TextSpan(
                                children: [
                                  const TextSpan(text: "We found: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.greyTextColor, fontFamily: 'Inter')),
                                  TextSpan(text:"${coachesMap.length} coaches nearby", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryColor, fontFamily: 'Inter')),
                                ]
                            )),
                      ),
                      const SizedBox(width: 10,),
                      IconButton(onPressed: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> const FilterPage())), icon: SvgPicture.asset(AppIcons.icFilter, color: AppColors.greyTextColor, width: 30,))
                    ],
                  ),
                ),
                Expanded(
                    child: isSubscribed
                        ? _buildCoachesWidget(coachesMap: coachesMap, size: size)
                        :  const SubscriptionPaywall(),
                ),
              ],
            );
          }
          return const LoadingWidget();
        }),
        BlocBuilder<PlayersCoachesCubit, PlayersCoachesState>(builder: (ctx, state){
          if(state is ShowLetsPlayAnim) {
            return Positioned(
                  right: 0,
                  left: 0,
                  bottom: 20,
                  child: Image.asset(AppIcons.bouncingBallAnim));
          }

          return const SizedBox.shrink();
        })

      ],
    );
  }

  void _initCurrentUser() async{
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    _subscription = FirebaseFirestore.instance
        .collection(userCollection)
        .doc(currentUID)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      currentUser = UserModel.fromMap(snapshot.data() as Map<String,dynamic>);
    },
      onError: (error) {},
    );
  }

  void onLetsPlayTap(UserModel player)async{
    playersCoachesCubit.onShowLetsPlayAnim();
    await Future.delayed(const Duration(seconds: 1));
    playersCoachesCubit.onHideLetsPlayAnim();

    DocumentReference docRef = FirebaseFirestore.instance
        .collection(userCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid);
    if(currentUser != null){
      List<String> requestSentToUserIDs = currentUser!.requestSentToUserIDs;
      requestSentToUserIDs.add(player.userID);
      currentUser!.requestSentToUserIDs = requestSentToUserIDs;
      await docRef.set(currentUser!.toMap());
      NotificationService.sendNotification(receiver: player,  sender: currentUser!);
    }else{
      docRef.get().then((value) async {
        currentUser = UserModel.fromMap(value.data() as Map<String,dynamic>);
        List<String> requestSentToUserIDs = currentUser!.requestSentToUserIDs;
        requestSentToUserIDs.add(player.userID);
        currentUser!.requestSentToUserIDs = requestSentToUserIDs;
        await docRef.set(currentUser!.toMap());

        NotificationService.sendNotification(receiver: player, sender: currentUser!);
      });
    }
  }

  Widget _buildCoachesWidget({required  List<Map<String, dynamic>> coachesMap, required Size size}){
    return coachesMap.isEmpty
        ? Center(
      child: Column(
        children: [
          const SizedBox(height: 20,),
          const Text("We currently don’t have \nany coaches nearby.\n\nTry adjusting your filter \nfor more results.", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: AppColors.greyTextColor),),
          const SizedBox(height: 20,),
          Image.asset(AppIcons.icNoPlayerFound),

        ],
      ),
    )
        : CarouselSlider(
      options: CarouselOptions(
        height: size.height*0.7,
        aspectRatio: 16/9,
        viewportFraction: 0.85,
        initialPage: 0,
        enableInfiniteScroll: false,
        reverse: false,
        autoPlay: false,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.3,
        scrollDirection: Axis.horizontal,
      ),
      items: coachesMap.map((player) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
                width: size.width*0.98,
                margin: const EdgeInsets.only( right: 10,), child: PlayerCoachItemWidget(playerMap: player, comingFromCoach: true,));

          },
        );
      }).toList(),
    );
  }
}

