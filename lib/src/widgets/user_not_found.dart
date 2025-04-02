import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hitch/src/features/authentication/create_your_player_card.dart';
import 'package:hitch/src/widgets/primary_btn.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class UserNotFoundWidget extends StatefulWidget {
  const UserNotFoundWidget({
    super.key,
  });

  @override
  State<UserNotFoundWidget> createState() => _UserNotFoundWidgetState();
}

class _UserNotFoundWidgetState extends State<UserNotFoundWidget> {
  bool deletingUser = false;
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("User not found. Please log in again or create a new account.", textAlign: TextAlign.center,),
          const SizedBox(height: 20,),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: PrimaryBtn(btnText: "Login", onTap: () async {
              User? user = FirebaseAuth.instance.currentUser;

              bool isGoogle = user!.providerData[0].providerId =='google.com';

              if (isGoogle) {
                // Trigger Google Sign-In
                await _updateGoogleUser(user: user);
              } else {
                await _updateAppleUser(user: user);
                debugPrint('No user is currently signed in.');
              }

              // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> const WelcomePage()), (route)=> false);

            }, isLoading: deletingUser,),
          )
        ],
      ),
    );
  }

  Future<void> _updateGoogleUser({required User user}) async{
    setState(() => deletingUser = true);
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      // Obtain the auth details from the request
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        // Re-authenticate the user
       UserCredential userCredential =  await user.reauthenticateWithCredential(credential);
       String userName = userCredential.user!.displayName ?? '';
       String userEmail = userCredential.user!.email ?? '';
       String userID = userCredential.user!.uid;
       _navigateToPlayerCardPage(userName, userEmail, userID);
      } catch (e) {
        debugPrint('Error during re-authentication or deletion: $e');
      }

      setState(() => deletingUser = false);
    }
  }

  Future<void> _updateAppleUser({required User user}) async{
    setState(() => deletingUser = true);


    // Trigger Apple Sign-In
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    // Create a new credential
    AuthCredential credential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    try {
      // Re-authenticate the user
      UserCredential userCredential = await user.reauthenticateWithCredential(credential);
      String userName = userCredential.user!.displayName ?? '';
      String userEmail = userCredential.user!.email ?? '';
      String userID = userCredential.user!.uid;

      _navigateToPlayerCardPage(userName, userEmail, userID);
    } catch (e) {
      debugPrint('Error during re-authentication or deletion: $e');
    }
    setState(() => deletingUser = false);

  }

  void _navigateToPlayerCardPage(String userName, String userEmail, String userID) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => CreateYourPlayerCard(
          name: userName,
          email: userEmail,
          userID: userID,
          comingFromSignup: true,
        )));
  }
}