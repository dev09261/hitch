import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hitch/src/features/in_app_purchase/store_config.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../providers/subscription_provider.dart';
import '../../res/app_colors.dart';
import '../../res/app_text_styles.dart';
import '../../utils/utils.dart';

class InAppPurchaseConfig {
  static final String _appleApiKey = dotenv.env['APPSTORE_PUBLIC_KEY']!;
  static final String _googleApiKey = dotenv.env['PLAYSTORE_PUBLIC_KEY']!;

  static Future<void> configInAppPurchases()async{
    //Get the current User first
   UserModel? user = await UserAuthService.instance.getCurrentUser();

   if(user!= null){
     if (Platform.isIOS || Platform.isMacOS) {
       StoreConfig(
         store: Store.appStore,
         apiKey: _appleApiKey,
       );

     }
     else if (Platform.isAndroid) {
      StoreConfig(
        store: Store.playStore,
        apiKey: _googleApiKey,
      );
    }
     String revenueCatUserID = '${user.userName}-${user.userID}';
     await _configureSDK(revenueCatUserID);
   }

  }

  static Future<void> _configureSDK(String userID) async {
    // Enable debug logs before calling `configure`.
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (StoreConfig.isForAmazonAppstore()) {
      configuration = AmazonConfiguration(StoreConfig.instance.apiKey)
        ..appUserID = userID
        ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();
    } else {
      configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
        ..appUserID = userID
        ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();
    }
    await Purchases.configure(configuration);
    fetchPackages();
  }


  static Future<List<Package>> fetchPackages() async {

    List<Package> packages = [];
    try {
      Offerings offerings = await Purchases.getOfferings();
      debugPrint("Offerings: ${offerings.all.length}");
      if(offerings.current != null){
        packages = offerings.current!.availablePackages;
      }
    }catch (e) {
      debugPrint("Exception while fetching offers: ${e.toString()}");
    }
    return packages;
  }

  static Future<Package> get7DaysPackage()async {
    Offerings offerings = await Purchases.getOfferings();
    Offering sevenDaysOffer = offerings.all['hitch_premium_consumable']!;

    return sevenDaysOffer.availablePackages.first;
  }

  static Future<List<Package>> getSubscriptionPackages()async {
    Offerings offerings = await Purchases.getOfferings();
    Offering susbscriptionOffering = offerings.all['hitch_premium_subscriptions']!;

    List<Package> packages = susbscriptionOffering.availablePackages;
    List<Package> mutablePackages = List.of(packages); // Creates a mutable copy

// Swap elements
    if (mutablePackages.length >= 2) {
      var temp = mutablePackages[0];
      mutablePackages[0] = mutablePackages[1];
      mutablePackages[1] = temp;
    }

    return mutablePackages;
  }

  static void onRestorePurchaseTap({required BuildContext context})async{
    /// Returns a [CustomerInfo] object, or throws a [PlatformException] if there
    /// was a problem restoring transactions.

    final subscriptionProvider = Provider.of<SubscriptionProvider>(context,listen: false);
    if(subscriptionProvider.getIsSubscribed){
      try {
        CustomerInfo customerInfo = await Purchases.restorePurchases();
        if(customerInfo.activeSubscriptions.isNotEmpty){

          _updateProvider(customerInfo: customerInfo, context: context);
        }
        // ... check restored purchaserInfo to see if entitlement is now active
      } on PlatformException catch (e) {
        // Error restoring purchases
        _showSnackBar(context, title: "Failed To Restore purchase", description: e.message!);
      }
    }else{
      _showSnackBar(context);
    }
  }

  static void _updateProvider({required CustomerInfo customerInfo, required BuildContext context}) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    subscriptionProvider.subscribe();
  }

  static void _showSnackBar(BuildContext context, {String title = 'No Active Subscription Found', String description = 'It looks like you don’t have an active subscription. Please subscribe to access premium features.'}){
    Utils.showTopSnackBar(context,
        content: Container(
          decoration: BoxDecoration(
              color: AppColors.primaryDarkColor,
              borderRadius: BorderRadius.circular(10)
          ),
          padding: const EdgeInsets.all(10),
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, color: Colors.black)),
              Text(description, style: AppTextStyles.regularTextStyle.copyWith(color: Colors.white),)
            ],
          ),
        ));
  }


}