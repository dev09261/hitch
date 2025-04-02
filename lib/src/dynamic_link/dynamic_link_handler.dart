// ignore_for_file: deprecated_member_use
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';

class DeepLinkHelper {
/*  static Future<String> generateDynamicLink() async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://hitch-dynamic-link.vercel.app/"),
      uriPrefix: "https://hitchplayerfinder.page.link", // Updated to include https://
      androidParameters: const AndroidParameters(
        packageName: 'com.willparton.hitch',
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.zenmarkx.zenmark',
      ),
    );
    try {
      if (Platform.isIOS) {
        final dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
        debugPrint("Dynamic Link: ${dynamicLink.shortUrl}");
        return dynamicLink.shortUrl.toString();
      } else {
        final dynamicLink =
        await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);
        debugPrint("Dynamic Link: ${dynamicLink.toString()}");
        return dynamicLink.toString();
      }
    } catch (e) {
      debugPrint("Exception while getting dynamic link: ${e.toString()}");
    }
    return '';
  }*/

  static FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  static Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      // Listen and retrieve dynamic links here
      final String deepLink = dynamicLinkData.link.toString(); // Get DEEP LINK

      if(deepLink.isEmpty)  return;
      _handleDeepLink(dynamicLinkData.link);
    }).onError((error) {
      debugPrint('onLink error');
      debugPrint(error.message);
    });
    _initUniLinks();
  }

  static Future<void> _initUniLinks() async {
    try {
      final initialLink = await dynamicLinks.getInitialLink();
      if(initialLink == null)  return;
      _handleDeepLink(initialLink.link);
    } catch (e) {
      // Error
    }
  }
  static void _handleDeepLink(Uri deepLink) {
    debugPrint("Path found: ${deepLink.path}");
    // navigate to detailed product screen
  }
}
