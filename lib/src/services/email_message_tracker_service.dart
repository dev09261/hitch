import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hitch/src/models/email_message_tracker_model.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/logged_in_user_provider.dart';
import '../res/string_constants.dart';

class EmailMessageTrackerService {

  static void addToTracker(
      {required UserModel triggeredFor,
        required BuildContext context,
      }) {
    String trackID = DateTime.now().millisecond.toString();
    DateTime dateTime = DateTime.now();

    UserModel currentUser =  Provider.of<LoggedInUserProvider>(context,listen: false).getUser;
    EmailMessageTrackerModel emailMessageTrackerModel = EmailMessageTrackerModel(
        trackID: trackID,
        triggeredByUName: currentUser.userName,
        triggeredByUID: currentUser.userID,
        triggeredForUName: triggeredFor.userName,
        triggeredForUID: triggeredFor.userID,
        triggeredOn: dateTime,
        triggeredType: triggerTypeMessage);


    _addEmailMessageTracker(emailMessageTrackerModel: emailMessageTrackerModel);
  }
  static Future<void> _addEmailMessageTracker({required EmailMessageTrackerModel emailMessageTrackerModel})async{
    try{
      await FirebaseFirestore.instance
          .collection(chatClickTrackerCollection)
          .doc(emailMessageTrackerModel.trackID)
          .set(emailMessageTrackerModel.toMap());
    }catch(e){
      String errorMessage = e.toString();

      if(e is PlatformException){
        errorMessage = e.message!;
      }

      debugPrint("Error while adding emailMessage Tracker: $errorMessage");
    }
  }
}