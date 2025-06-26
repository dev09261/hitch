import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/features/main_menu/hitches_page/hitch_request_widget.dart';
import 'package:hitch/src/models/hitches_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/services/hitches_service.dart';
import 'package:hitch/src/widgets/availability_switch.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:hitch/src/widgets/selected_videos_photos_gridview_widget.dart';
import 'package:hitch/src/widgets/sports_photos_videos_view_page.dart';
import '../../data/app_data.dart';
import '../../utils/utils.dart';
import '../../widgets/lets_play_button.dart';
import '../../widgets/match_gendertype_widget.dart';
import '../../widgets/selectable_available_days_widget.dart';

class UserInfoPage extends StatefulWidget{
  const UserInfoPage({super.key, required this.player, this.comingForHitchRequest = false, this.hitchID = ''});
  final UserModel player;
  final bool comingForHitchRequest;
  final String hitchID;

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {

  late List<Map<String, dynamic>> daysAvailable;
  late List<String> matchTypeList;
  late List<String> genderList;

  bool isReadyToContinue = false;

  // late UserModel player;
  late List<String> playerSportsPhotosVideos;
  @override
  void initState() {
    super.initState();
    daysAvailable = AppData.daysAvailable;
    matchTypeList = [
      'Both', 'Doubles', 'Singles'
    ];
    genderList = [
      'Both', 'Males', 'Females'
    ];

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder(
            future: UserAuthService.instance.getUserByID(userID: widget.player.userID),
            builder: (context, snapshot) {
              if(snapshot.hasData && snapshot.requireData != null){
                UserModel player = snapshot.requireData!;
                playerSportsPhotosVideos = player.uploadedSportsPhotos
                    .map((uploaded) => uploaded.url)
                    .toList();
                _updateDaysAvailable(player: player);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: AppBar(
                            leading: IconButton(onPressed: ()async{

                              Navigator.of(context).pop();
                            }, icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryColor,)),
                            title: player.profilePicture.isNotEmpty ? Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: CachedNetworkImageProvider(player.profilePicture),
                                ),
                                const SizedBox(width: 10,),
                                Expanded(child: Text(player.userName, maxLines: 2, style: AppTextStyles.pageHeadingStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w600))),
                              ],
                            ) : Text(player.userName, style: AppTextStyles.pageHeadingStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w600)),
                            centerTitle: true,
                            scrolledUnderElevation: 0,
                            backgroundColor:  Colors.white,
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            player.uploadedSportsPhotos.isNotEmpty
                                ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SelectedVideosPhotosGridviewWidget(
                                  selectedPhotosVideos: playerSportsPhotosVideos,
                                  onTap: (index) => _navigateToViewPhotosPage(index),
                                ),
                                const SizedBox(height: 20,),
                                if(widget.comingForHitchRequest)
                                  _buildUserInfoWidget(player: player),
                              ],
                            )
                                : _buildUserInfoWidget(player: player),

                            //Availability widget
                            const Padding(
                              padding:  EdgeInsets.only(top: 20.0),
                              child: Text('Availability', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headingColor),),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 20, bottom: 10),
                        child: AvailabilitySwitch(isAvailableDay: player.isAvailableDaily, onEveryDayChange: (val)=> null, onMorningChange: (val)=> null, isAvailableInMorning: player.isAvailableInMorning,),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(!player.isAvailableDaily)
                              SelectableAvailableDaysWidget(daysAvailable: daysAvailable, onTap: (index)=> null),
                            const SizedBox(height: 30,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MatchGendertypeWidget(selectedType: player.matchType, typeList: matchTypeList, onTap: (index)=> null, headingTitle: 'Match Type'),
                                const SizedBox(height: 30,),
                                MatchGendertypeWidget(selectedType: player.genderType, typeList: genderList, onTap: (index)=> null, headingTitle: 'Gender'),
                              ],
                            ),
                            const SizedBox(height: 30,),

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

                                // We have to display Let's Play button here
                                //Lets Play Button Here
                                return LetsPlayButton(player: player, comingFromUserPage: true,);
                              }),
                            ),
                            const SizedBox(height: 20,),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }else if(snapshot.hasError){
                return Center(child: Text("Couldn't get user information\n${snapshot.error.toString()}"),);
              }else if(snapshot.connectionState == ConnectionState.waiting){
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingWidget(),
                    SizedBox(height: 10,),
                    Text("Loading ...", style: AppTextStyles.regularTextStyle,)
                  ],
                );
              } else {
                return
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: AppBar(
                            leading: IconButton(onPressed: ()async{

                              Navigator.of(context).pop();
                            }, icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryColor,)),
                            scrolledUnderElevation: 0,
                            backgroundColor:  Colors.white,
                          )
                      ),
                      const Expanded(
                        child: Center(child: Text("This player's Hitch account no longer exists"),)
                      )
                    ],
                  );

              }
            }
        ),
      ),
    );
  }

  Widget _buildUserInfoWidget({required UserModel player}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlayerInfoRow(title: "Bio", value: player.bio),
        const SizedBox(
          height: 20,
        ),
        player.playerTypeCoach
            ? _buildPlayerInfoRow(
                title: "Experience",
                value: '${player.experience.toString()} years')
            : _buildPlayerInfoRow(title: "Age", value: player.age.toString()),
        const SizedBox(
          height: 20,
        ),
        _buildPlayerInfoRow(
            title: "Level", value: Utils.getPlayerLevelText(player)),
        const SizedBox(
          height: 20,
        ),
        FutureBuilder(
            future: Utils.getCityName(player),
            builder: (ctx, snapshot) {
              if (snapshot.hasData) {
                return _buildPlayerInfoRow(
                    title: "Location", value: snapshot.requireData);
              }
              return _buildPlayerInfoRow(
                  title: "Location", value: '2 miles away');
            }),
      ],
    );
  }

  Widget _buildPlayerInfoRow({required String title, required String value, }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(title, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start, style: const TextStyle(fontSize: 14, color: AppColors.greyColor, fontWeight: FontWeight.w400),)),
        const SizedBox(width: 40,),
        Expanded(
            flex: 4,
            child: Text(value.isEmpty ? '-' : value, overflow: TextOverflow.ellipsis,  textAlign: TextAlign.start, maxLines: 3, style: const TextStyle(fontSize: 14, color: AppColors.darkGreyTextColor),))
      ],
    );
  }

  void _updateDaysAvailable({required UserModel player}) {
    daysAvailable = daysAvailable.map((item) {
      if (player.availableDaysToPlay.contains(item['day'])) {
        item['isSelected'] = true;
      }
      return item;
    }).toList();
  }

  void _navigateToViewPhotosPage(int index) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) =>
            SportsPhotosVideosViewPage(
                uploadedFilesUrls:
                playerSportsPhotosVideos,
                selectedIndex: index)));
  }


}