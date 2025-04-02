import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitch/src/bloc_cubit/user_info_cubit/user_info_cubit.dart';
import 'package:hitch/src/data/app_data.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/widgets/pick_sport_videos_photos_widget.dart';
import 'package:hitch/src/widgets/picked_sport_videos_photos_widget.dart';
import 'package:hitch/src/widgets/primary_btn.dart';
import 'package:hitch/src/widgets/secondary_btn.dart';
import 'package:image_picker/image_picker.dart';
import '../../res/app_text_styles.dart';
import '../../widgets/availability_switch.dart';
import '../../widgets/match_gendertype_widget.dart';
import '../../widgets/selectable_available_days_widget.dart';
import '../../utils/show_dialogs.dart';

class SignupLastStepPage extends StatefulWidget{
  const SignupLastStepPage({super.key, this.comingForExistingUser = false});
  final bool comingForExistingUser; // Users who have already created account but does not provided the below information
  @override
  State<SignupLastStepPage> createState() => _SignupLastStepPageState();
}

class _SignupLastStepPageState extends State<SignupLastStepPage> {

  bool _isAvailableDaily = true;
  bool _isAvailableInMorning = false;

  late List<Map<String, dynamic>> daysAvailable;
  late List<String> matchTypeList;
  late List<String> genderList;

  String selectedMatchType = 'Both';
  String selectedGenderType = 'Both';
  final List<XFile> _pickedFiles = [];

  @override
  void initState() {
    super.initState();
    daysAvailable = AppData.daysAvailable;
    matchTypeList = [
      'Both', 'Doubles', 'Singles'
    ];
    genderList = [
      'Both', 'Males', 'Females'
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 10), 
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Align(
                    alignment: Alignment.center,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                        child: Text(widget.comingForExistingUser ? "Update Information" : "Last step!", style: AppTextStyles.pageHeadingStyle, textAlign: TextAlign.center,)
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Text("Add your best sport photos & videos", textAlign: TextAlign.center, style: AppTextStyles.regularTextStyle,),
                  const SizedBox(height: 10,),
                  _pickedFiles.isNotEmpty 
                      ? PickedSportVideosPhotosWidget(pickedFiles: _pickedFiles.map((file)=> file.path).toList(), onPickSportVideos: _onPickSportPhotosAndVideos,)
                      : PickSportVideosPhotosWidget(onPickSportPhotosAndVideos: _onPickSportPhotosAndVideos),
                  const SizedBox(height: 30,),
                  const Text('Availability', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headingColor),),
                ],
              ),),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: AvailabilitySwitch(
                    onEveryDayChange: (val)=> setState(()=> _isAvailableDaily = val),
                    onMorningChange: (val)=> setState(()=> _isAvailableInMorning = val),
                    isAvailableDay: _isAvailableDaily,
                    isAvailableInMorning: _isAvailableInMorning),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0,),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(!_isAvailableDaily)
                        SelectableAvailableDaysWidget(daysAvailable: daysAvailable, onTap: (index)=> setState(()=> daysAvailable[index]['isSelected'] = !daysAvailable[index]['isSelected'])),
                
                      const SizedBox(height: 20,),
                      MatchGendertypeWidget(selectedType: selectedMatchType, typeList: matchTypeList, onTap: (index)=> setState(()=> selectedMatchType = matchTypeList[index]), headingTitle: 'Match Type'),
                      const SizedBox(height: 20,),
                      MatchGendertypeWidget(selectedType: selectedGenderType, typeList: genderList, onTap: (index)=> setState(()=> selectedGenderType = genderList[index]), headingTitle: 'Gender'),
                      const Spacer(),
                      Align(
                        alignment: Alignment.center,
                        child: BlocConsumer<UserInfoCubit, UserInfoStates>(
                            listener: (ctx, state){
                              if(state is UserSportsMediaUploaded){
                                ShowDialogs.showSuccessBottomSheet(context);
                              }else if(state is UserSportsMediaUploadingFailed){
                                ShowDialogs.showErrorDialog(context: context, title: "Update Information Failed", description: state.errorMessage);
                              }
                            },
                            builder: (ctx, state) {
                              return SizedBox(
                                width: 150,
                                height: 45,
                                child: isReadyToContinue ? PrimaryBtn(
                                  btnText: "Continue",
                                  onTap: _onContinueTap,
                                  isLoading: state is UserSportsMediaUploading,
                                ) : SecondaryBtn(btnText: "Continue", onTap: (){}),
                              );
                            }
                        ),),
                      const SizedBox(height: 20,)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _onPickSportPhotosAndVideos()async{
    final imagePicker = ImagePicker();
    List<XFile> pickedFiles = await imagePicker.pickMultipleMedia();
    if(pickedFiles.isNotEmpty){
      _pickedFiles.addAll(pickedFiles);
      setState(() {});
    }
  }

  void _onContinueTap(){
    List<String> availableDays = daysAvailable
        .where((day) => day['isSelected'])
        .toList()
        .map((day) => day['day'].toString())
        .toList();
    context.read<UserInfoCubit>().onUploadSportsInfoTap(
        photosVideos: _pickedFiles,
        isAvailableDaily: _isAvailableDaily,
        isAvailableInMorning: _isAvailableInMorning,
        availableDays: availableDays,
        matchType: selectedMatchType,
        genderType: selectedGenderType,);
  }

  get isReadyToContinue {
    return (selectedGenderType.isNotEmpty && selectedMatchType.isNotEmpty);
  }
}