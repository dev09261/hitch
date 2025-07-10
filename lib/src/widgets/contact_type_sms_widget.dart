import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hitch/src/features/chats/chat_messages_page.dart';
import 'package:hitch/src/models/chat_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/providers/logged_in_user_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/services/chat_service.dart';
import 'package:hitch/src/services/email_message_tracker_service.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import '../res/app_icons.dart';
import '../res/app_text_styles.dart';
import '../res/string_constants.dart';

class ContactTypeSmsWidget extends StatefulWidget{
  final UserModel player;
  final double height;
  const ContactTypeSmsWidget({super.key, required this.player, this.height = 40});

  @override
  State<ContactTypeSmsWidget> createState() => _ContactTypeSmsWidgetState();
}

class _ContactTypeSmsWidgetState extends State<ContactTypeSmsWidget> {
  bool _checkingIfChatExists = false;
  ChatModel? chat;
  @override
  void initState() {
    _checkIfChatExists();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _onChatTap,
        child: _checkingIfChatExists
            ? const  LoadingWidget(isMoreLoading: true,)
            : chat != null
            ? StreamBuilder(
            stream: ChatService.getUnReadMessagesCount(
                roomID: chat!.roomID),
            builder: (_, snapshot) {
              return SizedBox(
                width: 60,
                height: 55,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    _buildMessageItemWidget(),
                    if (snapshot.hasData && snapshot.requireData > 0)
                      const Positioned(
                        top: 3,
                        left: 10,
                        child: CircleAvatar(
                          backgroundColor: AppColors.primaryColor,
                          radius: 8,
                        ),
                      )
                  ],
                ),
              );
            })
            : SizedBox(
            width: 60,
            height: 55,
            child: _buildMessageItemWidget()));
  }

  Column _buildMessageItemWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
                children: [
              Image.asset(
                AppIcons.icMessage,
                height: 30,
              ),
              const Text(
                "Chat",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textFieldFillColor),
              ),
                ],
    );
  }

  Future<void> _checkIfChatExists() async {
    setState(()=> _checkingIfChatExists = true);
    chat = await ChatService.createGetChatRoomID(userID: widget.player.userID);
    setState(()=> _checkingIfChatExists = false);
  }



  void _onChatTap() async{
    final userProvider = Provider.of<LoggedInUserProvider>(context, listen: false);

    if(!userProvider.isReviewed){
      await showRatingDialog();
    }

    if(chat != null){
      _navigateToChatTap(chat!);
    }else {
      setState(() => _checkingIfChatExists = true);
      ChatModel? chat = await ChatService.createGetChatRoomID(userID: widget.player.userID);
      setState(() => _checkingIfChatExists = false);
      if (chat != null) {
        _navigateToChatTap(chat);
      }
    }

    _addToTracker();
  }

  Future<void> showRatingDialog() async{
    double userRating = 0;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, innerState) {

              return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  // insetPadding: EdgeInsets.symmetric(horizontal: 20),
                  backgroundColor: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset('assets/icons/ic_logo.png'))
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Enjoying Hitch -\nPlayer Finder?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                                "Tap a star to rate it on the\nApp Store.",
                                textAlign: TextAlign.center,
                                style: AppTextStyles.regularTextStyle
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      RatingBar.builder(
                        glow: false,
                        initialRating: 0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        // itemSize: 25,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, index) => const Icon(
                          Icons.star_border_rounded,
                          color: Colors.blue,
                        ),
                        onRatingUpdate: (rating) {
                          innerState(()=> userRating = rating);
                        },
                      ),
                      const Divider(),
                      IntrinsicHeight(
                        child: Row(

                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "Not Now",
                                  style: TextStyle(color: Colors.blue, fontSize: 16),
                                ),
                              ),
                            ),
                            if(userRating > 0)
                              Expanded(
                                child: Row(
                                  children: [
                                    const VerticalDivider(),
                                    Expanded(
                                      child: TextButton(
                                        onPressed: (){
                                          LaunchReview.launch(
                                              androidAppId: 'com.willparton.hitch',
                                              iOSAppId: '6670320911'
                                          );
                                          _updateUserAddToReview();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          "Submit",
                                          style: TextStyle(color: Colors.blue, fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                          ],
                        ),
                      )
                    ],
                  )
              );
            }
        );
      },
    );
  }

  void _updateUserAddToReview() async{
    Provider.of<LoggedInUserProvider>(context, listen: false).setIsReviewed(isReviewed: true);
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection(userCollection).doc(currentUID).update({isReviewedKey : true});
  }

  void _navigateToChatTap(ChatModel chat){
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ChatMessagesPage(chat: chat)));
  }

  void _addToTracker() {
    EmailMessageTrackerService.addToTracker(triggeredFor: widget.player, context: context);
  }
}