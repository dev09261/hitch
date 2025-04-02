import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitch/src/bloc_cubit/user_info_cubit/user_info_cubit.dart';
import 'package:hitch/src/data/app_data.dart';
import 'package:hitch/src/features/permissions_page.dart';
import 'package:hitch/src/models/coach_experience_model.dart';
import 'package:hitch/src/models/player_level_model.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_icons.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:hitch/src/widgets/coach_experience_dropdown_textfield_widget.dart';
import 'package:hitch/src/widgets/dropdown_textfield_widget.dart';
import 'package:hitch/src/widgets/primary_btn.dart';
import 'package:image_picker/image_picker.dart';
import '../../res/string_constants.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/disclosure_text_widget.dart';
import '../../widgets/hitch_checkbox.dart';
import '../../widgets/secondary_btn.dart';
import 'tell_us_more_page.dart';

class CreateYourPlayerCard extends StatefulWidget{
  const CreateYourPlayerCard({super.key, this.comingFromSignup = false, this.email = '', this.name = '', this.userID = ''});
  final bool comingFromSignup;
  final String name;
  final String email;
  final String userID;
  @override
  State<CreateYourPlayerCard> createState() => _CreateYourPlayerCardState();
}

class _CreateYourPlayerCardState extends State<CreateYourPlayerCard> {

  late TextEditingController _fullNameController;
  late TextEditingController _bioTextController;
  File? _selectedImageFile;

  bool _isGoogleSignup = false;
  String _userID = '';
  // String _userEmail = '';


  late String _pickleBallPlayerText;
  late String _tennisBallPlayerText;
  late String _coachText;

  bool _playerTypePickleBal = false;
  bool _playerTypeTennis = false;
  bool _playerTypeCoach= false;

  PlayerLevelModel? _selectedPickleBallPlayerLevel;
  PlayerLevelModel? _selectedTennisBallPlayerLevel;
  CoachExperienceModel? _selectedCoachPickleBallExperienceModel;
  CoachExperienceModel? _selectedCoachTennisExperienceModel;


  late List<PlayerLevelModel> _pickleBallPlayerLevels;
  late List<PlayerLevelModel> _tennisBallPlayersLevels;
  late List<CoachExperienceModel> _coachPickleBallExperienceList;
  late List<CoachExperienceModel> _coachTennisExperienceList;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _bioTextController = TextEditingController();

    _pickleBallPlayerText = playerTypePickleBallValue;
    _tennisBallPlayerText = playerTypeTennisValue;
    _coachText = playerTypeCoachValue;

    _pickleBallPlayerLevels = AppData.getPickleBallPlayerLevels;
    _tennisBallPlayersLevels = AppData.getTennisBallPlayerLevels;
    _coachPickleBallExperienceList = AppData.getCoachPickleBallExperienceList;
    _coachTennisExperienceList = AppData.getCoachTennisBallExperienceList;

    if(widget.comingFromSignup){
      _fullNameController.text = widget.name;
      _userID = widget.userID;
      _isGoogleSignup = true;
    }

  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioTextController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              // padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: BlocConsumer<UserInfoCubit, UserInfoStates>(

