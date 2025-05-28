import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitch/src/bloc_cubit/players_coaches_cubit/players_coaches_cubit.dart';
import 'package:hitch/src/models/hitches_model.dart';
import 'package:hitch/src/models/pending_hitches.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/providers/logged_in_user_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/services/auth_service.dart';

import '../../../notifications/notification_service.dart';
import '../../../res/string_constants.dart';
import '../../../services/hitches_service.dart';
import '../../../widgets/contact_type_sms_widget.dart';
import '../../../widgets/hitch_request_sent_widget.dart';
import '../../../widgets/primary_btn.dart';

class HitchRequestStatusWidget extends StatefulWidget{
  const HitchRequestStatusWidget({super.key, required this.hitchRequest,});
  final HitchesModel hitchRequest;

  @override
  State<HitchRequestStatusWidget> createState() => _HitchRequestStatusWidgetState();
}

class _HitchRequestStatusWidgetState extends State<HitchRequestStatusWidget> {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    UserModel player = widget.hitchRequest.user;
    String hitchStatus = widget.hitchRequest.hitchesStatus;
    return Center(
      child:
      hitchStatus == hitchesStateDeclined
          ? const SizedBox()
          : hitchStatus == hitchesStateRequestSent
          ? const HitchRequestSentWidget()
          : hitchStatus == hitchesStateAccepted
          ? ContactTypeSmsWidget(player: player, height: 42,)
          : hitchStatus == hitchesStatePending || hitchStatus == hitchStateRequestReceived
          ? Column(
        children: [
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () async{
                await HitchesService
                    .onAcceptRejectHitchTap(
                  context: context,
                    hitchStatus:
                    hitchesStateAccepted,
                    hitchRequest: widget.hitchRequest);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 10)
              ), child: const Text("Accept Hitch", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),),),
          ),
          const SizedBox(height: 10,),
          SizedBox(
            width: 150,
            child: ElevatedButton(onPressed: ()async{
              context.read<LoggedInUserProvider>().updateDeclinedUsers(widget.hitchRequest.user.userID);
              Navigator.of(context).pop();
              await HitchesService.onAcceptRejectHitchTap(
                  context: context,
                  hitchStatus: hitchesStateDeclined, hitchRequest: widget.hitchRequest);

            }, style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: Colors.black)
            ), child: const Text("Decline", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),),),
          )
        ],
      )
          : SizedBox(
          width: size.width*0.5,
          child: PrimaryBtn(btnText: "Let’s play", onTap: onLetsPlayTap)),
    );
  }

  void onLetsPlayTap()async{
    final playersCoachesCubit = BlocProvider.of<PlayersCoachesCubit>(context);
    playersCoachesCubit.onShowLetsPlayAnim();
    await Future.delayed(const Duration(seconds: 1));
    playersCoachesCubit.onHideLetsPlayAnim();

    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference docRef = FirebaseFirestore.instance
        .collection(userCollection)
        .doc(currentUID);
    UserModel player = widget.hitchRequest.user;
    UserModel? currentUser = await UserAuthService.instance.getCurrentUser();

    if(currentUser != null){
      List<String> requestSentToUserIDs = currentUser.requestSentToUserIDs;
      requestSentToUserIDs.add(player.userID);
      currentUser.requestSentToUserIDs = requestSentToUserIDs;
      await PendingHitchesModel(
        uid: '${currentUser.userID}${player.userID}',
        senderId: currentUser.userID,
        senderName: currentUser.userName,
        senderToken: currentUser.token,
        receiverId: player.userID,
        receiverName: player.userName,
        receiverToken: player.token,
      ).create();
      await docRef.set(currentUser.toMap());
      NotificationService.sendNotification(receiver: player,  sender: currentUser);
    }else{
      docRef.get().then((value) async {
        currentUser = UserModel.fromMap(value.data() as Map<String,dynamic>);
        List<String> requestSentToUserIDs = currentUser!.requestSentToUserIDs;
        requestSentToUserIDs.add(player.userID);
        currentUser!.requestSentToUserIDs = requestSentToUserIDs;

        await PendingHitchesModel(
          uid: '${currentUser!.userID}${player.userID}',
          senderId: currentUser!.userID,
          senderName: currentUser!.userName,
          senderToken: currentUser!.token,
          receiverId: player.userID,
          receiverName: player.userName,
          receiverToken: player.token,
        ).create();

        await docRef.set(currentUser!.toMap());

        NotificationService.sendNotification(receiver: player, sender: currentUser!);
      });
    }
  }
}