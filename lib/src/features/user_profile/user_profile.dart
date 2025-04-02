import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/features/authentication/sign_in_with_accounts_page.dart';
import 'package:hitch/src/features/in_app_purchase/in_app_purchase_config.dart';
import 'package:hitch/src/models/uploaded_file_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/providers/logged_in_user_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/widgets/app_textfield.dart';
import 'package:hitch/src/widgets/availability_switch.dart';
import 'package:hitch/src/widgets/coach_experience_dropdown_textfield_widget.dart';
import 'package:hitch/src/widgets/dropdown_textfield_widget.dart';
import 'package:hitch/src/widgets/hitch_profile_image.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:hitch/src/widgets/match_gendertype_widget.dart';
import 'package:hitch/src/widgets/pick_sport_videos_photos_widget.dart';
import 'package:hitch/src/widgets/picked_sport_videos_photos_widget.dart';
import 'package:hitch/src/widgets/selectable_available_days_widget.dart';
import 'package:hitch/src/utils/show_dialogs.dart';
import 'package:hitch/src/widgets/sports_photos_videos_view_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../models/coach_experience_model.dart';
import '../../models/player_level_model.dart';
import '../../res/string_constants.dart';
import '../../widgets/hitch_checkbox.dart';
import '../../widgets/player_hitches_count_widget.dart';

class UserProfile extends StatefulWidget{
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late TextEditingController _fullNameController;
  late TextEditingController _ageController;
  late TextEditingController _experienceController;

  late TextEditingController _bioController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  late LoggedInUserProvider _loggedInUserProvider;
  bool _loadingUserInfo = false;
  bool _isErrorOccurred = false;
  UserModel? user;

  String? updatedImagePath;

  bool _canPop = false;

  bool playerTypePickleBal = false;
  bool playerTypeTennis = false;
  bool playerTypeCoach= false;

  PlayerLevelModel? _selectedPickleBallPlayerLevel;
  PlayerLevelModel? _selectedTennisBallPlayerLevel;
  CoachExperienceModel? _selectedCoachPickleBallExperienceModel;
  CoachExperienceModel? _selectedCoachTennisExperienceModel;


  late List<PlayerLevelModel> _pickleBallPlayerLevels;
  late List<PlayerLevelModel> _tennisBallPlayersLevels;
  late List<CoachExperienceModel> _coachPickleBallExperienceList;
  late List<CoachExperienceModel> _coachTennisExperienceList;

  bool _isAvailableDaily = true;
  bool _isAvailableInMorning = true;

  late List<Map<String, dynamic>> daysAvailable;
  late List<String> _matchTypeList;
  late List<String> _genderList;

  String _selectedMatchType = '';
  String _selectedGenderType = '';

  final userAuthService = UserAuthService.instance;
  late List<XFile> _newlyUploadedFiles;
  late List<String> _userUploadedSportsVideos;
  bool changesAreUpdating = false;

