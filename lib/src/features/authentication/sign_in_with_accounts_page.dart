import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitch/src/bloc_cubit/user_info_cubit/user_info_cubit.dart';
import 'package:hitch/src/features/authentication/create_your_player_card.dart';
import 'package:hitch/src/features/permissions_page.dart';
import 'package:hitch/src/res/app_icons.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:hitch/src/widgets/social_sign_in_widget.dart';

class SignInWithAccountsPage extends StatelessWidget{
  const SignInWithAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final authCubit = BlocProvider.of<UserInfoCubit>(context);
    bool isAndroid = Platform.isAndroid;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          Image.asset(AppIcons.landingPageImg, width: size.width, fit: BoxFit.cover,),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
                child:  isAndroid ?  Text('Get Started with An Account',  style: AppTextStyles.pageHeadingStyle.copyWith(color: Colors.black), textAlign: TextAlign.center,)
                    :  Text('Let’s Start by\nCreating An Account', style: AppTextStyles.pageHeadingStyle.copyWith(color: Colors.black, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
              ),
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: BlocConsumer<UserInfoCubit, UserInfoStates>(
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
                    }else if(state is SigningUpError){
                      Utils.showTopSnackBar(context, content: Column(
                        children: [
                          const Text('Sign in failed!', style: AppTextStyles.pageHeadingStyle,),
                          const SizedBox(height: 10,),
                          Text(state.errorMessage, style: AppTextStyles.regularTextStyle,),
                        ],
                      ));
                    }
                  },
                  builder: (context,state) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppIcons.signInAccountsPng),

                        const SizedBox(height: 10,),
                        if(Platform.isIOS)
                          SizedBox(
                              width: size.width*0.65,
                              child: SocialSignInWidget(
                                icon: AppIcons.icApple,
                                onTap: ()=> authCubit.onAppleSignInTap(),
                                isApple: true,
                                isLoading: state is AppleSigningIn,
                              )),
                        const SizedBox(height: 20,),
                        if(Platform.isAndroid)
                          SizedBox(
                              width: size.width*0.65,
                              child: SocialSignInWidget(
                            icon: AppIcons.icGoogle,
                            onTap: () => authCubit.onGoogleSignInTap(),
                            isGoogle: true,
                            isLoading: state is GoogleSigningIn,
                          )),

                      ],
                    );
                  }
              )),
          const SizedBox(height: 20,),
        ],
      ),
    );
  }

}