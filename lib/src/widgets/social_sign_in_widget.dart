import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hitch/src/widgets/loading_widget.dart';

class SocialSignInWidget extends StatelessWidget{
  final String icon;
  final VoidCallback onTap;
  final bool isGoogle;
  final bool isMicrosoft;
  final bool isApple;
  final bool isLoading;
  final bool isWelcomePage;
  const SocialSignInWidget({super.key, required this.icon, required this.onTap, this.isGoogle= false, this.isApple = false, this.isMicrosoft = false, this.isLoading = false, this.isWelcomePage = false});
  @override
  Widget build(BuildContext context) {

    // debugPrint("isGoogle: $isGoogle, isApple: $isApple, isMicrosoft: $isMicrosoft");
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding:  const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white
        ),
        child:  isLoading ? const LoadingWidget() : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(icon, height: isWelcomePage ? 15 :25,),
              isWelcomePage ? const SizedBox(width: 4,) : const SizedBox(width: 15,),
              isGoogle ?
              _buildSignInWithGoogle()
                  : isApple ? _buildSignInWithApple()
                  : _buildSignInWithMicrosoft(),
            ],
          ),
        ),
    );
  }

  RichText _buildSignInWithGoogle(){
    return RichText(
        text:  TextSpan(
      children: [
        TextSpan(
          text: "Continue with ",
          style: TextStyle(fontSize: isWelcomePage ? 12 :16,  fontFamily: 'Inter', color: Colors.black)
        ),
        TextSpan(
            text: "Google",
            style: TextStyle(fontSize: isWelcomePage ? 12 :16, fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Colors.black)
        )
      ]
    ));
  }

  RichText _buildSignInWithApple(){
    return RichText(text:  TextSpan(
        children: [
          TextSpan(
              text: "Continue with ",
              style: TextStyle(fontSize: isWelcomePage ? 12 :16, fontFamily: 'Inter', color: Colors.black)
          ),
          TextSpan(
              text: "Apple",
              style: TextStyle(fontSize: isWelcomePage ? 12 : 16, fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Colors.black)
          )
        ]
    ));
  }

  RichText _buildSignInWithMicrosoft(){
    return RichText(text: const TextSpan(
        children: [
          TextSpan(
              text: "Continue with ",
              style: TextStyle(fontSize: 16, fontFamily: 'Inter', color: Colors.black)
          ),
          TextSpan(
              text: "Microsoft",
              style: TextStyle(fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Colors.black)
          )
        ]
    ));
  }

}