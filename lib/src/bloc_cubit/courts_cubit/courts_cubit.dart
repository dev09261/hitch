import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitch/src/models/permission_accepted_rejected_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import '../../features/main_menu/court_finder/markers_page.dart';
import '../../models/places_api_response_model.dart';

part 'courts_states.dart';
class CourtsCubit extends Cubit<CourtsStates>{
  CourtsCubit(): super(InitialCourtStates());

  void loadCourts()async{
    emit(LoadingCourts());
    LatLng initialCameraPosition;
    UserModel? user = await UserAuthService.instance.getCurrentUser();
    if(user != null){
      LocationPermissionResponseModel response = await Utils.getUpdateUserLocation();
      if(response.permissionGranted){
        initialCameraPosition = response.latLng;
        emit(CurrentLocationCameraPosition(initialCameraPosition: CameraPosition(target: initialCameraPosition)));
        _initCourts(initialCameraPosition);
      }else{
        emit(LocationPermissionDeniedForever());
      }
    }else{
      emit(UserNotFound());
    }

    /*UserModel? user = await UserAuthService().getCurrentUser();
    if(user != null){
      if(user.latitude != null){
        initialCameraPosition = LatLng(user.latitude!, user.longitude!);
        emit(CurrentLocationCameraPosition(initialCameraPosition: CameraPosition(target: initialCameraPosition)));
        _initCourts(initialCameraPosition);
      }else {

        if (response.permissionGranted) {
          initialCameraPosition = response.latLng;
          initialCameraPosition = LatLng(user.latitude!, user.longitude!);
          emit(CurrentLocationCameraPosition(initialCameraPosition: CameraPosition(target: initialCameraPosition)));
          _initCourts(initialCameraPosition);
        } else {
          emit(LocationPermissionDeniedForever());
        }

      }
    }else{
      emit(UserNotFound());
    }*/
  }

  void _initCourts(LatLng initialCameraPosition) async{
    emit(CurrentLocationCameraPosition(initialCameraPosition: CameraPosition(target: initialCameraPosition, zoom: 12)));
    try{
      String placesAPIKey =  dotenv.env['PLACES_API_KEY']!;
      // get the nearby courts
      List<NearbyCourts> results = [];
      final String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=${initialCameraPosition.latitude},${initialCameraPosition.longitude}'
          '&radius=6000' // You can adjust the radius as needed (in meters)
          '&type=establishment'
          '&keyword=tennis+court|pickleball+court'
          '&key=$placesAPIKey';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);
        PlacesApiResponse placesResponse = PlacesApiResponse.fromJson(jsonMap);
        results = placesResponse.results;
        for (var result in results) {
          double courtLatitude = result.geometry.location.lat;
          double courtLongitude = result.geometry.location.lng;
          double distanceInMeters = Geolocator.distanceBetween(
            initialCameraPosition.latitude,
            initialCameraPosition.longitude,
            courtLatitude,
            courtLongitude,
          );
          result.distanceInMiles = distanceInMeters;
        }
        results.sort((a, b) => a.distanceInMiles.compareTo(b.distanceInMiles));

        results = results.map((court) {
          // debugPrint("Distance in miles before: ${court.distanceInMiles}");
          double distanceInMiles = Utils.getDistanceInMiles(court.distanceInMiles);
          court.distanceInMiles = distanceInMiles;
          // debugPrint("Distance in miles after: ${court.distanceInMiles}");
          return court;
        }).toList();

        emit(LoadedCourts(courtsNearby: results));
        Set<Marker> markers = {};
        for(int i=0;i<results.length;i++){
          NearbyCourts result = results[i];
          double latitude = result.geometry.location.lat;
          double longitude = result.geometry.location.lng;

          markers.add(Marker(
              markerId: MarkerId(result.placeId),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: result.name,
                snippet: result.vicinity,
              ),
              icon:  await TextOnImage(
              text: (i+1).toString(),
          ).toBitmapDescriptor(logicalSize: const Size(150, 150), imageSize: const Size(300, 400)),

          ));
        }
        emit(LoadedMarkersOfCourts(markers: markers));
      } else {
        throw Exception('Failed to load nearby tennis courts');
      }
    } catch (e) {
      emit(LoadingCourtsFailed(errorMessage: e.toString()));
    }
  }

}