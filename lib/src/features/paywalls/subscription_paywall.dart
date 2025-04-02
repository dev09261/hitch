import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hitch/src/features/in_app_purchase/in_app_purchase_config.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../providers/subscription_provider.dart';
import '../../res/app_icons.dart';
import '../../res/string_constants.dart';
import '../../utils/utils.dart';

class SubscriptionPaywall extends StatefulWidget{
  const SubscriptionPaywall({super.key, this.popupUpOnSubscription = false});
  final bool popupUpOnSubscription;
  @override
  State<SubscriptionPaywall> createState() => _SubscriptionPaywallState();
}

class _SubscriptionPaywallState extends State<SubscriptionPaywall> {
  bool _isLoadingPackages = false;
  Package? selectedPackage;

  final List<Package> _availablePackages = [];
  bool _subscriptionLoading = false;
  @override
  void initState() {
    _initPackages();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  _isLoadingPackages
        ? const LoadingWidget()
        : Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(15),
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: const TextSpan(
                      children: [
                        TextSpan(text: "Get ", style: TextStyle(fontSize: 28, fontFamily: 'Inter', fontWeight: FontWeight.w500, color: AppColors.darkGreyTextColor)),
                        TextSpan(text: "Hitch+ ", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600,color: AppColors.darkGreyTextColor,  fontFamily: 'Inter')),
                        TextSpan(text: "Why upgrade?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: AppColors.primaryColor, fontFamily: 'Inter'))
                      ]
                  )),
              const SizedBox(height: 20,),
              _buildWhyUpgradeNoteWidget(text: 'Create group chats'),
              const SizedBox(height: 15,),
              _buildWhyUpgradeNoteWidget(text: 'Get access to coaches'),
              const SizedBox(height: 15,),
              _buildWhyUpgradeNoteWidget(text: 'No ads'),
              const SizedBox(height: 15,),
              _buildWhyUpgradeNoteWidget(text: 'Filter players by distance, level, match type & gender'),
              const SizedBox(height: 15,),
              _buildWhyUpgradeNoteWidget(text: 'Post your own local event(s)'),
              const SizedBox(height: 30,),
              _buildPackageWidget(isMonthly: true),
              const SizedBox(height: 10,),
              _buildPackageWidget(),
              const SizedBox(height: 30,),

              SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 10), child: Column(
                children: [
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          children: [
                            const TextSpan(text: "Already Purchased Subscription? ", style:  TextStyle(fontSize: 14, color:  AppColors.greyTextColor, fontFamily: 'Inter'),),
                            TextSpan(
                              recognizer: TapGestureRecognizer()..onTap = ()=> InAppPurchaseConfig.onRestorePurchaseTap(context: context),
                              text: "Restore Purchase ", style:  const TextStyle(fontSize: 14,  color: Colors.black, fontFamily: 'Inter', decoration: TextDecoration.underline,),)
                          ]
                      )),
                  const SizedBox(height: 10,),
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          children: [
                            const TextSpan(text: "By purchasing Hitch subscription, you accept our ", style:  TextStyle(fontSize: 14, color: AppColors.greyTextColor, fontFamily: 'Inter'),),
                            TextSpan(
                              recognizer: TapGestureRecognizer()..onTap = ()=> Utils.launchAppUrl(url: termsOfUseUrl),
                              text: "Terms of use (EULA) ", style:  const TextStyle(fontSize: 14,  color: Colors.black, fontFamily: 'Inter', decoration: TextDecoration.underline,),),
                            const TextSpan(text: "and ", style:  TextStyle(fontSize: 14, color:  AppColors.greyTextColor, fontFamily: 'Inter'),),
                            TextSpan(
                              recognizer: TapGestureRecognizer()..onTap = ()=> Utils.launchAppUrl(url: privacyPolicyUrl),
                              text: "Privacy Policy", style:  const TextStyle(fontSize: 14,  color: Colors.black, fontFamily: 'Inter', decoration: TextDecoration.underline,),),

                          ]
                      )),


                  const SizedBox(height: 20,),
                ],
              ),),
            ],
                  ),
                ),
            if(_subscriptionLoading)
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black45,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingWidget(color: Colors.white,),
                    Text("Subscription Loading...", style: TextStyle(fontSize: 20, color: Colors.white),)
                  ],
                )
              )
          ],
        );
  }

  Row _buildWhyUpgradeNoteWidget({required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(AppIcons.icPickleBallMap, height: 20,),
        const SizedBox(width: 10,),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 18, color: AppColors.darkGreyTextColor, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),))
      ],
    );
  }

  Widget _buildPackageWidget({bool isMonthly = false}){
    return GestureDetector(
      onTap: ()=> _onPurchasePackageTap(isMonthly: isMonthly,),
      child: Container(
        width: double.infinity,
        // margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            boxShadow:  [
              BoxShadow(
                  color: Colors.grey[300]!,
                  blurRadius: 20
              )
            ],
            borderRadius: BorderRadius.circular(99)
        ),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99)
          ),
          child:  Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: isMonthly
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(text: const  TextSpan(
                      children: [
                        TextSpan(text:  "Monthly ", style: TextStyle(fontSize: 20, fontFamily: 'Inter', color: AppColors.primaryColor, fontWeight: FontWeight.w600)),
                        TextSpan(text: "Hitch+", style: TextStyle(fontSize: 20, fontFamily: 'Inter', color: AppColors.darkGreyTextColor, fontWeight: FontWeight.w600)),
                      ]
                  )),
                  const SizedBox(height: 5,),
                  Text('${_getMonthlyPackage.storeProduct.priceString}/m (cancel anytime)', style: const TextStyle(fontSize: 17, fontStyle: FontStyle.italic),),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(text: const  TextSpan(
                      children: [
                        TextSpan(text:  "Annual ", style: TextStyle(fontSize: 20, fontFamily: 'Inter', color: AppColors.primaryColor, fontWeight: FontWeight.w600)),
                        TextSpan(text: "Hitch+ Best Value", style: TextStyle(fontSize: 20, fontFamily: 'Inter', color: AppColors.darkGreyTextColor, fontWeight: FontWeight.w600)),
                      ]
                  )),
                  const SizedBox(height: 5,),
                  Text('${_getAnnualPackage.storeProduct.priceString}/yr (save \$5)', style: const TextStyle(fontSize: 17, fontStyle: FontStyle.italic),)

                ],
              )
          ),
        ),
      ),
    );
  }

  Package get _getMonthlyPackage {
    return _availablePackages.firstWhere((package)=> package.packageType == PackageType.monthly);
  }

  Package get _getAnnualPackage {
    return _availablePackages.firstWhere((package)=> package.packageType == PackageType.annual);
  }

  void _initPackages() async{
    setState(()=> _isLoadingPackages = true);

    try{
      Package sevenDaysPackage =await InAppPurchaseConfig.get7DaysPackage();
      List<Package> subscriptionPackages = await InAppPurchaseConfig.getSubscriptionPackages();
      _availablePackages.add(sevenDaysPackage);

      _availablePackages.addAll(subscriptionPackages);
    }catch(e){
      debugPrint("Exception while fetching packages: ${e.toString()}");
    }
    setState(()=> _isLoadingPackages = false);
  }

  Future<void> _onPurchasePackageTap({required bool isMonthly}) async {
    setState(()=> _subscriptionLoading = true);
    Package package = isMonthly ? _getMonthlyPackage : _getAnnualPackage;
    try{
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      if(customerInfo.activeSubscriptions.isNotEmpty){
        //Update Subscription Provider
        _updateProvider(customerInfo);
      }
      if(widget.popupUpOnSubscription){
        _onPopup();
      }
    }catch(e){
      String errorMessage =  e.toString();
      if(e is PlatformException){
        errorMessage = e.message!;
      }
      Utils.showCopyToastMessage(message: errorMessage);
    }
    setState(()=> _subscriptionLoading = false);
  }

  void _onPopup() {
    Navigator.of(context).pop();
  }

  void _updateProvider(CustomerInfo customerInfo) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    subscriptionProvider.subscribe();
  }
}