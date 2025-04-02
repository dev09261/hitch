import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/features/permissions_page.dart';
import 'package:hitch/src/providers/logged_in_user_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_icons.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/res/lottie_anims.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:hitch/src/widgets/lottie_anim_widget.dart';
import 'package:provider/provider.dart';

import '../res/string_constants.dart';
import '../widgets/hitch_checkbox.dart';
import '../widgets/primary_btn.dart';

class ShowDialogs {
  static void showErrorDialog({required BuildContext context, required String title, required String description}){
    showDialog(context: context, builder: (ctx){
      return AlertDialog(
        backgroundColor: const Color(0xffF2F2F2).withOpacity(0.8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)
        ),
        content:  Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),),
            const SizedBox(height: 5,),
            Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),),
            const SizedBox(height: 10,),
            const Divider(color: AppColors.greyTextColor,),
          ],
        ),
      );
    });
  }

  static void showDeleteAccountDialog({required BuildContext context, required VoidCallback onDeleteTap}) {
    bool isDeleting = false;
    showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, innerState) {
              return AlertDialog(
                backgroundColor: const Color(0xffF2F2F2).withOpacity(0.8),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Are you sure?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "This will permanently delete your account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      color: AppColors.greyTextColor,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    isDeleting ?
                        const LoadingWidget()
                    : Column(
                      children: [
                        GestureDetector(
                            onTap: ()async{
                              innerState(()=> isDeleting = true);
                              FirebaseAuth auth = FirebaseAuth.instance;
                              if(auth.currentUser != null){
                                try {
                                  // Get the current user
                                  User? user = FirebaseAuth.instance.currentUser;

                                  if (user != null) {
                                    // Delete the user

                                    //1. deleting from auth list
                                    await user.delete();
                                    debugPrint("User deleted, now deleting the document");
                                    //2. delete from firebase user table

                                    //Deleting every hitches document
                                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                        .collection(userCollection)
                                        .doc(user.uid).collection(hitchesCollection).get();

                                for (var doc in querySnapshot.docs) {
                                  await doc.reference.delete();
                                }
                                    //Deleting every contacted Players document
                                    QuerySnapshot contactedPlayersSnapshot = await FirebaseFirestore.instance
                                        .collection(userCollection)
                                        .doc(user.uid).collection(contactedPlayersCollection).get();

                                    for (var doc in contactedPlayersSnapshot.docs) {
                                      await doc.reference.delete();
                                    }

                                    //Deleting user document itself
                                   DocumentSnapshot docSnap = await FirebaseFirestore.instance
                                            .collection(userCollection)
                                            .doc(user.uid).get();
                                    docSnap.reference.delete();

                                        //3. Deleting from users hitch and hitch collection  to be done
                                    debugPrint("Deleting the document, Now going back");
                                    onDeleteTap();
                                    isDeleting = false;
                                  } else {
                                  }
                                } catch (e) {
                                  isDeleting = false;
                                  String errorMessage = e.toString();
                                  if (e is FirebaseAuthException) {
                                    if (e.code == 'requires-recent-login') {
                                      errorMessage = 'The user must re-authenticate before deleting the account';
                                    }
                                  }
                                  Navigator.of(context).pop();
                                  Utils.showCopyToastMessage(message: errorMessage);
                                }
                                innerState((){});
                              }
                            },
                            child: const Text(
                              "Delete Account",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red),
                            )),
                        const Divider(
                          color: AppColors.greyTextColor,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.blueColor),
                            ))
                      ],
                    )
                  ],
                ),
              );
            }
          );
        });
  }

  static void showSuccessBottomSheet(BuildContext context){
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context, builder: (ctx){
      return Padding(
        padding: const EdgeInsets.all(18.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
             const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieAnimWidget(anim: LottieAnims.successAnim),
                SizedBox(height: 10,),
                Text("Congrats! Your account was created successfully.", textAlign: TextAlign.center, style: AppTextStyles.regularTextStyle,),
              ],
            ),
            Center(child: Image.asset(AppIcons.bouncingBallAnim)),
          ],
        ),
      );
    });
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pop(context); // Dismiss the bottom sheet
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=> const PermissionsPage()), (route) =>false);
    });
  }

  static void showGenderDialog(BuildContext context, VoidCallback onPopup){
    showDialog(context: context, builder: (ctx){
      String selectedGender = '';
      bool isUpdating = false;
      return StatefulBuilder(builder: (ctx, innerState){

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20,),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text("Please select your gender", style: AppTextStyles.pageHeadingStyle,),
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: HitchCheckbox(text: 'Male', onChange: (val){
                        if(val!){
                          innerState(()=> selectedGender = 'Male');
                        }else{
                          innerState(()=> selectedGender = 'Female');
                        }
                      }, value: selectedGender == 'Male'),
                    ),

                    Expanded(
                      child: HitchCheckbox(text: 'Female', onChange: (val){
                        if(val!){
                          innerState(()=> selectedGender = 'Female');
                        }else{
                          innerState(()=> selectedGender = 'Male');
                        }
                      }, value: selectedGender == 'Female'),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: SizedBox(
                  width: double.infinity,
                  child: PrimaryBtn(btnText: "Continue", onTap: ()async{
                    if(selectedGender.isNotEmpty){
                      final userAuthService = UserAuthService.instance;
                      LoggedInUserProvider loggedInUserProvider = Provider.of<LoggedInUserProvider>(context, listen: false  );
                      try{
                        await userAuthService.updateUserInfo(updatedMap: {'gender' : selectedGender});
                        loggedInUserProvider.updateUserGender(selectedGender);
                        onPopup();
                      }catch(e){
                        debugPrint("Exception while updating the gender");
                      }
                      innerState(()=> isUpdating = false);
                    }
                  }, isLoading: isUpdating,),
                ),
              )
            ],
          ),
        );
      });
    });
  }
}