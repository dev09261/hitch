import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/models/event_model.dart';
import 'package:hitch/src/models/event_request_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/notifications/notification_service.dart';
import 'package:hitch/src/services/auth_service.dart';

class EventProvider with ChangeNotifier {
  List<EventRequestModel> eventRequests = [];
  static final _eventRequestsRef = FirebaseFirestore.instance.collection('joinEventRequests');

  initMyEventRequest() {
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    _eventRequestsRef
    .where('requestUserId', isEqualTo: currentUID)
        .where('eventDate',
        isGreaterThan: DateTime.now()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch)
        .snapshots().listen(
            (snapshot) {
          if (snapshot.docs.isEmpty) {
            eventRequests = [];
            notifyListeners();
          } else {
            eventRequests = [];
            for (var item in snapshot.docs) {
              eventRequests.add(
                  EventRequestModel.fromMap(item.data())
              );
            }
            notifyListeners();
          }
        }
    );
  }

  sendRequest(EventModel event) async {
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    final authService = UserAuthService.instance;

    UserModel? currentUser = await authService.getCurrentUser();

    if (currentUser == null) {
      return;
    }

    await _eventRequestsRef.add(
      EventRequestModel(
          eventID: event.eventID,
          createdAt: event.createdAt,
          eventDate: event.eventDate.millisecondsSinceEpoch,
          createdByUserID: event.createdByUserID,
          requestUserId: currentUID,
          requestUserName: currentUser.userName,
          requestUserImageUrl: currentUser.profilePicture,
          status: 'Pending').toMap()
    );

    UserModel? creator = await authService.getUserByID(userID: event.createdByUserID);
    if (creator != null) {
      NotificationService.sendRequestNotification(receiver: creator,  sender: currentUser, title: event.title);
    }
  }

  Future<int> getTotalMyEventRequestCount() async {
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    try {
      return (await _eventRequestsRef.where('requestUserId', isEqualTo: currentUID).count().get()).count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}