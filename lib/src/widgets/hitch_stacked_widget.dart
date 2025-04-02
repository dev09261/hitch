import 'package:flutter/material.dart';

import '../res/app_icons.dart';

class HitchStackedWidget extends StatelessWidget {
  const HitchStackedWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 170,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(15)
              ),
            ),
          ),
          SizedBox(
            width: 200,
            height: 190,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(15)
              ),
            ),
          ),
          SizedBox(
            width: 180,
            height: 210,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(15)
              ),
            ),
          ),
          const CircleAvatar(
            radius: 65,
            backgroundImage: AssetImage(AppIcons.icPremiumUserMockup),
          ),
          Image.asset(AppIcons.icHitchLogo, height: 30,)
        ],
      ),);
  }
}