// ignore_for_file: deprecated_member_use
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gif_view/gif_view.dart';
import 'package:hitch/src/features/paywalls/filter_subscription_paywall.dart';
import 'package:hitch/src/providers/logged_in_user_provider.dart';
import 'package:hitch/src/providers/subscription_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_icons.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/players_coaches_service.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import '../../../bloc_cubit/players_coaches_cubit/players_coaches_cubit.dart';
import '../../../models/user_model.dart';
import '../../../widgets/failed_to_locate_widget.dart';
import '../../filter_page.dart';
import 'player_item_widget/player_item_widget.dart';

class PlayersWidget extends StatefulWidget{
  const PlayersWidget({super.key});

  @override
  State<PlayersWidget> createState() => _PlayersWidgetState();
}

class _PlayersWidgetState extends State<PlayersWidget> {
  late PlayersCoachesCubit playersCoachesCubit;
  late UserModel currentUser;
  Position? currentPosition;

  late SubscriptionProvider subscriptionProvider;

  @override
  void initState() {
    super.initState();
    context.read<PlayersCoachesCubit>().checkLocPermission();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    playersCoachesCubit = BlocProvider.of<PlayersCoachesCubit>(context);
    currentUser = Provider.of<LoggedInUserProvider>(context).getUser;
    subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    return BlocConsumer<PlayersCoachesCubit, PlayersCoachesState>(
          listener: (ctx, state){
            if(state is LocationPermissionDeniedForever){
              Utils.showPermissionRequestDialog(context, locationPermissionDescription);
            }
          },
          builder: (context, state) {
            if(state is LocationPermissionDeniedForever){
                return FailedToLocateUserWidget(onRefreshTap: () => playersCoachesCubit.checkLocPermission());
              }
              return Stack(
                children: [
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: StreamBuilder(stream: PlayersCoachesService().getPlayers(user: currentUser,), builder: (ctx,snapshot){
                if(snapshot.hasData){
                  List<UserModel> players = snapshot.data!;
                  List<Map<String, dynamic>> playersMap = [];
                  if(currentUser.latitude != null){

                    for (var player in players) {
                      double startLatitude = currentUser.latitude!;
                      double startLongitude = currentUser.longitude!;
                      double endLatitude = player.latitude ?? 0;
                      double endLongitude = player.longitude ?? 0;
                      double distanceInMeters = Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
                      double distanceInMiles = Utils.getDistanceInMiles(distanceInMeters);
                      playersMap.add({
                        playerKey: player,
                        distanceKey: distanceInMiles,
                      });
                    }
                    playersMap.sort((a, b) => a[distanceKey].compareTo(b[distanceKey]));
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: playersMap.isEmpty  ?  RichText(
                                  text: const TextSpan(
                                      children: [
                                        TextSpan(text: "0 ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryColor, fontFamily: 'Inter')),
                                        TextSpan(text: "results", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.greyTextColor, fontFamily: 'Inter')),

                                      ]
                                  )) : RichText(
                                  text: TextSpan(
                                      children: [
                                        const TextSpan(text: "We found: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.greyTextColor, fontFamily: 'Inter')),
                                        TextSpan(text:"${playersMap.length} people nearby", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryColor, fontFamily: 'Inter')),
                                      ]
                                  )),
                            ),
                            const SizedBox(width: 10,),
                            IconButton(onPressed: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> const FilterPage())), icon: SvgPicture.asset(AppIcons.icFilter, color: AppColors.greyTextColor, width: 30,))
                          ],
                        ),
                      ),
                      playersMap.isEmpty
                          ? Expanded(child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 20,),
                            const Text("We currently don’t have \nany players nearby.\n\nTry adjusting your filter \nfor more results.", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: AppColors.greyTextColor),),
                            const SizedBox(height: 20,),
                            Image.asset(AppIcons.icNoPlayerFound),

                          ],
                        ),
                      ))
                          : Expanded(
                            child: CarouselSlider(
                            carouselController: playersCoachesCubit.carouselCtrl,
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
                              items: playersMap.map((player) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                    width: size.width*0.98,
                                    margin: const EdgeInsets.only( right: 10,), child: PlayerCoachItemWidget(playerMap: player,));

                            },
                            );
                              }).toList(),
                            ),
                          ),

                      if(!subscriptionProvider.getIsSubscribed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0,),
                          child: InkWell(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                      children: [
                                        TextSpan(
                                            text: "Hitch+: Expand your player network",
                                            style: TextStyle(
                                              decoration: TextDecoration.underline,
                                                fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkGreyTextColor, fontFamily: 'Inter')
                                        ),
                                      ]
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> const FilterSubscriptionPaywall()));
                            },
                          ),
                        ),

                    ],
                  );
                }
                else if(snapshot.hasError){
                  return Center(child: Text(snapshot.error.toString()),);
                }else if(snapshot.connectionState == ConnectionState.waiting){

                  return const LoadingWidget();
                }

                return const SizedBox();
              }),
                      ),
              BlocBuilder<PlayersCoachesCubit, PlayersCoachesState>(builder: (ctx, state){
              if(state is ShowLetsPlayAnim) {
                return Positioned(
                    right: 0,
                    left: 0,
                    bottom: 20,
                    child: GifView.asset(
                      AppIcons.bouncingBallAnim,
                      frameRate: 30, // default is 15 FPS
                    ));
              }

              return const SizedBox.shrink();
                      })
                    ],
                  );
            }
          );
  }
}
