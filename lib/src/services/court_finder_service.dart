import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/utils/utils.dart';

import '../models/sponsored_club_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class CourtFinderService {
  static final _sponsoredColRef = FirebaseFirestore.instance.collection(sponsoredCollection);
  static Future<void> uploadSponsoredPicklrToDb({required List<SponsoredClubModel> sponsoredClubs})async {
    debugPrint("Length: ${sponsoredClubs.length}");
    for (var club in sponsoredClubs) {
      try{
       await _sponsoredColRef.add(club.toMap());
       debugPrint("Club ${club.name} added");
      }catch(e){
        debugPrint("Adding club failed: ${e.toString()}");
      }
    }
  }

  static Future<List<Map<String, dynamic>>> getSponsoredClubs()async {
    List<Map<String, dynamic>> sponsoredMap = [];
    UserModel? user = await UserAuthService.instance.getCurrentUser();
   QuerySnapshot querySnapshot = await _sponsoredColRef.where("status", isEqualTo: 'Open').get();
   List<SponsoredClubModel> sponsoredClubs = querySnapshot.docs.map((doc)=> SponsoredClubModel.fromMap(doc.data() as Map<String,dynamic>)).toList();

    for (var sponsored in sponsoredClubs) {
     try{
       List<Location> locations = await locationFromAddress(sponsored.address);
       if (locations.isNotEmpty) {
         double distance = Geolocator.distanceBetween(
           // 30.396032, -88.885307,
           user!.latitude ?? 0.0,
           user.longitude ?? 0.0,
           locations.first.latitude,
           locations.first.longitude,
         );

         double miles = Utils.getDistanceInMiles(distance);
         // debugPrint("Miles found: $miles");
         /*sponsoredMap.add({
           distanceKey : miles,
           clubKey : sponsored,
           'latitude': locations.first.latitude,
           'longitude': locations.first.longitude
         });*/
         if(miles <= 30){
           sponsoredMap.add({
             distanceKey : miles,
             clubKey : sponsored,
             'latitude': locations.first.latitude,
             'longitude': locations.first.longitude
           });
         }
       }
     }catch(e){
       debugPrint("Exception while getting latitude from address: ${e.toString()}");
     }
   }
   return sponsoredMap;
  }

}