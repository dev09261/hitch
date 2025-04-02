import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hitch/src/notifications/notification_service.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/chat_service.dart';
import 'package:hitch/src/utils/utils.dart';
import '../email_sender.dart';
import '../models/hitches_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class HitchesService{
  static Stream<List<HitchesModel>> getUserHitchRequest(){
   return FirebaseFirestore.instance
        .collection(userCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(hitchesCollection)
       .snapshots()
       .map((snapshot)=> snapshot.docs.map((doc)=> HitchesModel.fromMap(doc.data())).toList());
  }

  static Future<void> addHitchToUser({required UserModel receiver, required UserModel sender}) async{

    final userColRef = FirebaseFirestore.instance.collection(userCollection);
    // Creating hitch to receiver as request received
    String hitchID = DateTime.now().millisecond.toString();

    //Earlier (In first versions of the app receiver Hitch Status was pending not received
    final dateTime = DateTime.now();
    HitchesModel hitchesReceiverModel = HitchesModel(
        user: sender, hitchesStatus: hitchStateRequestReceived, hitchID: hitchID,dateTime: dateTime);
    await FirebaseFirestore.instance.collection(userCollection)
        .doc(receiver.userID)
        .collection(hitchesCollection).doc(hitchID)
        .set(hitchesReceiverModel.toMap());

    HitchesModel hitchesSenderModel = HitchesModel(
        user: receiver,
        hitchesStatus: hitchesStateRequestSent,
        hitchID: hitchID,
      dateTime: dateTime
    );
    // Creating hitch to sender as request sent
    await userColRef
        .doc(sender.userID)
        .collection(hitchesCollection).doc(hitchID)
        .set(hitchesSenderModel.toMap());

    EmailSender.sendEmail(recipientEmail: receiver.emailAddress,);
    NotificationService.sendNotification(receiver: receiver,  sender: sender);

  }

  static Future<void> onAcceptRejectHitchTap({required HitchesModel hitchRequest, required String hitchStatus})async{
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    //Update both database sender and receiver
    await FirebaseFirestore.instance
        .collection(userCollection)
        .doc(currentUID)
        .collection(hitchesCollection)
        .doc(hitchRequest.hitchID)
        .update({hitchesStatusKey: hitchStatus});


    //if current user declines the request, the receiver will see that the request I sent was rejected
    String receiverHitchStatus =  hitchStatus == hitchesStateDeclined ?  hitchesStateRejected : hitchStatus;
    await FirebaseFirestore.instance
        .collection(userCollection)
        .doc(hitchRequest.user.userID)
        .collection(hitchesCollection)
        .doc(hitchRequest.hitchID)
        .update({hitchesStatusKey: receiverHitchStatus});


    if(hitchStatus == hitchesStateDeclined){
      try {
        await FirebaseFirestore.instance.collection(userCollection).doc(currentUID).update({
          'declinedRequestsUserIDs': FieldValue.arrayUnion([hitchRequest.user.userID]),
        });
        debugPrint('Value added to array successfully!');
      } catch (e) {
        debugPrint('Error adding value to array: $e');
      }
    }

    //If chatRoom already Existed it will return else it will create a new chat room and returns it
    ChatService.createGetChatRoomID(userID: hitchRequest.user.userID);

    EmailSender.sendEmail(recipientEmail: hitchRequest.user.emailAddress, isAccepted: hitchStatus == hitchesStateAccepted);
    UserModel? sender = await UserAuthService.instance.getCurrentUser();

    if(hitchStatus == hitchesStateAccepted){
      NotificationService.sendNotification(receiver: hitchRequest.user, sender: sender!, isAcceptHitch: true);
    }
  }

  static List<HitchesModel> sortHitches(List<HitchesModel> hitches){
    hitches.sort((a, b) {
      if (a.dateTime == null && b.dateTime == null) {
        return 0; // Both are null, keep their order
      } else if (a.dateTime == null) {
        return 1; // Place nulls at the end
      } else if (b.dateTime == null) {
        return -1; // Place nulls at the beginning
      } else {
        return b.dateTime!.compareTo(a.dateTime!); // Compare non-null dates
      }
    });

    return hitches;
  }

  static Future<HitchesModel?> getHitchRequestByID({required String hitchID})async{
    try{
      DocumentSnapshot docSnap = await FirebaseFirestore.instance
          .collection(userCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(hitchesCollection).doc(hitchID).get();
     final map = docSnap.data() as Map<String, dynamic>;
     return HitchesModel.fromMap(map);
    }catch(e){
      debugPrint("Exception while getting Hitch request byID: ${e.toString()}");
    }
    return null;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getPendingHitchesStream() {
    return FirebaseFirestore.instance
        .collection(userCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(hitchesCollection).where(hitchesStatusKey, isEqualTo: hitchesStatePending)
        .snapshots();
  }

  static Future<List<HitchesModel>> getAcceptedHitches() async{
    QuerySnapshot querySnapshot = await  FirebaseFirestore.instance
        .collection(userCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(hitchesCollection).where(hitchesStatusKey, isEqualTo: hitchesStateAccepted)
        .get();

    return querySnapshot.docs.map((doc)=> HitchesModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  static Future<List<String>> getAcceptedHitchesUserIds() async{
    QuerySnapshot querySnapshot = await  FirebaseFirestore.instance
        .collection(userCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(hitchesCollection).where(hitchesStatusKey, isEqualTo: hitchesStateAccepted)
        .get();

    return querySnapshot.docs.map((doc){

      final map = doc.data() as Map<String, dynamic>;
      return map['user']['userID'] as String;
    }).toList();
  }


  static Future<int> getPendingAndUnReadCount()async {
    int total = 0;

    try{
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection(userCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(hitchesCollection).where(hitchesStatusKey, isEqualTo: hitchesStatePending).get();
      total += query.size;
      // debugPrint("Total hitch request: ${query.size}");
     int totalUnread = await ChatService.getTotalUnreadMessagesCount();
      // debugPrint("Total unRead messages: $totalUnread");
     total += totalUnread;

      int totalUnreadGroup = await ChatService.getTotalUnreadGroupMessagesCount();
      // debugPrint("Total Group unRead messages: $totalUnreadGroup");
      total += totalUnreadGroup;
    }catch(e){
      debugPrint("Exception: ${e.toString()}");
    }

    return total;
  }

  static Stream<int> getPlayerHitchCount(String userID) {
    return FirebaseFirestore.instance
        .collection(userCollection)
        .doc(userID)
        .collection(hitchesCollection)
        .where(hitchesStatusKey, isEqualTo: hitchesStateAccepted)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  static Future<void> deleteHitchByID(String hitchID, String userID) async{
    debugPrint("In Delete Hitch");
    String currentUID = FirebaseAuth.instance.currentUser!.uid;

    try{
      DocumentReference docRef = FirebaseFirestore.instance
          .collection(userCollection)
          .doc(currentUID)
          .collection(hitchesCollection).doc(hitchID);
      DocumentSnapshot docSnap = await docRef.get();
      if(docSnap.exists){
        debugPrint("Current User Doc found");
        await docSnap.reference.delete();
        Utils.showCopyToastMessage(message: "Hitch removed successfully");
      }else{
        debugPrint("Current User Doc Not found");

      }

      DocumentReference remoteUserDocRef = FirebaseFirestore.instance
          .collection(userCollection)
          .doc(userID)
          .collection(hitchesCollection).doc(hitchID);
      DocumentSnapshot remoteDocRef = await remoteUserDocRef.get();
      if(remoteDocRef.exists){
        debugPrint("Remote User Doc found");
        await remoteDocRef.reference.delete();
      }else{
        debugPrint("Remote User Doc Not found");
      }
    }catch(e){
      debugPrint("Error while deleting from Current user: ${e.toString()}");
    }

  }
}