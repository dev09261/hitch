import 'package:hitch/src/models/coach_experience_model.dart';
import 'package:hitch/src/models/uploaded_file_model.dart';

import '../res/string_constants.dart';
import 'player_level_model.dart';

class UserModel {
  String userID;
  String userName;
  String profilePicture;
  bool playerTypePickle;
  bool playerTypeTennis;
  bool playerTypeCoach;
  String level;
  String bio;
  String cellNumber;
  String emailAddress;
  String? age;
  String? experience;
  double distanceFromCurrentLocation;
  final String token;
  List<String> requestSentToUserIDs;
  List<String> requestReceivedFromUserIDs;
  String? gender;
  final bool isReviewed;

  List<String> declinedRequestsUserIDs;
  double? latitude;
  double? longitude;
  PlayerLevelModel? pickleBallPlayerLevel;
  PlayerLevelModel? tennisBallPlayerLevel;
  CoachExperienceModel? coachPickleBallExperienceLevel;
  CoachExperienceModel? coachTennisBallExperienceLevel;
  List<UploadedFileModel> uploadedSportsPhotos;
  bool isAvailableDaily;
  bool isAvailableInMorning;
  String matchType;
  String genderType;
  List<String> availableDaysToPlay;
  UserModel({
    required this.userID,
    required this.userName,
    required this.profilePicture,
    required this.playerTypePickle,
    required this.playerTypeTennis,
    required this.playerTypeCoach,
    this.level = '',
    required this.bio,
    required this.cellNumber,
    required this.emailAddress,
    this.latitude,
    this.longitude,
    this.gender,
    this.distanceFromCurrentLocation = 30,
    this.age,
    this.token = '',
    this.experience,
    this.requestReceivedFromUserIDs = const [],
    this.declinedRequestsUserIDs = const [],
    this.requestSentToUserIDs = const [],
    this.coachPickleBallExperienceLevel,
    this.coachTennisBallExperienceLevel,
    this.pickleBallPlayerLevel,
    this.tennisBallPlayerLevel,
    this.uploadedSportsPhotos = const [],
    this.isAvailableDaily = true,
    this.isAvailableInMorning = false,
    this.matchType = 'Both',
    this.genderType = 'Both',
    required this.availableDaysToPlay,
    this.isReviewed = false
  });

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'userName': userName,
      'profilePicture': profilePicture,
      'playerTypePickle': playerTypePickle,
      'playerTypeTennis': playerTypeTennis,
      'playerTypeCoach': playerTypeCoach,
      'level': level,
      'bio': bio,
      'cellNumber': cellNumber,
      'emailAddress': emailAddress,
      'age': age,
      'experience': experience,
      'token' : token,
      'distanceFromCurrentLocation': distanceFromCurrentLocation,
      'requestSentToUserIDs': requestSentToUserIDs,
      'requestReceivedFromUserIDs': requestReceivedFromUserIDs,
      'declinedRequestsUserIDs': requestReceivedFromUserIDs,
      // 'languages' : languages,
      'latitude': latitude,
      'longitude':longitude,
      'gender' :  gender,
      'coachPickleBallExperienceLevel': coachPickleBallExperienceLevel?.toMap(),
      'coachTennisBallExperienceLevel' : coachTennisBallExperienceLevel?.toMap(),
      'pickleBallPlayerLevel': pickleBallPlayerLevel?.toMap(),
      'tennisBallPlayerLevel' : tennisBallPlayerLevel?.toMap(),
      uploadedFilesKey : uploadedSportsPhotos.map((uploadedSportsPhotos)=> uploadedSportsPhotos.toMap()).toList(),
      isAvailableDailyKey: isAvailableDaily,
      isAvailableInMorningKey: isAvailableInMorning,
      matchTypeKey : matchType,
      genderTypeKey : genderType,
      availableDaysToPlayKey : availableDaysToPlay,
      isReviewedKey : isReviewed

    };
  }

  // Create a UserProfile object from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userID: map['userID'],
      userName: map['userName'],
      profilePicture: map['profilePicture'],
      playerTypePickle: map['playerTypePickle'] ?? true,
      playerTypeTennis: map['playerTypeTennis'] ?? true,
      playerTypeCoach: map['playerTypeCoach'] ?? false,
      level: map['level'],
      bio: map['bio'],
      cellNumber: map['cellNumber'],
      emailAddress: map['emailAddress'],
      age: map['age'],
      experience: map['experience'],
      token: map['token'] ?? '',
      distanceFromCurrentLocation: map['distanceFromCurrentLocation'],
      requestSentToUserIDs: List<String>.from(map['requestSentToUserIDs'] ?? []),
        declinedRequestsUserIDs: List<String>.from(map['declinedRequestsUserIDs'] ?? []),
      // languages: List<String>.from(map['languages'] ?? []),
      requestReceivedFromUserIDs: List<String>.from(map['requestReceivedFromUserIDs'] ?? []),
      latitude: map['latitude'],
      longitude: map['longitude'],
      gender: map['gender'],
        coachPickleBallExperienceLevel: map['coachPickleBallExperienceLevel'] !=
            null ? CoachExperienceModel.fromMap(
            map['coachPickleBallExperienceLevel']) : null,
      coachTennisBallExperienceLevel: map['coachTennisBallExperienceLevel'] != null ? CoachExperienceModel.fromMap(map['coachTennisBallExperienceLevel']) : null,
      pickleBallPlayerLevel: map['pickleBallPlayerLevel'] != null ? PlayerLevelModel.fromMap(map['pickleBallPlayerLevel']) : null,
      tennisBallPlayerLevel: map['tennisBallPlayerLevel'] != null ? PlayerLevelModel.fromMap(map['tennisBallPlayerLevel']) : null,
      uploadedSportsPhotos: (map['uploadedFiles'] as List<dynamic>? ?? [])
          .map((fileMap) => UploadedFileModel.fromMap(fileMap as Map<String, dynamic>))
          .toList(),
      isAvailableDaily: map[isAvailableDailyKey] ?? true,
      isAvailableInMorning: map[isAvailableInMorningKey] ?? false,
      matchType: map[matchTypeKey] ?? 'Both',
      genderType: map[genderTypeKey] ?? 'Both',
      isReviewed: map[isReviewedKey] ?? false,
      availableDaysToPlay: List<String>.from(map[availableDaysToPlayKey] ?? [],
      )
    );
  }

  void setUserID({required String userID}) {
    this.userID = userID;
  }

  void setProfileUrl({required String profilePicture}) {
    this.profilePicture = profilePicture;
  }
}
