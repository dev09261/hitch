import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/models/event_model.dart';
import 'package:hitch/src/models/event_request_model.dart';
import 'package:hitch/src/res/string_constants.dart';

class PostProvider with ChangeNotifier {
  List<EventRequestModel> eventRequests = [];
  List<EventModel> activeEvents = [];
  static final _eventRequestsRef =
      FirebaseFirestore.instance.collection('joinEventRequests');
  static final _eventsRef =
      FirebaseFirestore.instance.collection(eventsCollection);
  bool loading = false;

  initPendingRequests() {
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    _eventRequestsRef
        .where('createdByUserID', isEqualTo: currentUID)
        .where('status', isEqualTo: 'Pending')
        .where('eventDate',
        isGreaterThan: DateTime.now()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        eventRequests = [];
        notifyListeners();
      } else {
        eventRequests = [];
        for (var item in snapshot.docs) {
          eventRequests.add(EventRequestModel.fromMap(item.data()));
        }
        notifyListeners();
      }
    });
  }

  getActiveEvents() {
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    activeEvents = [];
    loading = true;
    notifyListeners();
    _eventsRef
        .where('createdByUserID', isEqualTo: currentUID)
        .where('eventDate',
        isGreaterThan: DateTime.now()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (var item in snapshot.docs) {
          activeEvents.add(EventModel.fromMap(item.data()));
        }
      }
      activeEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      loading = false;
      notifyListeners();
    });
  }

  Future<List<EventRequestModel>> getRequestsForEvent(String eventId) async {
    List<EventRequestModel> eventRequests = [];
    var requestDocs = await _eventRequestsRef.where('eventID', isEqualTo: eventId).get();
    if (requestDocs.docs.isNotEmpty) {
      for (var item in requestDocs.docs) {
        EventRequestModel req = EventRequestModel.fromMap(item.data());
        req.docId = item.id;
        eventRequests.add(req);
      }
    }
    eventRequests.sort((a, b) => b.status.compareTo(a.status));
    return eventRequests;
  }

  readRequest(String docId) {
    _eventRequestsRef.doc(docId).update({'status' : 'Accepted'});
  }

  Future deletePost(String eventId) async {
    var requestDocs = await _eventRequestsRef.where('eventID', isEqualTo: eventId).get();
    for (var item in requestDocs.docs) {
      await _eventRequestsRef.doc(item.id).delete();
    }
    await _eventsRef.doc(eventId).delete();
    getActiveEvents();
  }
}
