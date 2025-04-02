import 'package:flutter/material.dart';
import 'package:hitch/src/features/paywalls/subscription_paywall.dart';
import 'package:hitch/src/res/app_colors.dart';

class FilterSubscriptionPaywall extends StatelessWidget{
  const FilterSubscriptionPaywall({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 30,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(onPressed: ()=> Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryColor,)),
      ),
      body: const SafeArea(
        child: SubscriptionPaywall(popupUpOnSubscription: true,),
      ),
    );
  }

}