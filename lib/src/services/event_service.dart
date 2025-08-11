import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hitch/src/models/event_model.dart';
import 'package:hitch/src/models/pickleball_tournament_model.dart';
import 'package:hitch/src/providers/hitches_provider.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/utils.dart';
import 'hitches_service.dart';

class EventService {
  static final _eventsRef =
      FirebaseFirestore.instance.collection(eventsCollection);
  static final _userColRef =
      FirebaseFirestore.instance.collection(userCollection);
  static Future<EventModel> createEvent(
      {required String title,
      required String description,
      required String imagePath,
      required DateTime eventDate,
      required bool isForEveryOne,
      double? lat,
      double? lng,
      String? eventUrl}) async {
    String? imageUrl = await getProfileUrl(eventPicPath: imagePath);

    DateTime now = DateTime.now();
    String eventID = now.millisecondsSinceEpoch.toString();
    EventModel event = EventModel(
        eventID: eventID,
        createdAt: now,
        eventDate: eventDate,
        title: title,
        description: description,
        eventImageUrl: imageUrl!,
        isForEveryOne: isForEveryOne,
        latitude: lat,
        longitude: lng,
        createdByUserID: FirebaseAuth.instance.currentUser!.uid,
        eventUrl: eventUrl);

    await _eventsRef.doc(eventID).set(event.toMap());
    return event;
  }

  static Future<String?> getProfileUrl({required String eventPicPath}) async {
    File imageFile = File(eventPicPath);
    String? profileUrl;
    try {
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('event_${DateTime.now().toIso8601String()}/$eventPicPath')
          .putFile(imageFile);
      profileUrl = await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Exception found: ${e.toString()}");
    }
    return profileUrl;
  }

/*  static Stream<List<EventModel>> get eventsStream {
    return _eventsRef.snapshots().map((snapshot) => snapshot.docs
        .map((snapshot) => EventModel.fromMap(snapshot.data()))
        .toList());
  }*/

  static Stream<List<EventModel>> getEventsStream(BuildContext context) {
    List<String> acceptedUserIDs =
        Provider.of<HitchesProvider>(context, listen: false)
            .acceptedHitchUserIds;
    return _eventsRef.snapshots().asyncMap((snapshot) async {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return []; // No authenticated user

      // Fetch current user details
      DocumentSnapshot currentUserDoc =
          await _userColRef.doc(currentUser.uid).get();
      if (!currentUserDoc.exists) return []; // No user data available

      UserModel currentUserData =
          UserModel.fromMap(currentUserDoc.data() as Map<String, dynamic>);

      List<EventModel> filteredEvents = [];

      // debugPrint("Events found: ${snapshot.docs.length} and my UID: ${currentUserData.userID}");
      for (var doc in snapshot.docs) {
        EventModel event = EventModel.fromMap(doc.data());
        // debugPrint("Event: ${event.eventID}, creatorID: ${event.createdByUserID}");
        if (event.createdByUserID == currentUserData.userID) {
          filteredEvents.add(event);
        } else if (event.isForEveryOne) {
          // Fetch event creator details
          DocumentSnapshot creatorDoc =
              await _userColRef.doc(event.createdByUserID).get();
          if (!creatorDoc.exists) continue; // Skip if creator details not found

          UserModel creatorUserData =
              UserModel.fromMap(creatorDoc.data() as Map<String, dynamic>);

          // Check if both users have valid locations
          if (currentUserData.latitude != null &&
              currentUserData.longitude != null &&
              creatorUserData.latitude != null &&
              creatorUserData.longitude != null) {
            double distance = Geolocator.distanceBetween(
              currentUserData.latitude!,
              currentUserData.longitude!,
              creatorUserData.latitude!,
              creatorUserData.longitude!,
            );
            double distanceInMiles = Utils.getDistanceInMiles(distance);
            // debugPrint("Event: ${event.eventID}, creatorID: ${event.createdByUserID}, and Distance in miles: $distanceInMiles");
            if (distanceInMiles <= 200) {
              filteredEvents.add(event);
            }
          }
        } else {
          // debugPrint("Accepted usersIDs: ${acceptedUserIDs.length}");
          //Check if the creator is in the my hitches
          if (acceptedUserIDs.contains(event.createdByUserID)) {
            filteredEvents.add(event);
          }
        }
      }

      return filteredEvents;
    });
  }

