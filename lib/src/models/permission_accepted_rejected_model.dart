import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPermissionResponseModel {
  final bool permissionGranted;
  final LatLng latLng;

  LocationPermissionResponseModel({required this.permissionGranted, required this.latLng});
}