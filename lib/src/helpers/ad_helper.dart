import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdHelper {


  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ANDROID_INTERSTITIAL_ADDID']!;
    } else if (Platform.isIOS) {
      return dotenv.env['IOS_INTERSTITIAL_ADDID']!;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ANDROID_BANNER_ADID']!;
    } else if (Platform.isIOS) {
      return dotenv.env['IOS_BANNER_ADID']!;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

}