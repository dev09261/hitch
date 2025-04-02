import 'package:flutter/cupertino.dart';

class HitchesProvider extends ChangeNotifier{
  List<String> _acceptedHitchUsersIDs = [];

  List<String> get acceptedHitchUserIds => _acceptedHitchUsersIDs;


  void setAcceptedHitches(List<String> userIDs){
    _acceptedHitchUsersIDs.addAll(userIDs);
    notifyListeners();
  }

  void addUserToHitch(String userID){
    if(!_acceptedHitchUsersIDs.contains(userID)){
      _acceptedHitchUsersIDs.add(userID);
      notifyListeners();
    }
  }
}