  static Stream<List<EventModel>> getStream() {
    return FirebaseFirestore.instance
        .collection(eventsCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data()))
            .toList());
  }

  static Future<Map<String, dynamic>> fetchTournaments(
      int page, int limit) async {
    const String url = "https://fe-gql.pickleball.com/graphql";
    List<Tournament> tournaments = [];
    bool hasMore = true;
    UserModel? currentUser = await UserAuthService.instance.getCurrentUser();

    if (currentUser == null) {
      return {'tournaments': tournaments, 'hasMore': false};
    }

    const String getTournamentsQuery = r'''
query GetTournaments(
  $bounds: BoundsInput,
  $endDate: String,
  $keyword: String,
  $clubId: String,
  $limit: Int,
  $nowPlaying: Boolean,
  $nowRegistering: Boolean,
  $featured: Boolean,
  $page: Int,
  $center: LatLng,
  $userLocationFetch: Boolean,
  $pastEvents: Boolean,
  $userId: String,
  $myTournaments: Boolean,
  $mtManaging: Boolean,
  $mtPast: Boolean,
  $tournamentFilter: String,
  $partner: String,
  $startDate: String,
  $requesterUuid: String
) {
  tournaments(
    bounds: $bounds
    endDate: $endDate
    keyword: $keyword
    clubId: $clubId
    limit: $limit
    nowPlaying: $nowPlaying
    featured: $featured
    nowRegistering: $nowRegistering
    userId: $userId
    page: $page
    center: $center
    userLocationFetch: $userLocationFetch
    myTournaments: $myTournaments
    mtManaging: $mtManaging
    mtPast: $mtPast
    tournamentFilter: $tournamentFilter
    pastEvents: $pastEvents
    partner: $partner
    startDate: $startDate
    requesterUuid: $requesterUuid
  ) {
    items {
      id
      dateFrom
      dateTo
      currency
      location
      isCanceled
      isCostPerEvent
      isFavorite
      isFree
      isPrizeMoney
      isRegistrationClosed
      isTournamentCompleted
      lat
      lng
      logo
      price
      registrationCount
      slug
      status
      title
      additionalImages
      hideRegisteredPlayers
      isAdvertiseOnly
      __typename
    }
    totalCount
    __typename
  }
}
''';

    var bounds = Utils.calculateBoundingBox(currentUser.latitude!, currentUser.longitude!, 200);

    final Map<String, dynamic> payload = {
      "operationName": "GetTournaments",
      "variables": {
        "bounds": {
          "ne_lat": bounds.maxLat,
          "ne_lng": bounds.maxLng,
          "sw_lat": bounds.minLat,
          "sw_lng": bounds.minLng,
        },
        "keyword": null,
        "limit": limit,
        "center": {"lat": currentUser.latitude!, "lng": currentUser.longitude},
        "nowPlaying": false,
        "clubId": null,
        "nowRegistering": false,
        "pastEvents": false,
        "page": page,
        "featured": false,
        "myTournaments": false,
        "mtManaging": false,
        "mtPast": false,
        "userLocationFetch": false,
        "userId": null,
        "startDate": null,
        "endDate": null,
        "partner": null,
        "tournamentFilter": null,
        "requesterUuid": null,
      },
      "query": getTournamentsQuery,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // debugPrint("Data get: ${data}");
      PickleballTournamentModel pickleballTournaments =
          PickleballTournamentModel.fromJson(data);

      print(pickleballTournaments.data.tournaments.totalCount);

      hasMore = pickleballTournaments.data.tournaments.totalCount > limit;
      UserModel? currentUser = await UserAuthService.instance.getCurrentUser();
      if (currentUser != null) {
        for (var tournament in pickleballTournaments.data.tournaments.items) {
          // Convert tournament dateTo to DateTime

          // Only add future tournaments
          double distanceInMeters = Geolocator.distanceBetween(
              currentUser.latitude!,
              currentUser.longitude!,
              tournament.lat,
              tournament.lng);

          tournament.distance = distanceInMeters;
          tournaments.add(tournament);
        }

        // Sort tournaments from closest to farthest
        tournaments.sort((a, b) => a.distance.compareTo(b.distance));
        tournaments.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      }
    }

    return {'tournaments': tournaments, 'hasMore': hasMore};
  }

  static Future<List<EventModel>> getLocalTournaments(
      UserModel currentUser) async {
    List<EventModel> events = [];
    List<String> myHitchesIds =
        await HitchesService.getAcceptedHitchesUserIds();

    GeoBox box = Utils.calculateBoundingBox(
        currentUser.latitude!, currentUser.longitude!, 200);

    myHitchesIds.add(currentUser.userID);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(eventsCollection)
        .where('createdByUserID', whereIn: myHitchesIds)
        .where('latitude', isGreaterThanOrEqualTo: box.minLat)
        .where('latitude', isLessThanOrEqualTo: box.maxLat)
        .where('longitude', isGreaterThanOrEqualTo: box.minLng)
        .where('longitude', isLessThanOrEqualTo: box.maxLng)
        .where('isForEveryOne', isEqualTo: false)
        .where('eventDate',
        isGreaterThan: DateTime.now()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch)
        .get();

    events = querySnapshot.docs
        .map((doc) => EventModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    if (currentUser.latitude != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(eventsCollection)
          .where('latitude', isGreaterThanOrEqualTo: box.minLat)
          .where('latitude', isLessThanOrEqualTo: box.maxLat)
          .where('longitude', isGreaterThanOrEqualTo: box.minLng)
          .where('longitude', isLessThanOrEqualTo: box.maxLng)
          .where('isForEveryOne', isEqualTo: true)
          .where('eventDate',
          isGreaterThan: DateTime.now()
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch)
          .get();

      for (var doc in querySnapshot.docs) {
        EventModel event =
            EventModel.fromMap(doc.data() as Map<String, dynamic>);
        events.add(event);
      }
    }
    events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return events;
  }

  static void deleteAllEvents() async {
    QuerySnapshot querySnapshot = await _eventsRef.get();
    querySnapshot.docs.forEach((doc) {
      String docID = doc.id;
      _eventsRef.doc(docID).get().then((eventDoc) async {
        if (eventDoc.exists) {
          await eventDoc.reference.delete();
          debugPrint("Doc $docID deleted");
        }
      });
    });
  }
}
