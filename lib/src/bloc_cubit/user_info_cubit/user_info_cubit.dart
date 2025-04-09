import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hitch/src/models/coach_experience_model.dart';
import 'package:hitch/src/models/player_level_model.dart';
import 'package:hitch/src/models/uploaded_file_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../res/string_constants.dart';

part 'user_info_states.dart';

class UserInfoCubit extends Cubit<UserInfoStates>{
  final auth = FirebaseAuth.instance;

  final _userAuthService = UserAuthService.instance;
  UserInfoCubit() : super(InitialUserState());
  void onUpdateSignupInfoTap({required Map<String, dynamic> userMap, required bool isComingFromGoogle, required String cellNumber, String? experience, String? age, String? gender})async{
    try{
      emit(UpdatingUserInfo());
      PlayerLevelModel? pickleBallPlayerLevel = userMap[pickleBallPlayerLevelKey];
      PlayerLevelModel? tennisBallPlayerLevel = userMap[tennisBallPlayerLevelKey];
      CoachExperienceModel? coachPickleBallExperience = userMap[coachPickleBallExperienceLevelKey];
      CoachExperienceModel? coachTennisBallExperience = userMap[coachTennisExperienceLevelKey];


      UserModel user = UserModel(
        userID: userMap[userIDKey],
        emailAddress: userMap[emailAddressKey],
        userName: userMap[userNameKey],
        profilePicture: userMap[profileKey] ?? '',
        bio: userMap[bioKey],
        playerTypePickle: userMap[playerTypePickleKey],
        playerTypeTennis: userMap[playerTypeTennisKey],
        playerTypeCoach: userMap[playerTypeCoachKey],
          isConnectedToDupr: userMap['isConnectedToDupr'],
          myDuprID: userMap['myDuprID'],
          duprSingleRating: userMap['duprSingleRating'],
          duprDoubleRating: userMap['duprDoubleRating'],
        age: age,
        experience: experience,
        cellNumber: cellNumber,
        gender: gender,
        pickleBallPlayerLevel: pickleBallPlayerLevel,
        tennisBallPlayerLevel: tennisBallPlayerLevel,
        coachPickleBallExperienceLevel: coachPickleBallExperience,
        coachTennisBallExperienceLevel: coachTennisBallExperience,
        availableDaysToPlay: userMap[availableDaysToPlayKey] ?? [],
        isReviewed: userMap[isReviewedKey] ?? false
      );
      if(isComingFromGoogle){
        String profilePicture = user.profilePicture;
        if(user.profilePicture.isNotEmpty){
          profilePicture = (await _userAuthService.getProfileUrl(profilePicPath: user.profilePicture)) ??  '';
          user.setProfileUrl(profilePicture: profilePicture);
        }

        await _userAuthService.setUserInfo(user: user);
        emit(UpdatedUserInfo(userModel: user));
      }
      else{
        UserCredential? userCredential = await _userAuthService.signUp();
        if(userCredential != null){
          String userID = userCredential.user!.uid;
          String profilePicture = user.profilePicture;
          user.setUserID(userID: userID);

          if(user.profilePicture.isNotEmpty){
            profilePicture = (await _userAuthService.getProfileUrl(profilePicPath: user.profilePicture)) ??  '';
            user.setProfileUrl(profilePicture: profilePicture);
          }

          await _userAuthService.setUserInfo(user: user);
          emit(UpdatedUserInfo(userModel: user));
        }else{
          emit(UpdatingUserInfoFailed(errorMessage: 'Failed to create account'));
        }
      }

    }catch(e){
      debugPrint("Exception was: ${e.toString()}");
      emit(UpdatingUserInfoFailed(errorMessage: e.toString()));
    }
  }

