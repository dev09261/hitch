import 'package:flutter/cupertino.dart';
import 'package:hitch/src/models/user_model.dart';

class LoggedInUserProvider extends ChangeNotifier{
  late UserModel _user;
  bool _isReviewed = false;
  UserModel get getUser => _user;
  bool get isReviewed => _isReviewed;


  void setIsReviewed({required bool isReviewed}){
    _isReviewed = isReviewed;
    notifyListeners();
  }
  void setLoggedInUserInfo(UserModel user){
    _user = user;
    notifyListeners();
  }

  void updateDeclinedUsers(String userID) {
    // Create a new instance of the UserModel with updated declinedRequestsUserIDs
    UserModel updatedUser = UserModel(
      userID: _user.userID,
      userName: _user.userName,
      profilePicture: _user.profilePicture,
      playerTypePickle: _user.playerTypePickle,
      playerTypeTennis: _user.playerTypeTennis,
      playerTypeCoach: _user.playerTypeCoach,
      level: _user.level,
      bio: _user.bio,
      cellNumber: _user.cellNumber,
      emailAddress: _user.emailAddress,
      distanceFromCurrentLocation: _user.distanceFromCurrentLocation,
      token: _user.token,
      requestSentToUserIDs: List.from(_user.requestSentToUserIDs), // Mutable copy
      requestReceivedFromUserIDs: List.from(_user.requestReceivedFromUserIDs), // Mutable copy
      declinedRequestsUserIDs: List.from(_user.declinedRequestsUserIDs)..add(userID), // Add during copy
      latitude: _user.latitude,
      longitude: _user.longitude,
      gender: _user.gender,
      pickleBallPlayerLevel: _user.pickleBallPlayerLevel,
      tennisBallPlayerLevel: _user.tennisBallPlayerLevel,
      coachPickleBallExperienceLevel: _user.coachPickleBallExperienceLevel,
      coachTennisBallExperienceLevel: _user.coachTennisBallExperienceLevel,
      uploadedSportsPhotos: _user.uploadedSportsPhotos,
      isAvailableDaily: _user.isAvailableDaily,
      isAvailableInMorning: _user.isAvailableInMorning,
      matchType: _user.matchType,
      genderType: _user.genderType,
      availableDaysToPlay: _user.availableDaysToPlay,
      isReviewed: _user.isReviewed
    );

    _user = updatedUser; // Update the state

    notifyListeners();
  }

  void updateUserGender(String gender){
    _user.gender = gender;
    notifyListeners();
  }
  void updateUserEmail(String email){
    _user.emailAddress = email;
    notifyListeners();
  }
}