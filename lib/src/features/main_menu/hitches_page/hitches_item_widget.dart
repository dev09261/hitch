// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hitch/src/models/hitches_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/services/hitches_service.dart';
import 'package:hitch/src/widgets/hitch_profile_image.dart';
import 'package:hitch/src/widgets/hitch_request_pending_widget.dart';
import 'package:hitch/src/widgets/hitch_request_sent_widget.dart';
import '../../../widgets/contact_type_sms_widget.dart';
import '../../user_profile/user_info_page.dart';

class HitchesItemWidget extends StatefulWidget{
  final HitchesModel hitchRequest;
  final bool isLastItem;
  const HitchesItemWidget({super.key, required this.hitchRequest, this.isLastItem = false});

  @override
  State<HitchesItemWidget> createState() => _HitchesItemWidgetState();
}

class _HitchesItemWidgetState extends State<HitchesItemWidget> with SingleTickerProviderStateMixin{
  late final controller = SlidableController(this);

  String get _getNameText {
    String name = widget.hitchRequest.user.userName;
    return name.split(" ").length > 1
        ? '${name.split(' ')[0]}\n${name.split(' ')[1]}'
        : name;
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = widget.hitchRequest.user;
    return Slidable(
        controller: controller,
        // Specify a key if the Slidable is dismissible.
        key: const ValueKey(0),
        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          extentRatio: 0.35,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_)=> _onRemoveChatTap(),
              label: 'REMOVE',
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            )
          ],
        ),

        // The child of the Slidable is what the user sees when the
        // component is not dragged.
        child: _buildHitchItemWidget(user)
    );
  }

  Column _buildHitchItemWidget(UserModel user) {
    return Column(
      children: [
         ListTile(
           onTap: (){
             Navigator.of(context).push(MaterialPageRoute(
                 builder: (ctx) => UserInfoPage(player: widget.hitchRequest.user, comingForHitchRequest: true, hitchID: widget.hitchRequest.hitchID,)));
           },
           contentPadding: const EdgeInsets.only(top: 5,bottom: 5, right: 10),
          leading: FutureBuilder(
              future: UserAuthService.instance
                  .getUserByID(userID: widget.hitchRequest.user.userID),
              builder: (ctx, snapshot){
                if(snapshot.hasData){
                  String imageUrl = snapshot.requireData != null ? snapshot.requireData!.profilePicture : user.profilePicture;
                  return SizedBox(
                    width: 100,
                    child: widget.hitchRequest.isRequestViewed
                        ? HitchProfileImage(
                        profileUrl: imageUrl, size: 50)
                        : Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, right: 8),
                          child: CircleAvatar(backgroundColor: AppColors.primaryColor, radius: 6,),
                        ),
                        HitchProfileImage(profileUrl: imageUrl, size: 50)
                      ],
                    ),
                  );
                }

                return SizedBox(
                  width: 100,
                  child: HitchProfileImage(profileUrl: user.profilePicture, size: 50),
                );
              }),
          title: Text(_getNameText, style: AppTextStyles.regularTextStyle.copyWith(color: Colors.black),),
           trailing: Container(
             width: 145,
             alignment: Alignment.centerRight,
             margin: const EdgeInsets.only(right: 0),
             decoration: BoxDecoration(
               color: widget.hitchRequest.hitchesStatus == hitchesStatePending
                   ? AppColors.primaryColor
                   : null,
               borderRadius: BorderRadius.circular(99),
             ),
             child: widget.hitchRequest.hitchesStatus == hitchesStateAccepted
                 ?  ContactTypeSmsWidget(player: widget.hitchRequest.user)
                 : widget.hitchRequest.hitchesStatus == hitchesStateRequestSent
                 ? const HitchRequestSentWidget()
                 : HitchRequestPendingWidget(hitchRequest: widget.hitchRequest,),
           ),
        ),
        Container(
          color: Colors.grey,
          height: 1,
        )
      ],
    );
  }

  void _onRemoveChatTap(){
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Please Confirm"),
          // content: const Text("Are you sure to delete the chat?"),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel", style: TextStyle(fontSize: 16, color: AppColors.greyTextColor),),
            ),
            CupertinoDialogAction(
              onPressed: () {
                // Handle delete action
                debugPrint("on delete tap");
                HitchesService.deleteHitchByID(widget.hitchRequest.hitchID, widget.hitchRequest.user.userID);
                Navigator.of(context).pop();
              },
              isDestructiveAction: true, // Makes text red
              child: const Text("Delete", style: TextStyle(fontSize: 16, color: AppColors.redColor),),
            ),
          ],
        );
      },
    );
  }
}