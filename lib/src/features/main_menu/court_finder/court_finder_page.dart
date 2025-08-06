// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitch/src/bloc_cubit/courts_cubit/courts_cubit.dart';
import 'package:hitch/src/features/paywalls/subscription_paywall.dart';
import 'package:hitch/src/features/user_profile/user_profile.dart';
import 'package:hitch/src/models/places_api_response_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/providers/subscription_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_icons.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/res/lottie_anims.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/court_finder_service.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitch/src/widgets/failed_to_locate_widget.dart';
import 'package:hitch/src/widgets/hitch_profile_image.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:hitch/src/widgets/lottie_anim_widget.dart';
import 'package:hitch/src/widgets/primary_btn.dart';
import 'package:provider/provider.dart';
import '../../../models/sponsored_club_model.dart';
import '../../../widgets/user_not_found.dart';
import '../../filter_page.dart';


class CourtFinderPage extends StatefulWidget{
  const CourtFinderPage({super.key});

  @override
  State<CourtFinderPage> createState() => _CourtFinderPageState();
}

class _CourtFinderPageState extends State<CourtFinderPage> {
  late CameraPosition _initialCameraPosition;
  GoogleMapController? mapController;
  bool isVisible  = true;
  List<Map<String,dynamic>> sponsoredClubs = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  bool loadingCourts = false;
  List<NearbyCourts> results = [];
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    context.read<CourtsCubit>().loadCourts();
    _initSponsoredClubs();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final _subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    if (!_subscriptionProvider.getIsSubscribed) {
      return const SubscriptionPaywall();
    }

