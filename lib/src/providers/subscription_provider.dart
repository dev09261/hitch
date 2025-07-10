import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionProvider with ChangeNotifier{
  bool _isSubscribed = true;
  Map<String, EntitlementInfo>? _subscribedPackage;


  bool get getIsSubscribed => _isSubscribed;
  Map<String, EntitlementInfo>? get getSubscribedPackage => _subscribedPackage;

  SubscriptionProvider(){
        subscribe();
    _initializePurchases();
  }

  void subscribe() {
    _isSubscribed = true;
    notifyListeners();
  }

  void unsubscribe() {
    _isSubscribed = false;
    notifyListeners();
  }

  Future<void> _initializePurchases() async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      // Check if the customer has any active entitlements
      bool hasActiveSubscription = customerInfo.activeSubscriptions.isNotEmpty;
      debugPrint("Has active subscription: $hasActiveSubscription");
      // Update the subscription status based on active entitlements
      if (hasActiveSubscription) {
        subscribe();
      } else {
        unsubscribe();
      }
    });
  }
}