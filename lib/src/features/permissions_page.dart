
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hitch/src/features/main_menu_page.dart';
import 'package:hitch/src/models/permission_accepted_rejected_model.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:hitch/src/widgets/loading_widget.dart';

import '../notifications/notification_service.dart';
import '../res/string_constants.dart';
import '../services/app_icon_badger_service.dart';
import '../services/auth_service.dart';

class PermissionsPage extends StatefulWidget{
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  final userAuthService = UserAuthService.instance;
  @override
  void initState() {
    _initPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: Padding(
          padding: EdgeInsets.only(
              bottom: 20,
              left: 18,
              right: 18
          ),
          child: LoadingWidget(),
        ))
    );
  }

  void _initPermissions() async {

    try{
      LocationPermissionResponseModel permissionResponse =  await Utils.getUpdateUserLocation();
      if(!permissionResponse.permissionGranted){
        _showRequestDialog(locationPermissionDescription);
      }
      //Get notification permission then
      await NotificationService.requestPermissions().then((value) {});
      await _initNotification();
      initPlatformState();
      _initGoogleMobileAds();
    }catch(e){
      debugPrint("Error while getting permission");
    }
    _navigateToMainMenu();
  }

  Future<void> _checkLocationPermissionAndPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    // Check location permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return Future.error('Location permission permanently denied.');
    }

    // If permissions are granted, get the position stream
    try {
      LocationSettings locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.airborne,
        distanceFilter: 50,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );

      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        Map<String, dynamic> locationMap = {
          'latitude': position.latitude,
          'longitude': position.longitude
        };
        userAuthService.updateUserInfo(updatedMap: locationMap);
      });
    } catch (e) {
      debugPrint("Failed to get current position: ${e.toString()}");
    }
  }

  Future<void> _initNotification() async {
    try{
      await NotificationService.initializeLocalNotifications();
      await NotificationService.initializeFirebaseMessaging().then((value) {
        NotificationService.startNotificationListeners();
      });
      NotificationService.startNotificationClickListeners();
    }catch(e){
      debugPrint("Exception while notification configuration: ${e.toString()}");
    }

    _checkLocationPermissionAndPosition();
  }

  void _showRequestDialog(String requestMsg) {
    Utils.showPermissionRequestDialog(context, requestMsg);
  }

  void _navigateToMainMenu() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => const MainMenuPage()),
        (route) => false);
  }

  initPlatformState() async {
    String appBadgeSupported;
    try {
      bool res = await FlutterAppBadgeControl.isAppBadgeSupported();
      if (res) {
        appBadgeSupported = 'Supported';
        AppIconBadgerService.updateAppIconBadge();
      } else {
        appBadgeSupported = 'Not supported';
      }
    } on PlatformException {
      appBadgeSupported = 'Failed to get badge support.';
    }

    debugPrint("Badge Supported: $appBadgeSupported");
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

  }

  Future<void> _initGoogleMobileAds() async{
   await MobileAds.instance.initialize();

   // if(Platform.isIOS){
   //   // Add your test device ID
   //   RequestConfiguration requestConfiguration = RequestConfiguration(
   //     testDeviceIds: ['08c5c075673afda66f4179c03d88006a'],
   //   );
   //   MobileAds.instance.updateRequestConfiguration(requestConfiguration);
   // }
  }

}