    return BlocConsumer<CourtsCubit, CourtsStates>(
        listener: (ctx, state){
          if(state is LocationPermissionDeniedForever){
            Utils.showPermissionRequestDialog(context, locationPermissionDescription);
          }
        },
        builder: (ctx, state){
      if(state is UserNotFound){
        return const UserNotFoundWidget();
      }
      if(state is LoadingCourts){
        return const LoadingWidget();
      }
      if(state is LoadingCourtsFailed){
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LottieAnimWidget(anim: LottieAnims.mapsAnim, repeat: true,),
              const SizedBox(height: 10,),
              const Text("We failed to locate you.\nPlease check your connection and try again.", textAlign: TextAlign.center,),
              const SizedBox(height: 20,),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: PrimaryBtn(btnText: "Refresh", onTap: (){
                  context.read<CourtsCubit>().loadCourts();
                }),
              )
            ],
          ),
        );
      }
      else if(state is LocationPermissionDenied){
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppIcons.icLocationPin),
              const SizedBox(height: 10,),
              const Text("Location", style: AppTextStyles.headingTextStyle,),
              const SizedBox(height: 10,),
              const Text("Allow maps to access your location while you use the app?", textAlign: TextAlign.center, style: AppTextStyles.regularTextStyle,),
              const SizedBox(height: 20,),
              SizedBox(
                  width: size.width*0.7,
                  child: PrimaryBtn(btnText: "Allow ", onTap: ()=> context.read<CourtsCubit>().loadCourts))
            ],
          ),
        );
      }
      else if(state is LocationPermissionDeniedForever){
        return FailedToLocateUserWidget(onRefreshTap: ()=> context.read<CourtsCubit>().loadCourts(),);
      }
      else if(state is CurrentLocationCameraPosition){
        _initialCameraPosition = state.initialCameraPosition;
        // _initialCameraPosition = const CameraPosition(target: LatLng(30.396032, -88.885307,),);
        if(mapController != null){
          mapController!.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
        }

      }else if(state is LoadedCourts){
        results = state.courtsNearby;
      }else if(state is LoadedMarkersOfCourts){
        markers.addAll(state.markers);
      }

      return Stack(
        children: [
          Positioned.fill(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StreamBuilder(stream: FirebaseFirestore.instance.collection(userCollection).doc(FirebaseAuth.instance.currentUser!.uid).snapshots(), builder: (ctx, snapshot){
                            if(snapshot.hasData){
                              UserModel user = UserModel.fromMap(snapshot.data!.data()!);
                              return GestureDetector(
                                  onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> const UserProfile())),
                                  child: HitchProfileImage(profileUrl: user.profilePicture, size: 50));
                            }

                            return CircleAvatar(
                              backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                              radius: 25,
                            );
                          }),
                          const Text("Courts", style: AppTextStyles.pageHeadingStyle ),
                          const SizedBox(width: 20,),
                        ],
                      ),
                    ),

                    SizedBox(
                        height: size.height*0.3,
                        child: GoogleMap(
                            initialCameraPosition: _initialCameraPosition,
                            zoomGesturesEnabled: true,
                            onMapCreated: _onMapCreated,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            markers: markers
                        ))
                  ],
                )
            ),
          ),
          AnimatedPositioned(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              bottom: isVisible ? 0 : -400, // Adjust the target height here
              left: 0,
              right: 0,
              child: Card(
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                  child: SizedBox(
                    height: size.height*0.55,
                    child: loadingCourts
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor,),)
                        : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                      text: TextSpan(
                                          children: [
                                            const TextSpan(text: "We found: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.greyTextColor, fontFamily: 'Inter')),
                                            TextSpan(text: "${results.length} courts nearby", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryColor, fontFamily: 'Inter')),
                                          ]
                                      )),
                                ),
                                IconButton(onPressed: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> const FilterPage()));
                                  // setState(() => showNoPeopleFound = false);
                                },
                                    icon: SvgPicture.asset(AppIcons.icFilter, color: AppColors.greyTextColor, width: 30,),
                                )
                              ],
                            ),
                          ),
                          sponsoredClubs.isNotEmpty ? _buildListViewItems(results) : _buildOnlyNearbyCourts(results)

                          ],
                          ),
                        ),
                  )
              )
          ),
        ],
      );
    });
  }

  void _initSponsoredClubs() async{
    sponsoredClubs = await CourtFinderService.getSponsoredClubs();
    if(sponsoredClubs.isNotEmpty){
      BitmapDescriptor customIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(37, 37)),
        'assets/icons/ic_pickler_map_marker.png',
      );
      for (var clubMap in sponsoredClubs) {
        SponsoredClubModel club = clubMap[clubKey];
        double latitude = clubMap['latitude'];
        double longitude = clubMap['longitude'];

        markers.add(Marker(
          markerId: MarkerId(club.name),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: club.name,
            snippet: club.address,
          ),
          icon: customIcon,
          onTap: (){
            mapController?.showMarkerInfoWindow(MarkerId(club.name));
          }
        ));
      }

      setState(() {});
      debugPrint("Sponsored Clubs After: ${markers.length}");
    }
  }

  _buildListViewItems(List<NearbyCourts> results) {
    int courtIndex = 1;
    List<dynamic> combinedList = [...sponsoredClubs, ...results];
    return Expanded(child: ListView.builder(
        itemCount: combinedList.length,
        itemBuilder: (ctx, index){
      final item = combinedList[index];
      if(item is Map<String, dynamic>){
        SponsoredClubModel club = item[clubKey];
        double distance = item[distanceKey];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: ()async{
                    await Clipboard.setData(ClipboardData(text: club.address));
                    Utils.showCopyToastMessage();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(index == 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Image.asset(AppIcons.icPicklrLogo, height: 25,),
                        ),
                      GestureDetector(onTap: (){
                        Utils.launchAppUrl(url: club.affiliateLink);
                      }, child: const Text('Indoor Courts & Pro Shop', textAlign: TextAlign.start, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkGreyTextColor, decoration: TextDecoration.underline),),),
                      const SizedBox(height: 8,),
                      Text(club.address, style:  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.headingColor,),),
                      Text('${distance.toStringAsFixed(2)} miles', style:  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff929292),),),
                       Text('Sponsored', style:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[400]!,),),
                    ],
                  ),
                ),
              ),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: 'https://thepicklr.com/wp-content/uploads/2022/12/image-3-2-1024x557.png',
                ),
              ))
            ],
          ),
        );
      }else{
        return _buildNearbyCourtWidget(item as NearbyCourts, courtIndex++);
      }
    }));
  }

  Widget _buildNearbyCourtWidget(NearbyCourts court, int courtIndex){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text((courtIndex).toString(), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),),
          const SizedBox(width: 20,),
          Expanded(child: InkWell(
            onTap: ()async{
              await Clipboard.setData(ClipboardData(text: court.vicinity));
              Utils.showCopyToastMessage();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(court.vicinity, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
                Text('${court.distanceInMiles.toStringAsFixed(2)} miles away', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.greyColor),),
              ],),
          ),
          ),
          const SizedBox(width: 5,),
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox.fromSize(
              size: const Size.fromRadius(45), // Image radius
              child: court.photos != null ? Image.network(
                Utils.getCourtPhotoUrlFromReference(court.photos![0].photoReference),
                fit: BoxFit.cover,
              ) : Image.network(court.icon),
            ),
          ),),
        ],
      ),
    );
  }

  _buildOnlyNearbyCourts(List<NearbyCourts> results) {
    return Expanded(child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (ctx, index){
          return _buildNearbyCourtWidget(results[index], index+1);
    }));
  }
}