  @override
  void initState() {
    super.initState();
    _pickleBallPlayerLevels = AppData.getPickleBallPlayerLevels;
    _tennisBallPlayersLevels = AppData.getTennisBallPlayerLevels;
    _coachPickleBallExperienceList = AppData.getCoachPickleBallExperienceList;
    _coachTennisExperienceList = AppData.getCoachTennisBallExperienceList;
    daysAvailable = AppData.daysAvailable;
    _newlyUploadedFiles = [];
    _userUploadedSportsVideos = [];
    _matchTypeList = [
      'Both', 'Doubles', 'Singles'
    ];
    _genderList = [
      'Both', 'Males', 'Females'
    ];
    _initUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loggedInUserProvider = Provider.of<LoggedInUserProvider>(context);
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: _canPop,
      onPopInvoked: (didPop) {
        onPopup();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(onPressed: ()async{
            await checkForChanges();
            _onPopup();
          }, icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryColor,)),
          title: const Text("Profile", style: AppTextStyles.pageHeadingStyle),
          centerTitle: true,
          scrolledUnderElevation: 0,
          backgroundColor: changesAreUpdating ? Colors.black54 :  Colors.white,
        ),
        body: SafeArea(
          child:  Stack(
            children: [
              _loadingUserInfo
                  ? const LoadingWidget()
                  : _isErrorOccurred ? const Center(child: Text("Failed to get user information, Try again !", textAlign: TextAlign.center, style: AppTextStyles.subHeadingTextStyle,),)
                  : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _onPickProfileImageTap,
                        child: updatedImagePath != null ?
                        HitchProfileImage(profileUrl: updatedImagePath!, isLocalImage: true, size: 75)
                            : HitchProfileImage(
                          profileUrl: user!.profilePicture,
                          size: 75,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5,),
                    Center(child: PlayerHitchesCountWidget(userID: FirebaseAuth.instance.currentUser!.uid,)),
                    const SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Recent video and photos", style: AppTextStyles.textFieldHeadingStyle.copyWith(fontWeight: FontWeight.w600),),
                          const SizedBox(height: 8,),
                          _userUploadedSportsVideos.isEmpty
                              ? PickSportVideosPhotosWidget(onPickSportPhotosAndVideos: _onPickSportPhotosAndVideos)
                              : PickedSportVideosPhotosWidget(pickedFiles: _userUploadedSportsVideos, onPickSportVideos: _onPickSportPhotosAndVideos, onPhotosTap: (index){
                                Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> SportsPhotosVideosViewPage(uploadedFilesUrls: _userUploadedSportsVideos, selectedIndex: index)));
                          },),
                          const SizedBox(height: 20,),
                          AppTextField(textEditingController: _fullNameController, hintText: 'Name',),

                          if(!playerTypeCoach)
                            AppTextField(
                              textEditingController: _ageController,
                              hintText: 'Age  ',
                            ),
                          const SizedBox(height: 30,),
                          Text("Player Type", style: AppTextStyles.regularTextStyle.copyWith(fontWeight: FontWeight.w600),),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                              flex:4,
                              child: HitchCheckbox(text: playerTypePickleBallValue, onChange: _onPlayerTypePickleChange, value: playerTypePickleBal && !playerTypeCoach)
                          ),
                          Expanded(
                              flex: 3,
                              child: HitchCheckbox(text: playerTypeTennisValue, onChange: _onPlayerTypeTennisChange, value: playerTypeTennis && !playerTypeCoach)
                          ),
                          Expanded(
                              flex: 3,
                              child: HitchCheckbox(text: playerTypeCoachValue, onChange: _onPlayerTypeCoachChange, value: playerTypeCoach)
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          if(playerTypePickleBal)
                            PlayerLevelDropdownTextfieldWidget(
                                isEmpty: _selectedPickleBallPlayerLevel == null,
                                selectedValue: _selectedPickleBallPlayerLevel,
                                onChanged: (newValue)=> setState(()=> _selectedPickleBallPlayerLevel = newValue),
                                playerLevels: _pickleBallPlayerLevels,
                                width: size.width*0.8,
                              hintText: 'Select Pickleball level (DUPR)',
                            ),

                          if(playerTypeTennis)
                            Padding(
                              padding:  EdgeInsets.only(top: playerTypePickleBal ? 30.0:0,),
                              child: PlayerLevelDropdownTextfieldWidget(
                                  isEmpty: _selectedTennisBallPlayerLevel == null,
                                  selectedValue: _selectedTennisBallPlayerLevel,
                                  onChanged: (newValue)=> setState(()=> _selectedTennisBallPlayerLevel = newValue),
                                  playerLevels: _tennisBallPlayersLevels,
                                  width: size.width*0.8,
                                hintText: 'Select Tennis level (UTR)',
                              ),
                            ),

                          if(playerTypeCoach)
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

                          const SizedBox(height: 30,),
                          AppTextField(textEditingController: _bioController, hintText: 'Bio  ',),
                          const SizedBox(height: 30,),
                          AppTextField(textEditingController: _contactNumberController, hintText: 'Contact Number  ', textInputNumber: true,),
                          const SizedBox(height: 30,),
                          AppTextField(textEditingController: _emailController, hintText: 'Email  ', ),
                          const SizedBox(height: 30,),
                          const Align(
                              alignment: Alignment.topLeft,
                              child: Text('Availability', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headingColor),),
                           ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: AvailabilitySwitch(
                          onEveryDayChange: (val)=> setState(()=> _isAvailableDaily = val),
                          onMorningChange: (val)=> setState(()=> _isAvailableInMorning = val),
                          isAvailableDay: _isAvailableDaily,
                          isAvailableInMorning: _isAvailableInMorning),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(!_isAvailableDaily)
                            SelectableAvailableDaysWidget(daysAvailable: daysAvailable, onTap: (index)=> setState(()=> daysAvailable[index]['isSelected'] = !daysAvailable[index]['isSelected'])),

                          const SizedBox(height: 20,),
                          MatchGendertypeWidget(selectedType: _selectedMatchType, typeList: _matchTypeList, onTap: (index)=> setState(()=> _selectedMatchType = _matchTypeList[index]), headingTitle: 'Match Type'),
                          const SizedBox(height: 20,),
                          MatchGendertypeWidget(selectedType: _selectedGenderType, typeList: _genderList, onTap: (index)=> setState(()=> _selectedGenderType = _genderList[index]), headingTitle: 'Gender'),
                          const SizedBox(height: 20,),

                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                              ),
                              elevation: 2,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  _buildTextButton(text: 'Restore Purchase', icon: Icons.navigate_next_rounded, onTap: ()=> InAppPurchaseConfig.onRestorePurchaseTap(context: context)),
                                  const Divider(),
                                  _buildTextButton(text: 'Logout', icon: Icons.login_rounded, onTap: _onLogoutTap),
                                  const Divider(),
                                  _buildTextButton(text: 'Delete Account', icon: Icons.delete_rounded, onTap: (){
                                    ShowDialogs
                                        .showDeleteAccountDialog(
                                        context: context,
                                        onDeleteTap: _navigateToWelcome);
                                  }),
                                ],
                              ),
                            ),
                          ),
                          /*SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)
                              ),
                              onPressed: ()=> InAppPurchaseConfig.onRestorePurchaseTap(context: context),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Restore Purchase", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),),
                                  Icon(Icons.navigate_next_rounded)
                                ],
                              ),),
                          ),*/
                         /* Padding(
                            padding: const EdgeInsets.only(bottom: 18.0,),
                            child: Card(
                              elevation: 1,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: PrimaryBtn(btnText: "Logout",bgColor: Colors.white,textColor: Colors.black, onTap: ()async{
                                    await FirebaseAuth.instance.signOut();
                                    _navigateToWelcome();
                                  })
                              ),
                            ),
                          ),

                          Align(
                              alignment: Alignment.center,
                                        child: SecondaryBtn(
                                            btnText: "Delete Account",
                                            onTap: () => ShowDialogs
                                                .showDeleteAccountDialog(
                                                    context: context,
                                                    onDeleteTap: _navigateToWelcome)))
                          */

                                  ],
                      ),
                    )
                  ],
                ),
              ),

              if(changesAreUpdating)
                Container(
                  height: double.infinity,
                  color: Colors.black54,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LoadingWidget(),
                      const SizedBox(height: 20,),
                      Text("Changes are updating...", style: AppTextStyles.regularTextStyle.copyWith(color: Colors.white),)
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  TextButton _buildTextButton({required String text, required IconData icon, required VoidCallback onTap}) {
    return TextButton(
        onPressed: onTap,
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            Icon(
              icon,
              color: Colors.black,
            )
          ],
        ));
  }

  void _onPlayerTypePickleChange(bool? value) {
    if(playerTypeCoach){
      playerTypeCoach = false;
    }
    playerTypePickleBal = value!;
    setState((){});
  }

  void _onPlayerTypeTennisChange(bool? value) {
    if(playerTypeCoach){
      playerTypeCoach = false;
    }
    playerTypeTennis = value!;
    setState(() {});
  }

  void _onPlayerTypeCoachChange(bool? value) {
    playerTypeCoach = value!;
    playerTypePickleBal = false;
    playerTypeTennis = false;
    setState((){});
  }

  void _onPickProfileImageTap() async{
    ImagePicker imagePicker = ImagePicker();
    XFile? imageFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if(imageFile != null){
      updatedImagePath = imageFile.path;
      setState(() {});
      String? url = await userAuthService.getProfileUrl(profilePicPath: updatedImagePath!);
      Map<String, dynamic> profileMap = {'profilePicture' : url!};
      userAuthService.updateUserInfo(updatedMap: profileMap);
    }
  }

  void _onPickSportPhotosAndVideos()async{
    final imagePicker = ImagePicker();
    final List<XFile> selectedMedia = await imagePicker.pickMultipleMedia();
    if(selectedMedia.isNotEmpty){
      _newlyUploadedFiles.addAll(selectedMedia);
      List<String> updated= selectedMedia.map((uploaded)=> uploaded.path).toList();
      _userUploadedSportsVideos.addAll(updated);


      // debugPrint("Selected media: ${_userUploadedSportsVideos.length}");
      setState(() {});
    }
  }

  Future<bool> checkForChanges() async{
    setState(() => changesAreUpdating = true);
    bool shouldPop = false;

    String userName = _fullNameController.text.trim();
    String age = _ageController.text.trim();
    String experience = _experienceController.text.trim();
    String bioText = _bioController.text.trim();
    String cellNumber = _contactNumberController.text.trim();
    String email = _emailController.text.trim();
    // String level = selectedLevel['level'];

    String imageUrl =  user!.profilePicture;

    try{
      if(updatedImagePath != null){
        String? updatedUrl = await userAuthService.getProfileUrl(profilePicPath: updatedImagePath!);
        if(updatedUrl != null){
          imageUrl = updatedUrl;
        }
      }

      List<UploadedFileModel> newlyUploadedList = [];
      for (var newlyAdded in _newlyUploadedFiles) {
        String? url = await  userAuthService.uploadFileToDatabase(newlyAdded);
        if(url != null){
          newlyUploadedList.add(UploadedFileModel(fileName: newlyAdded.name, url: url,));
        }
      }
      String token0 = '';
      try{
        String? token = await FirebaseMessaging.instance.getToken();
        if(token != null){
          token0 = token;
        }
      }catch(e){
        debugPrint("Failed to get token: ${e.toString()}");
      }

      if(!playerTypeCoach){
        experience = user!.experience ?? '';
      }


      if(newlyUploadedList.isNotEmpty){
        //update sports videos first
        newlyUploadedList.addAll(user!.uploadedSportsPhotos);
        List<Map<String, dynamic>> uploadedFilesMap = newlyUploadedList.map((uploadedFile)=> uploadedFile.toMap()).toList();

        await userAuthService.updateUserInfo(updatedMap: {uploadedFilesKey: uploadedFilesMap});
      }

      List<String> updatedDays = daysAvailable.where((dayAvailable)=> dayAvailable['isSelected']).toList().map((selectedDay)=> selectedDay['day'].toString()).toList();
      Map<String, dynamic> map = {
        userNameKey: userName,
        'profilePicture': imageUrl,
        playerTypePickleKey: playerTypePickleBal,
        playerTypeTennisKey: playerTypeTennis,
        playerTypeCoachKey: playerTypeCoach,
        bioKey: bioText,
        cellNumberKey: cellNumber,
        emailAddressKey: email,
        'age': age,
        'token': token0,
        experienceKey: experience,
        pickleBallPlayerLevelKey : _selectedPickleBallPlayerLevel?.toMap(),
        tennisBallPlayerLevelKey : _selectedTennisBallPlayerLevel?.toMap(),
        coachTennisExperienceLevelKey: _selectedCoachTennisExperienceModel?.toMap(),
        coachPickleBallExperienceLevelKey: _selectedCoachPickleBallExperienceModel?.toMap(),
        isAvailableInMorningKey : _isAvailableInMorning,
        isAvailableDailyKey : _isAvailableDaily,
        matchTypeKey: _selectedMatchType.isEmpty ? null : _selectedMatchType,
        genderTypeKey: _selectedGenderType.isEmpty ? null : _selectedGenderType,
        availableDaysToPlayKey: updatedDays,
      };

      await userAuthService.updateUserInfo(updatedMap: map);

      UserModel? userModel =  await userAuthService.getCurrentUser();
      if(userModel != null){
        _loggedInUserProvider.setLoggedInUserInfo(userModel);
      }
    }catch(e){
      debugPrint("Exception while updating the user Profile: ${e.toString()}");
    }


    setState(() => changesAreUpdating = false);
    return shouldPop;
  }

  void _initUserInfo() async{
    setState(()=> _loadingUserInfo = true);
    try{
      user = await userAuthService.getCurrentUser();
      if(user != null){

        _fullNameController = TextEditingController(text: user!.userName);
        _ageController = TextEditingController(text: user!.age ?? '');
        _experienceController = TextEditingController(text: user!.experience?? '');

        _bioController = TextEditingController(text: user!.bio);
        _contactNumberController = TextEditingController(text: user!.cellNumber);
        _emailController = TextEditingController(text: user!.emailAddress);
        playerTypePickleBal = user!.playerTypePickle;
        playerTypeTennis = user!.playerTypeTennis;
        playerTypeCoach = user!.playerTypeCoach;
        _isAvailableInMorning = user!.isAvailableInMorning;
        _isAvailableDaily = user!.isAvailableDaily;
        _selectedMatchType = user!.matchType ;
        _selectedGenderType = user!.genderType ;
        _userUploadedSportsVideos = user!.uploadedSportsPhotos.map((uploaded)=> uploaded.url).toList();

        _selectedPickleBallPlayerLevel = user!.pickleBallPlayerLevel;
        _selectedTennisBallPlayerLevel = user!.tennisBallPlayerLevel;
        _selectedCoachPickleBallExperienceModel = user!.coachPickleBallExperienceLevel;
        _selectedCoachTennisExperienceModel = user!.coachTennisBallExperienceLevel;
        daysAvailable = daysAvailable.map((item) {
          if (user!.availableDaysToPlay.contains(item['day'])) {
            item['isSelected'] = true;
          }
          return item;
        }).toList();
      }
    }catch(e){
      _isErrorOccurred = true;
      debugPrint("Failed to get userInfo: ${e.toString()}");
    }
    setState(()=> _loadingUserInfo = false);
  }

  void onPopup() {
    if (_canPop) return;
    WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
        _canPop = await checkForChanges();

        if (_canPop) {
          if (!mounted) return;
          Navigator.of(context).pop();
        }
      },
    );
  }

  void _onPopup() {
    Navigator.of(context).pop();
  }


  void _onLogoutTap() async{
    await FirebaseAuth.instance.signOut();
    _navigateToWelcome();
  }

  void _navigateToWelcome(){
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> const SignInWithAccountsPage()), (route)=> false);
  }
}