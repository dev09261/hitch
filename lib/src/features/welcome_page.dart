/*
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hitch/src/bloc_cubit/user_info_cubit/user_info_cubit.dart';
import 'package:hitch/src/features/authentication/create_your_player_card.dart';
import 'package:hitch/src/features/authentication/sign_in_with_accounts_page.dart';
import 'package:hitch/src/features/permissions_page.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_icons.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/widgets/primary_btn.dart';

import '../widgets/loading_widget.dart';

class WelcomePage extends StatelessWidget{
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = BlocProvider.of<UserInfoCubit>(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
              onTap: ()=> _navigateToSignupPage(context),

              child: Image.asset(AppIcons.landingPageImg, fit: BoxFit.fitWidth, width: double.infinity,)),
          Platform.isIOS
              ? Padding(
            padding: const EdgeInsets.only(bottom: 20.0, left: 8, right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Already have an account?", style: AppTextStyles.pageHeadingStyle.copyWith(color: Colors.white),),
                const SizedBox(height: 10,),
                BlocConsumer<UserInfoCubit, UserInfoStates>(
                    listener: (context, state){
                      if(state is GoogleSignedUp || state is AppleSignedUp){
                        late UserCredential userCredential;
                        late String userName;
                        late String email;
                        late String userID;
                        if(state is GoogleSignedUp){
                          userCredential = state.user;
                          userName = userCredential.user!.displayName?? '';
                          email = userCredential.user!.email ?? '';
                          userID = userCredential.user!.uid;
                        }
                        if(state is AppleSignedUp){
                          userName = state.userName;
                          email = state.email;
                          userID = state.userID;
                        }
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => CreateYourPlayerCard(
                              name: userName,
                              email: email,
                              comingFromSignup: true,
                              userID: userID,
                            )));
                      }else if(state is GoogleSignedIn || state is AppleSignedIn){
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> const PermissionsPage()), (route)=> false);
                      }else if(state is UserNotFoundInDB){
                        String userName = state.userName;
                        String email = state.email;
                        String userID = state.userID;
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> CreateYourPlayerCard(name: userName, email: email ,comingFromSignup: true, userID: userID)));
                      }
                    },
                    builder: (context,state) {

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSocialLoginWidget(icon: AppIcons.icApple, onTap: (){
                                authCubit.onAppleSignInTap();
                              }, isApple: true, isLoading: state is AppleSigningIn),
                            ),
                            const SizedBox(width: 10,),
                            Expanded(child: _buildSocialLoginWidget(icon: AppIcons.icGoogle, onTap: ()=> authCubit.onGoogleSignInTap(),isLoading: state is GoogleSigningIn,)),

                          ],
                        ),
                      );
                    }

                )],
            ),
          )
              : Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PrimaryBtn(
              btnText: "Let's Get Started",
              onTap: ()=> _navigateToSignupPage(context),
              bgColor: Colors.white,
              textColor: AppColors.textPrimaryColor,
            ),
          )
        ],
      )
    );
  }

  Widget _buildSocialLoginWidget({required VoidCallback onTap, required bool isLoading, required String icon, bool isApple = false}){
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.white,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
            // border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(5)
        ),
        child: InkWell(
          onTap: onTap,
          child: isLoading ? const LoadingWidget() : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(icon, height: 15 ),
              const SizedBox(width: 4,) ,
              isApple ?
              _buildSignInWithApple()
                  : _buildSignInWithGoogle()
            ],
          ),
        ),
      ),
    );
  }

  RichText _buildSignInWithGoogle(){
    return RichText(
        text:  const TextSpan(
            children: [
              TextSpan(
                  text: "Continue with ",
                  style: TextStyle(fontSize: 11 ,  fontFamily: 'Inter', color: Colors.black)
              ),
              TextSpan(
                  text: "Google",
                  style: TextStyle(fontSize:11 , fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Colors.black)
              )
            ]
        ));
  }

  RichText _buildSignInWithApple(){
    return RichText(text:  const TextSpan(
        children: [
          TextSpan(
              text: "Continue with ",
              style: TextStyle(fontSize: 12 ,  fontFamily: 'Inter', color: Colors.black)
          ),
          TextSpan(
              text: "Apple",
              style: TextStyle(fontSize: 12 ,  fontFamily: 'Inter', color: Colors.black, fontWeight: FontWeight.w700,)
          )
        ]
    ));
  }


  void _navigateToSignupPage(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (ctx) =>
            const SignInWithAccountsPage()));
  }
}*/
