/*
import 'package:flutter/material.dart';
import 'package:hitch/src/constants/string_constants.dart';
import 'package:hitch/src/models/hitches_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/providers/logged_in_user_provider.dart';
import 'package:provider/provider.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_colors.dart';
import '../../helpers/contact_players_helper.dart';
import '../../services/hitches_service.dart';
import '../../utils/utils.dart';
import '../../widgets/hitch_profile_image.dart';
import '../../widgets/hitch_request_sent_widget.dart';

class ViewProfile extends StatelessWidget{
  const ViewProfile({super.key, required this.hitchRequest, required this. onAcceptTap});
  final HitchesModel hitchRequest;
  final VoidCallback onAcceptTap;
  @override
  Widget build(BuildContext context) {
    UserModel player = hitchRequest.user;
    String hitchStatus = hitchRequest.hitchesStatus;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,

      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
          child: Container(
            // height: size.height*0.5,
            margin: const EdgeInsets.only(top: 10),
            child: Stack(
              children: [
                Card(
                  margin: const EdgeInsets.only(top: 75, bottom: 40 ),
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Container(
                    decoration:  BoxDecoration(
                      color: Colors.white,
                      // shape: BoxShape.circle,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.grey, spreadRadius: 1)],
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(top: 65),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xffBFBCBC)),

                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(player.userName, style: const TextStyle(fontSize: 24, color: primaryColor),),
                          const SizedBox(height: 10,),
                          _buildPlayerInfoRow(title: "Bio", value: player.bio),
                          const SizedBox(height: 20,),
                          player.playerTypeCoach ? _buildPlayerInfoRow(title: "Experience", value: '${player.experience.toString()} years') :
                          _buildPlayerInfoRow(title: "Age", value: player.age.toString()),
                          const SizedBox(height: 20,),
                          _buildPlayerInfoRow(title: "Level", value: player.level.toString()),
                          const SizedBox(height: 20,),

                          FutureBuilder(future: Utils.getCityName(player), builder: (ctx, snapshot){
                            if(snapshot.hasData){
                              return _buildPlayerInfoRow(title: "Location", value: snapshot.requireData);
                            }
                            return _buildPlayerInfoRow(title: "Location", value: '2 miles away');
                          }),

                          const SizedBox(height: 40,),
                          hitchStatus == hitchesStateRequestSent
                              ? const HitchRequestSentWidget()
                              : hitchStatus == hitchesStateAccepted
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if(player.cellNumber.isNotEmpty)
                                IconButton(onPressed: (){
                                  ContactPlayersHelper.onContactPlayerTap(player: player, context: context, contactViaEmail: false);
                                },
                                    icon: Image.asset(icMessage, height: 50,)),
                              const SizedBox(width: 10,),
                              IconButton(onPressed: (){
                                ContactPlayersHelper.onContactPlayerTap(player: player, context: context, contactViaEmail: true);
                              }, icon: Image.asset(icMail, height: 40,)),
                            ],
                          )
                              : Column(
                            children: [
                              SizedBox(
                                width: 150,
                                child: ElevatedButton(
                                            onPressed: () async{
                                             await HitchesService
                                                  .onAcceptRejectHitchTap(
                                                  hitchStatus:
                                                  hitchesStateAccepted,
                                                  hitchRequest: hitchRequest);
                                              _onPopup();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                ), child: const Text("Accept Hitch", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),),),
                              ),
                              const SizedBox(height: 10,),
                              SizedBox(
                                width: 150,
                                child: ElevatedButton(onPressed: ()async{
                                  context.read<LoggedInUserProvider>().updateDeclinedUsers(hitchRequest.user.userID);
                                  Navigator.of(context).pop();
                                  await HitchesService.onAcceptRejectHitchTap(hitchStatus: hitchesStateDeclined, hitchRequest: hitchRequest);

                                }, style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.black)
                                ), child: const Text("Decline", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),),),
                              )
                            ],
                          ),

                          const SizedBox(height: 20,),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 10,
                  child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey, spreadRadius: 2)],
                      ),
                      child: HitchProfileImage(profileUrl: player.profilePicture, size: 110.0,)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfoRow({required String title, required String value, }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(title, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: const TextStyle(fontSize: 16, color: greyTextColor, fontWeight: FontWeight.w400),)),
        const SizedBox(width: 40,),
        Expanded(
            flex: 2,
            child: Text(value, overflow: TextOverflow.ellipsis,  textAlign: TextAlign.start,maxLines: 3, style: const TextStyle(fontSize: 16,),))
      ],
    );
  }

  void _onPopup() {
    Navigator.of(context).pop();
  }
}*/
