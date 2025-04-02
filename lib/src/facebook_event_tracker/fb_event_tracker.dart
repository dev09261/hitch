import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/cupertino.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class FbEventTracker{
  static late FacebookAppEvents _facebookSDK;

  static void initFbEventTracker()async{
    _facebookSDK = FacebookAppEvents();

   /* try{
      await  _facebookSDK.logEvent(name: "Test Event");
      debugPrint("Facebook Test event logged");
    }catch(e){
      debugPrint("Failed to log test App event: ${e.toString()}");
    }*/
  }

  static void logPurchaseEvent() async{
    UserModel? user = await UserAuthService.instance.getCurrentUser();
    Map<String, String> params = {
      'userName': user!.userName,
      'userID' : user.userID,
      'email' : user.emailAddress
    };
    try{
      await _facebookSDK.logPurchase(amount: 9, currency: 'USD', parameters: params);
      debugPrint("Facebook Purchase Event logged");
    }catch(e){
      debugPrint("Facebook Purchase event logged failed: ${e.toString()}");
    }


  }
}
