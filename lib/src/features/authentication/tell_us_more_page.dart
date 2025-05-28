import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitch/src/bloc_cubit/user_info_cubit/user_info_cubit.dart';
import 'package:hitch/src/data/app_data.dart';
import 'package:hitch/src/features/authentication/signup_last_step_page.dart';
import 'package:hitch/src/widgets/app_textfield.dart';
import 'package:hitch/src/widgets/primary_btn.dart';
import 'package:hitch/src/utils/show_dialogs.dart';
import '../../res/app_text_styles.dart';
import '../../res/string_constants.dart';
import '../../widgets/disclosure_text_widget.dart';

class TellUsMorePage extends StatefulWidget{
  const TellUsMorePage({super.key, required this.userAboutInfo, required this.isGoogleSignup});
  final Map<String, dynamic> userAboutInfo;
  final bool isGoogleSignup;
  @override
  State<TellUsMorePage> createState() => _TellUsMorePageState();
}

class _TellUsMorePageState extends State<TellUsMorePage> {

  double distanceFromCurrentLocation = 10.0;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _experienceController;

  String pickleBallPlayerText = playerTypePickleBallValue;
  String tennisBallPlayerText = playerTypeTennisValue;
  String coachText = playerTypeCoachValue;

  bool playerTypePickleBal = false;
  bool playerTypeTennis = false;
  bool _playerTypeCoach= false;

  late UserInfoCubit _userInfoCubit;

  Map<String,dynamic> selectedLevel = {};
  late List<String> _genders;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userAboutInfo[emailAddressKey]);
    _ageController = TextEditingController();
    _experienceController = TextEditingController();
    _playerTypeCoach = widget.userAboutInfo[playerTypeCoachKey];
    _genders = AppData.genders;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _ageController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _userInfoCubit = BlocProvider.of<UserInfoCubit>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 20.0),
              child: SizedBox(
                height: size.height*0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                        child: Text("Tell Us More\nAbout Yourself", style: AppTextStyles.pageHeadingStyle, textAlign: TextAlign.center,)
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         /* AppTextField(textEditingController: _emailController, hintText: 'Email', isReadOnly: true,),
                          const SizedBox(height: 30,),*/
                          _playerTypeCoach
                              ? AppTextField(
                                  textEditingController: _experienceController,
                                  hintText: "Years of experience (Optional)",
                                  textInputNumber: true,
                                )
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Do you want to play with people around your age?', style: AppTextStyles.regularTextStyle,),
                                  const SizedBox(height: 10,),
                                  AppTextField(
                                      textEditingController: _ageController,
                                      hintText: "Age (Optional)",
                                      textInputNumber: true,
                                      // textInputNumber: true,
                                    ),
                                ],
                              ),
                          const SizedBox(height: 30,),
                          const Text("What is your gender?", style: AppTextStyles.regularTextStyle,),
                          const SizedBox(height: 10,),
                          FormField<String>(
                            builder: (FormFieldState<String> state) {
                              return InputDecorator(
                                decoration: InputDecoration(
                                  labelStyle: AppTextStyles.regularTextStyle,
                                  hintStyle: AppTextStyles.regularTextStyle.copyWith(color: Colors.grey),
                                  contentPadding: EdgeInsets.zero,
                                  errorStyle: AppTextStyles.regularTextStyle.copyWith(color: Colors.red),
                                  // hintText: 'Please select expense',
                                ),
                                isEmpty: _selectedGender == null,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedGender,
                                    hint: const Text('Select (Optional)'),
                                    isDense: true,
                                    elevation: 0,
                                    dropdownColor: Colors.white,
                                    onChanged: (String? newValue) {
                                      setState(()=> _selectedGender = newValue);
                                    },
                                    items: _genders.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: SizedBox(
                                          width: size.width*0.75,
                                          child: Text(value),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 18.0),
                      child:  DisclosureTextWidget(),
                    ),
                    const Spacer(),

                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: BlocConsumer<UserInfoCubit, UserInfoStates>(
                    listener: (ctx, state){
                      if(state is UpdatedUserInfo){
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> const SignupLastStepPage()));
                        // ShowDialogs.showSuccessBottomSheet(context);
                      }else if(state is UpdatingUserInfoFailed){
                        ShowDialogs.showErrorDialog(context: context, title: "Failed to Create User account", description: "The app was unable to create your account, Please try again later");
                      }
                    },
                    builder: (context, state) {
                      return Align(
                          alignment: Alignment.center,
                          child: PrimaryBtn(btnText: "Continue", onTap: _onContinueTap, isLoading: state is UpdatingUserInfo, )
                      );
                    }
                ))
          ],
        ),
      ),
    );
  }

  void onSliderChange(double value){
    distanceFromCurrentLocation  = value;
  }

  void displaySnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)));
  }


  void _onContinueTap() async{
    String experience = _experienceController.text.trim();
    String age = _ageController.text.trim();

    _userInfoCubit.onUpdateSignupInfoTap(
        userMap: widget.userAboutInfo,
        isComingFromGoogle: widget.isGoogleSignup,
        cellNumber: '',
        experience: experience,
        age: age,
        gender: _selectedGender);
  }
}