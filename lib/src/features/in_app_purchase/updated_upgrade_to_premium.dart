import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';
import '../../res/app_text_styles.dart';
import '../../widgets/hitch_stacked_widget.dart';

class UpdatedUpgradeToPremium extends StatefulWidget{
  const UpdatedUpgradeToPremium({super.key});

  @override
  State<UpdatedUpgradeToPremium> createState() => _UpdatedUpgradeToPremiumState();
}

class _UpdatedUpgradeToPremiumState extends State<UpdatedUpgradeToPremium> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
             SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: SizedBox(
                                child: Text("Upgrade to continue connecting with players",maxLines: 4, style: AppTextStyles.pageHeadingStyle, textAlign: TextAlign.center,))),
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryColor,)),
                        ),
                      ],
                    ),
                  ),
                  const HitchStackedWidget(),
                  const SizedBox(height: 20,),
                  // const SubscriptionPaywall(popupUpOnSubscription: true,)
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }


}