                builder: (ctx, state){
                  return SizedBox(
                    height: size.height*0.9,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10), child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const  Padding(
                                padding:  EdgeInsets.only(top: 50.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text('Create Your Player Card', style: AppTextStyles.pageHeadingStyle, textAlign: TextAlign.center,),
                                ),
                              ),
                              const SizedBox(height: 50,),
                              _selectedImageFile != null
                                  ? GestureDetector(
                                  onTap: _onPickImageTap,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: MemoryImage(_selectedImageFile!.readAsBytesSync()),
                                      ),
                                      const SizedBox(width: 5,),
                                      const Text("Profile Photo", style: TextStyle(fontSize: 17, color: AppColors.greyTextColor, fontWeight: FontWeight.w400),
                                      )
                                    ],
                                  ))
                                  : GestureDetector(
                                onTap: _onPickImageTap,
                                child: Row(
                                  children: [
                                    Image.asset(AppIcons.icAddProfile, height: 45,),
                                    const SizedBox(width: 5,),
                                    const Text("Add a player profile (optional)", style: TextStyle(fontSize: 17, color: AppColors.greyTextColor, fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 35,),
                              AppTextField(textEditingController: _fullNameController, hintText: "Full Name", onTextChange: onTextChange,),
                              const SizedBox(height: 35,),
                              AppTextField(textEditingController: _bioTextController, hintText: "Tell your story (player bio)", onTextChange: onTextChange,),
                              const SizedBox(height: 35,),
                              const Text("Player type", style: AppTextStyles.regularTextStyle,),
                            ],
                          ),),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                      
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex:4,
                                        child: HitchCheckbox(text: _pickleBallPlayerText, onChange: _onPlayerTypePickleChange, value: (_playerTypePickleBal  && !_playerTypeCoach))
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: HitchCheckbox(text: _tennisBallPlayerText, onChange: _onPlayerTypeTennisChange, value: (_playerTypeTennis && !_playerTypeCoach))
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: HitchCheckbox(text: _coachText, onChange: _onPlayerTypeCoachChange, value: _playerTypeCoach)
                      
                                    ),
                                  ],
                                ),
                              ),
                      
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                child: Column(
                                  children: [
                                    if(_playerTypePickleBal)
                                      PlayerLevelDropdownTextfieldWidget(
                                        isEmpty: _selectedPickleBallPlayerLevel == null,
                                        selectedValue: _selectedPickleBallPlayerLevel,
                                        onChanged: (newValue)=> setState(()=> _selectedPickleBallPlayerLevel = newValue),
                                        playerLevels: _pickleBallPlayerLevels,
                                        width: size.width*0.8,
                                        hintText: 'Select Pickleball level (DUPR)',
                                      ),


                                    if(_playerTypeTennis)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 30.0,),
                                        child: PlayerLevelDropdownTextfieldWidget(
                                          isEmpty: _selectedTennisBallPlayerLevel == null,
                                          selectedValue: _selectedTennisBallPlayerLevel,
                                          onChanged: (newValue)=> setState(()=> _selectedTennisBallPlayerLevel = newValue),
                                          playerLevels: _tennisBallPlayersLevels,
                                          width: size.width*0.8,
                                          hintText: 'Select Tennis level (UTR)',
                                        ),
                                      ),
                      
                                    if(_playerTypeCoach)
                                      Column(
                                        children: [
                                          CoachExperienceLevelsDropDownWidget(
                                              isEmpty: _selectedCoachPickleBallExperienceModel == null,
                                              selectedValue: _selectedCoachPickleBallExperienceModel,
                                              onChanged: (val)=> setState(()=> _selectedCoachPickleBallExperienceModel = val),
                                              experienceLevels: _coachPickleBallExperienceList,
                                              width: size.width*0.8,
                                              hintText: 'Select years of coaching (DUPR)'),


                                          const SizedBox(height: 20,),
                                          CoachExperienceLevelsDropDownWidget(
                                              isEmpty: _selectedCoachTennisExperienceModel == null,
                                              selectedValue: _selectedCoachTennisExperienceModel,
                                              onChanged: (val)=> setState(()=> _selectedCoachTennisExperienceModel = val),
                                              experienceLevels: _coachTennisExperienceList,
                                              width: size.width*0.8,
                                              hintText: 'Select years of coaching (UTR)'),

                                        ],
                                      ),
                                    const SizedBox(height: 20,),
                                    const DisclosureTextWidget(),
                                    const SizedBox(height: 20,)
                                  ],
                                ),
                              )
                      
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
                listener: (ctx, state){
                  if(state is GoogleSignedUp){
                    UserCredential user = state.user;
                    _fullNameController.text = user.user?.displayName ?? '';
                    _userID = user.user!.uid;
                    _isGoogleSignup = true;
                  }else if(state is GoogleSignedIn){
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> const PermissionsPage()), (route)=> false);
                  }
                },
              )
            ),

            Positioned(
              right: size.width*0.3,
              left: size.width*0.3,
              bottom: 10,
              // alignment: Alignment.bottomCenter,
              child: isReadyToContinue
                  ? PrimaryBtn(
                  btnText: "Continue",
                  onTap: _onContinueTap)
                  : SecondaryBtn(
                  btnText: "Continue", onTap: () {
                String userName = _fullNameController.text.trim();
                String bioText = _bioTextController.text.trim();
                bool isPlayerTypeSelected = _playerTypeTennis || _playerTypePickleBal || _playerTypeCoach;
                if(userName.isEmpty){
                  Utils.showCopyToastMessage(message: 'Please enter your name to proceed.');
                }else if(bioText.isEmpty){
                  Utils.showCopyToastMessage(message: 'Please tell us about yourself in bio to proceed');
                }else if(!isPlayerTypeSelected){
                  Utils.showCopyToastMessage(message: 'Please select the player type to proceed.');
                }else{
                  Utils.showCopyToastMessage(message: 'Please complete all required fields to proceed');
                }
              }),
            ),

          ],
        ),
      ),
    );
  }

  void _onPlayerTypePickleChange(bool? value) {
    _playerTypePickleBal = value!;
    if(_playerTypeCoach){
      _playerTypeCoach = false;
    }
    setState(() {});
  }

  void _onPlayerTypeTennisChange(bool? value) {
    _playerTypeTennis = value!;
    if(_playerTypeCoach){
      _playerTypeCoach = false;
    }
    setState(() {});
  }

  void _onPlayerTypeCoachChange(bool? value) {
    _playerTypeCoach = value!;
    _playerTypeTennis = false;
    _playerTypePickleBal = false;
    setState((){});
  }

  void onTextChange(String text){
    setState(() {});
  }
  void _onPickImageTap() async{
    try{
      XFile? imageFile =  await ImagePicker().pickImage(source: ImageSource.gallery);
      if(imageFile != null){
        _selectedImageFile = File(imageFile.path);
        setState(() {});
      }
    }catch(e) {
      if (e is PlatformException) {
        if (e.code == 'photo_access_denied') {
          _showErrorSnackBar(photosPermissionDescription);
        }
      }
    }
  }

  get isReadyToContinue {
    // bool isImageSelected = selectedImageFile != null;
    bool isNameAdded = _fullNameController.text.trim().isNotEmpty;
    // bool isBioAdded = _bioTextController.text.isNotEmpty;
    bool isPlayerSelected = (_playerTypeTennis || _playerTypePickleBal || _playerTypeCoach);

    return (isPlayerSelected && isNameAdded);
  }

  void _onContinueTap(){
    String? imagePath = _selectedImageFile?.path;
    String fullName = _fullNameController.text.trim();
    String bio = _bioTextController.text.trim();
    String email = widget.email;


    Map<String, dynamic> userMap = {
      userNameKey: fullName,
      profileKey : imagePath,
      bioKey: bio,
      emailAddressKey: email,
      playerTypePickleKey: _playerTypePickleBal,
      playerTypeTennisKey: _playerTypeTennis,
      playerTypeCoachKey: _playerTypeCoach,
      pickleBallPlayerLevelKey: _selectedPickleBallPlayerLevel,
      tennisBallPlayerLevelKey : _selectedTennisBallPlayerLevel,
      coachTennisExperienceLevelKey: _selectedCoachTennisExperienceModel,
      coachPickleBallExperienceLevelKey: _selectedCoachPickleBallExperienceModel,
      // levelKey: selectedLevel['level'],
      userIDKey : _userID
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> TellUsMorePage(userAboutInfo: userMap, isGoogleSignup: _isGoogleSignup,)));
  }

  void _showErrorSnackBar(String photosPermissionDescription) {
    Utils.showPermissionRequestDialog(context, photosPermissionDescription);
  }
}