  Future<void> onGoogleSignInTap() async {
    emit(GoogleSigningIn());
    try {
      // if it is web
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider(

        );
        try {
          await auth.signInWithPopup(authProvider);

          emit(GoogleSignedIn());
        } catch (e) {
          String errorMessage = e.toString();
          if(e is PlatformException){
            errorMessage = e.message ?? e.toString();
          }else if (e is FirebaseAuthException) {
            errorMessage = e.message ?? e.toString();
            debugPrint("error while google sign in: ${e.message}");
          }

          emit(SigningUpError(errorMessage: errorMessage));
        }
      } else {

        const List<String> scopes = <String>[
          'email',
        ];
        GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes,);
        final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
        if (googleSignInAccount != null) {
          final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );

          try {
            UserCredential? userCredential = await auth.signInWithCredential(credential);
            if (userCredential.additionalUserInfo!.isNewUser) {

              emit(GoogleSignedUp(user: userCredential));
            } else {
              UserModel? user = await _userAuthService.getCurrentUser();
              if(user != null){
                emit(GoogleSignedIn());
              }else{
                emit(GoogleSignedUp(user: userCredential));
              }
            }
          } on FirebaseAuthException catch (e) {
            debugPrint("Google sign in error: ${e.toString()}");
            debugPrint("error while google sign in: ${e.message}");
            String errorMessage = e.toString();
            if (e.code == 'account-exists-with-different-credential') {
              errorMessage = 'Account exists with different credentials';
              // ...
            } else if (e.code == 'invalid-credential') {
              errorMessage = 'Invalid Credentials!';
              // ...
            }

            emit(SigningUpError(errorMessage: errorMessage));
          } catch (e) {
            String errorMessage = e.toString();
            if(e is PlatformException){
              errorMessage = e.message ?? e.toString();
            }
            emit(SigningUpError(errorMessage: errorMessage));
          }

        }else{
          emit(SigningUpError(errorMessage: 'Signing up error'));
        }
      }
    } catch (e) {
      emit(SigningUpError(errorMessage: e.toString()));
    }
  }

  Future<void> onAppleSignInTap() async {
    emit(AppleSigningIn());

    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
          // Request the full name only on first sign-in.
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,

      );

      try {
        UserCredential userCredential = await auth.signInWithCredential(oauthCredential);
        debugPrint("Apple Credential: Given Name: ${appleCredential.givenName}, FamilyName: ${appleCredential.familyName}, Email: ${appleCredential.email}");
        String displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}';
        String userEmail = appleCredential.email ?? '';
        String userID = userCredential.user!.uid;

        if (userCredential.additionalUserInfo != null && userCredential.additionalUserInfo!.isNewUser) {
          // Check if it's a new user, as Apple won't return the name on subsequent sign-ins.

          displayName = displayName.trim();
          if(userEmail.isEmpty){
            userEmail = userCredential.user!.email ?? '';
          }
          if(displayName.isEmpty){
            displayName = userCredential.user!.displayName ?? '';
          }
          // Update Firebase display name
          if (displayName.isNotEmpty) {
            await userCredential.user?.updateDisplayName(displayName);
          }
          emit(AppleSignedUp(email: userEmail, userName: displayName, userID: userID));
        } else {
          debugPrint("User credential: $userCredential");
          // Returning user: use display name from Firebase
          //Checking if user exists in database too.
          UserModel? user = await _userAuthService.getCurrentUser();
          if(user != null){
            emit(AppleSignedIn());
          }else{
            displayName = displayName.trim();
            if(userEmail.isEmpty){
              userEmail = userCredential.user!.email ?? '';
            }
            if(displayName.isEmpty){
              displayName = userCredential.user!.displayName ?? '';
            }
            // Update Firebase display name
            if (displayName.isNotEmpty) {
              await userCredential.user?.updateDisplayName(displayName);
            }
            emit(UserNotFoundInDB(email: userEmail, userName: displayName, userID: userID));
          }
        }
      } on FirebaseAuthException catch (e) {
        debugPrint("Exception while apple sign in: ${e.toString()}");
        emit(SigningUpError(errorMessage: e.message!));
      } catch (e) {
        emit(SigningUpError(errorMessage: e.toString()));
      }
    } catch (e) {
      debugPrint("Exception while apple sign in: ${e.toString()}");
    }
  }

  Future<void> onUploadSportsInfoTap({
    required List<XFile> photosVideos,
    required bool isAvailableDaily,
    required List<String> availableDays,
    required String matchType,
    required String genderType,
    required bool isAvailableInMorning
  }) async {
    emit(UserSportsMediaUploading());
    try{
      List<UploadedFileModel> uploadedFiles = [];
      if(photosVideos.isNotEmpty){
        for (var photo in photosVideos) {
          String? url = await  _userAuthService.uploadFileToDatabase(photo);
          if(url != null){
            uploadedFiles.add(UploadedFileModel(fileName: photo.name, url: url,));
          }
        }
      }

      List<Map<String, dynamic>> uploadedFilesMap = uploadedFiles.map((uploadedFile)=> uploadedFile.toMap()).toList();
      Map<String, dynamic> updatedMap = {
        uploadedFilesKey : uploadedFilesMap,
        isAvailableDailyKey : isAvailableDaily,
        isAvailableInMorningKey : isAvailableInMorning,
        availableDaysToPlayKey : availableDays,
        matchTypeKey: matchType,
        genderTypeKey : genderType
      };
     await _userAuthService.updateUserInfo(updatedMap: updatedMap);
     emit(UserSportsMediaUploaded());
    }catch(e){
      String errorMessage = e.toString();
      if(e is PlatformException){
        errorMessage = e.message!;
      }
      emit(UserSportsMediaUploadingFailed(errorMessage: errorMessage));
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}