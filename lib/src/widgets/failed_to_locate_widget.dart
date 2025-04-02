import 'package:flutter/material.dart';
import 'package:hitch/src/res/lottie_anims.dart';
import 'package:hitch/src/widgets/primary_btn.dart';
import 'lottie_anim_widget.dart';

class FailedToLocateUserWidget extends StatelessWidget {
  const FailedToLocateUserWidget({
    super.key,
    required this.onRefreshTap
  });
  final VoidCallback onRefreshTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LottieAnimWidget(anim: LottieAnims.mapsAnim, repeat: true,),
          const SizedBox(height: 10,),
          const Text("We failed to locate you.\nPlease check your connection and try again.", textAlign: TextAlign.center,),
          const SizedBox(height: 20,),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: PrimaryBtn(btnText: "Refresh", onTap: onRefreshTap),
          )
        ],
      ),
    );
  }
}