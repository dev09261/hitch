import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:image_picker/image_picker.dart';

class UserAuthService {
  UserAuthService._();

  static final UserAuthService instance = UserAuthService._();

  final _auth = FirebaseAuth.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _storageInstance = FirebaseStorage.instance;
  final _userCollection = FirebaseFirestore.instance.collection(userCollection);

  Future<UserCredential?> signUp() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  Future<String?> getProfileUrl({required String profilePicPath})async{
    File imageFile = File(profilePicPath);
    String? profileUrl;
    try{
      TaskSnapshot snapshot = await _storageInstance.ref('profilePictures/$profilePicPath').putFile(imageFile);
      profileUrl = await snapshot.ref.getDownloadURL();
    }catch(e){
      debugPrint("Exception found: ${e.toString()}");
    }
   return profileUrl;
  }

  Future<void> setUserInfo({required UserModel user})async {
   await _userCollection.doc(user.userID).set(user.toMap());
   updateDeviceToken();
  }

  Future<void> updateDeviceToken()async{
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    _firebaseMessaging.getToken().then((token) async {
     await _userCollection.doc(currentUID).update({"token" : token});
    });
  }

  Future<void> updateUserInfo({required Map<String, dynamic> updatedMap}) async{
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    await _userCollection.doc(currentUID).update(updatedMap);
  }

  Future<UserModel?> getCurrentUser()async{
    try{
      String currentUID = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot documentSnapshot = await _userCollection
          .doc(currentUID)
          .get()
          .timeout(const Duration(seconds: 20));
      if(documentSnapshot.data() != null){
        UserModel currentUser = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
        return currentUser;
      }
    }catch(e){
      debugPrint("Exception while getting user: ${e.toString()}");
    }

    return null;
  }

  Future<UserModel?> getUserByID({required String userID})async{
    try{
      DocumentSnapshot documentSnapshot = await _userCollection
          .doc(userID)
          .get()
          .timeout(const Duration(seconds: 20));
      if(documentSnapshot.data() != null){
        UserModel user = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
        return user;
      }
    }catch(e){
      debugPrint("Exception while getting user: ${e.toString()}");
    }

    return null;
  }

  Future<String?> uploadFileToDatabase(XFile file)async{
    try{
      final firebaseStorageRef = FirebaseStorage.instance.ref();

      TaskSnapshot uploadTask = await firebaseStorageRef.child(file.name).putFile(File(file.path));
      String downloadUrl =  await uploadTask.ref.getDownloadURL();
      debugPrint("File ${file.name} and URL: $downloadUrl");
      return downloadUrl;
    }catch(e){
      debugPrint("Failed to upload sport file: ${e.toString()}");
    }
    return null;
  }

  Stream<UserModel> get currentUserStream {
    return FirebaseFirestore.instance
        .collection(userCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => UserModel.fromMap(snapshot.data()!));
  }
}