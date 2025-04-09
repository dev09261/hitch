import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitch/src/models/permission_accepted_rejected_model.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/primary_btn.dart';

class GeoBox {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  GeoBox(this.minLat, this.maxLat, this.minLng, this.maxLng);
}

class Utils {
  static Future<void> saveToCache({required String key, required String value})async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(key, value);
  }

  static Future<String?> getFromCache({required String key})async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(key);
  }

  static double calculateDistance(LatLng currentLocation, LatLng courtLocation) {
    const double earthRadius = 3958.8; // Radius of the Earth in miles

    double dLat = radians(courtLocation.latitude - currentLocation.latitude);
    double dLng = radians(courtLocation.longitude - courtLocation.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(radians(currentLocation.latitude)) * cos(radians(courtLocation.latitude)) *
            sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double radians(double degrees) {
    return degrees * pi / 180;
  }

  static String getCourtPhotoUrlFromReference(String photoReference, {int maxWidth = 400, int maxHeight = 400}) {
    String placesAPIKey =  dotenv.env['PLACES_API_KEY']!;
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=$maxWidth&maxheight=$maxHeight'
        '&photoreference=$photoReference'
        '&key=$placesAPIKey';
  }

  static double getDistanceInMiles(double distanceInMeters){
    return distanceInMeters / 1609.34;
  }

  static Future<String> getCityName(UserModel player) async{
    final userAuthService = UserAuthService.instance;
    UserModel? currentUser = await userAuthService.getCurrentUser();
    if(currentUser != null){
      double startLatitude = currentUser.latitude!;
      double startLongitude = currentUser.longitude!;
      double endLatitude = player.latitude!;
      double endLongitude = player.longitude!;
      double distanceInMeters = Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
      double distanceInMiles = Utils.getDistanceInMiles(distanceInMeters);

      String cityName = '';
      try {
        List<Placemark> placeMarks = await placemarkFromCoordinates(player.latitude!, player.longitude!);
        if (placeMarks.isNotEmpty) {
          cityName =  placeMarks.first.locality!; // This returns the city name
        }
      } catch (e) {
        debugPrint('Error while getting cityName: $e');
      }

      return '${distanceInMiles.toStringAsFixed(2)} miles away ($cityName)';
    }

    return '';
  }

  static void showCopyToastMessage({String message = 'Address Copied to clipboard'}){
    Fluttertoast.showToast(msg: message, gravity: ToastGravity.BOTTOM,);
  }

  static Future<void> launchEmail({required String email,required String subject, required String body})async{
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject&body=$body', // Add subject and body here
    );

    if (await canLaunchUrl(params)) {
    await launchUrl(params);
    } else {
    throw 'Could not launch $params';
    }
  }

  static void launchSMS({required String phoneNumber, required String message}) async {
    final Uri params = Uri(
      scheme: 'sms',
      path: phoneNumber,
      query: 'body=$message',
    );

    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      throw 'Could not launch $params';
    }
  }

  static void launchAppUrl({required String url}) async {
    Uri termsOfUse = Uri.parse(url);
    if(await canLaunchUrl(termsOfUse)){
      await launchUrl(termsOfUse);
    }
  }

  static void showTopSnackBar(
      context,{
        Duration? duration,
        Widget? content
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.up,
        backgroundColor: Colors.white,
        duration: const Duration(milliseconds: 400),
        content: content ?? Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)
          ), child: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.close_rounded, color: AppColors.primaryColor,),
            ),
            SizedBox(width: 10,),
            Expanded(child: Text("Password did not meet the requirements", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'Inter'),))
          ],
        ),),
      ),
    );
  }
  static Future<LocationPermissionResponseModel> getUpdateUserLocation() async {
    final userAuthService = UserAuthService.instance;
    LatLng defaultLatLng = const LatLng(0, 0);
    bool permissionGranted = false;
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      await Geolocator.openLocationSettings();
    }

    // Check and request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permissionGranted = false;
        // return LocationPermissionResponseModel(permissionGranted: false, latLng: defaultLatLng);
      }
    }else if (permission == LocationPermission.deniedForever) {
      permissionGranted = false;
      // return LocationPermissionResponseModel(permissionGranted: false, latLng: defaultLatLng);
    }else if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      permissionGranted = true;
      try {
        // Fetch last known location first
        Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition != null) {
          // debugPrint("Last known position: ${lastKnownPosition.latitude}");

          defaultLatLng = LatLng(lastKnownPosition.latitude, lastKnownPosition.longitude);
          Map<String, dynamic> locationMap = {
            'latitude': lastKnownPosition.latitude,
            'longitude':  lastKnownPosition.longitude
          };
          userAuthService.updateUserInfo(updatedMap: locationMap);
        } else {
          // Add a small delay before getting current position
          await Future.delayed(const Duration(seconds: 2));

          // Now get the current position
          Position currentPosition = await Geolocator.getCurrentPosition();
          // debugPrint("Current position: ${currentPosition.latitude}");
          defaultLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
          Map<String, dynamic> locationMap = {
            'latitude': currentPosition.latitude,
            'longitude': currentPosition.longitude
          };
          userAuthService.updateUserInfo(updatedMap: locationMap);
        }
      } catch (e) {
        debugPrint("Exception while getting position: ${e.toString()}");
      }
    }

    return LocationPermissionResponseModel(permissionGranted: permissionGranted, latLng: defaultLatLng);
  }

  static Future<void> showPermissionRequestDialog(BuildContext context, String description)async{
    late BuildContext dialogContext;
    try{
      PermissionStatus permissionStatus = await Permission.photos.request();
      if(permissionStatus.isPermanentlyDenied){
        showDialog(context: context, builder: (ctx){
          dialogContext = ctx;
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
            ),
            content: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Permission required!", style: AppTextStyles.pageHeadingStyle,),
                  const SizedBox(height: 10,),
                  Text(description, style: const TextStyle(fontSize: 14),),

                  const SizedBox(height: 20,),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: PrimaryBtn(btnText: "Open Settings", onTap: (){
                      Navigator.of(dialogContext).pop();
                      openAppSettings();
                    }),
                  )
                ],
              ),
            ),
          );
        });
      }
    }catch(e){
      debugPrint("Exception: ${e.toString()}");
    }
  }

  static String getPlayerLevelText(UserModel player) {

    String pickLevelLabel = "";
    if (player.pickleBallPlayerLevel != null) {
      pickLevelLabel = player.pickleBallPlayerLevel!.levelRank;

      if (pickLevelLabel == '2.0') {
        pickLevelLabel = '0.0 ~ 2.99';
      } else if (pickLevelLabel == '3.0') {
        pickLevelLabel = '3.0 ~ 3.99';
      } else if (pickLevelLabel == '4.0') {
        pickLevelLabel = '4.0 ~ 4.99';
      } else if (pickLevelLabel == '5.0') {
        pickLevelLabel = '5.0 ~ 5.99';
      } else if (pickLevelLabel == '6.0') {
        pickLevelLabel = '6.0 ~ 6.99';
      } else if (pickLevelLabel == '7.0') {
        pickLevelLabel = '7.0 ~ 7.99';
      } else if (pickLevelLabel == '8.0') {
        pickLevelLabel = '8.0 ~ ';
      }
      
    }

    if(player.pickleBallPlayerLevel != null && player.tennisBallPlayerLevel != null){
      if (player.isConnectedToDupr) {
        return '${player.duprDoubleRating} Pickleball & ${player.tennisBallPlayerLevel!.levelRank} Tennis';
      }
      return '$pickLevelLabel Pickleball & ${player.tennisBallPlayerLevel!.levelRank} Tennis';
    }else if(player.pickleBallPlayerLevel != null){
      if (player.isConnectedToDupr) {
        return '${player.duprDoubleRating} Pickleball';
      }
      return '$pickLevelLabel Pickleball ';
    }else if(player.tennisBallPlayerLevel != null){
      return '${player.tennisBallPlayerLevel!.levelRank} Tennis ';
    }else if(player.playerTypeCoach){
      return getCoachExperienceDetails(player);
    }else if(player.playerTypePickle && player.playerTypeTennis){
      if (player.isConnectedToDupr) {
        return '${player.duprDoubleRating} Pickleball & Tennis';
      }
      return '${player.level} Pickleball & Tennis';
    }else if(player.playerTypePickle){
      if (player.isConnectedToDupr) {
        return '${player.duprDoubleRating} Pickleball';
      }
      return '${player.level} Pickleball';
    }else if(player.playerTypeTennis){
      return '${player.level} Tennis';
    }
    return player.level;
  }

  static String getCoachExperienceDetails(UserModel user) {
    // Check if the player is a coach
    if (!user.playerTypeCoach && user.experience!.isEmpty) {
      return "-";
    }
    // debugPrint("Player: ${user.toMap()}");

    // Check the conditions for experience and levels
    if (user.experience == null && user.experience!.isEmpty &&
        user.coachPickleBallExperienceLevel == null &&
        user.coachTennisBallExperienceLevel == null) {
      return "-";
    }

    // Return the combined experience details if all conditions are met

    if(user.experience != null && user.experience!.isNotEmpty){
      return user.experience!;
    }else if(user.coachPickleBallExperienceLevel != null && user.coachTennisBallExperienceLevel != null){
      return '${user.coachPickleBallExperienceLevel!.experienceInYears} Pickleball & ${user.coachPickleBallExperienceLevel!.experienceInYears} Tennis';
    }else if(user.coachPickleBallExperienceLevel != null){
      return '${user.coachPickleBallExperienceLevel!.experienceInYears} Pickleball';
    }else if(user.coachTennisBallExperienceLevel != null){
      return '${user.coachTennisBallExperienceLevel!.experienceInYears} Tennis';
    }else{
      return '-';
    }
  }

  static Future<String> getUserLocationFromLatLng(double latitude, double longitude) async {
    String address = 'Unknown Location';
    String googleAPIKey = dotenv.env['GOOGLE_API_KEY_FOR_LOCATION']!;
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleAPIKey';

    try {
      final response = await http.get(Uri.parse(url));
      // debugPrint("Result: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final List<dynamic> addressComponents = data['results'][0]['address_components'];
          String city = '';
          String state = '';
          String country = '';

          // Iterate through address components to find city, state, and country
          for (var component in addressComponents) {
            final types = component['types'] as List;
            if (types.contains('locality')) {
              city = component['long_name'];
            } else if (types.contains('administrative_area_level_1')) {
              state = component['short_name'];
            } else if (types.contains('country')) {
              country = component['long_name'];
            }
          }

          if(city.isNotEmpty){
            address = city;
          }else if(state.isNotEmpty){
            address = state;
          }else {
            address = country;
          }
        } else {
          debugPrint('Geocoding API returned no results or status not OK. Status: ${data['status']}');
        }
      } else {
        debugPrint('Failed to fetch geocoding data. HTTP status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error during geocoding: $e');
    }

    return address;
  }

  static GeoBox calculateBoundingBox(double lat, double lng, double distanceInMiles) {
    const double earthRadius = 3958.8; // Radius of Earth in miles
    double latRadian = lat * (3.14159 / 180); // Convert to radians

    // Approximate degrees per mile
    double latDegreePerMile = 1 / 69.0; // 1 degree latitude ≈ 69 miles
    double lngDegreePerMile =
        1 / (69.0 * cos(latRadian)); // Adjust longitude based on latitude

    double deltaLat = distanceInMiles * latDegreePerMile;
    double deltaLng = distanceInMiles * lngDegreePerMile;

    return GeoBox(
      lat - deltaLat, // minLat
      lat + deltaLat, // maxLat
      lng - deltaLng, // minLng
      lng + deltaLng, // maxLng
    );
  }
}