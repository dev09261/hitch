import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hitch/src/models/event_model.dart';
import 'package:hitch/src/providers/logged_in_user_provider.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/event_service.dart';
import 'package:hitch/src/widgets/app_textfield.dart';
import 'package:hitch/src/widgets/hitch_checkbox.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../res/app_colors.dart';
import '../../../res/app_icons.dart';
import '../../../res/app_text_styles.dart';
import '../../../utils/utils.dart';
import '../../../widgets/primary_btn.dart';
import '../../../widgets/secondary_btn.dart';

class AddEventPage extends StatefulWidget{
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  late TextEditingController _eventUrlController;
  XFile? _userUploadedEventImg;

  DateTime? eventDate;
  String selectedEvent = '';

  bool _creatingEvent = false;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _dateController = TextEditingController();
    _descriptionController = TextEditingController();
    _eventUrlController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _eventUrlController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Add Event', style: AppTextStyles.pageHeadingStyle,),
        leading: IconButton(onPressed: ()=> Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryColor,)),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 25,
            children: [
              AppTextField(textEditingController: _titleController, hintText: 'Title'),
              const SizedBox(height: 15,),
              _buildUploadImageWidget(),
              const SizedBox(height: 15,),
              AppTextField(textEditingController: _dateController, hintText: 'Date', isDatePicker: true, onEventDateChange: (dateTime){
                eventDate = dateTime;
              },),
              AppTextField(textEditingController: _descriptionController, hintText: 'Description'),
              AppTextField(textEditingController: _eventUrlController, hintText: 'URL (Optional)'),
              Row(
                children: [
                  Expanded(
                    child: HitchCheckbox(text: "Everyone (30mi)", onChange: (val){
                      if(val!){
                        setState(() =>  selectedEvent = eventTypeEveryone);
                      }
                    }, value: selectedEvent ==  eventTypeEveryone),
                  ),
                  const SizedBox(width: 20,),
                  Expanded(
                    child: HitchCheckbox(text: "My Hitches", onChange: (val){
                      if(val!){
                        setState(() =>  selectedEvent = eventTypeHitchesOnly);
                      }
                    }, value: selectedEvent ==  eventTypeHitchesOnly),
                  ),

                ],
              ),
              const SizedBox(height: 20,),
              Container(
                width: double.infinity,
                height: 55,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: isReadyToContinue
                    ? PrimaryBtn(
                    btnText: "Publish",
                    onTap: _onContinueTap,
                    isLoading : _creatingEvent
                )
                    : SecondaryBtn(
                    btnText: "Publish", onTap: () {
                  String title = _titleController.text.trim();
                  String description = _descriptionController.text.trim();
                  String date = _dateController.text.trim();
                  if(title.isEmpty){
                    Utils.showCopyToastMessage(message: 'Please enter title of the event.');
                  }else if(_userUploadedEventImg == null){
                    Utils.showCopyToastMessage(message: 'Please add image of the event');
                  } else if(description.isEmpty){
                    Utils.showCopyToastMessage(message: 'Please tell us about event in description to proceed');
                  }else if(date.isEmpty){
                    Utils.showCopyToastMessage(message: 'Please select the date of the event.');
                  }else{
                    Utils.showCopyToastMessage(message: 'Please complete all required fields to proceed');
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadImageWidget() {
    return SizedBox(
      height: 160,
      child: GestureDetector(
        child: Container(
          width: double.infinity,
          padding: _userUploadedEventImg == null ? const EdgeInsets.all(40) : EdgeInsets.zero,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderColor)
          ),
          child:
           _userUploadedEventImg == null
               ? IconButton(icon: SvgPicture.asset(AppIcons.icUploadImage), onPressed: ()async{
             debugPrint("On tap");
             ImagePicker imagePicker = ImagePicker();
             final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
             if(pickedImage != null){
               _userUploadedEventImg = pickedImage;
               setState(() {});
             }
           },)
               : ClipRRect(
               borderRadius: BorderRadius.circular(10),
               child: Image.file(File(_userUploadedEventImg!.path,), fit: BoxFit.cover,))
        ),
      ),
    );
  }

  bool get isReadyToContinue {
    bool isReady = false;
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();
    String date = _dateController.text.trim();
    isReady = title.isNotEmpty && description.isNotEmpty && date.isNotEmpty && _userUploadedEventImg !=null;
    return isReady;
  }

  void _onContinueTap() async{
    setState(()=>  _creatingEvent = true);
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    try{
     var currentUser = Provider.of<LoggedInUserProvider>(context, listen: false).getUser;

     EventModel event = await EventService.createEvent(title: title,
          description: description,
          imagePath: _userUploadedEventImg!.path,
          eventDate: eventDate!,
          eventUrl: _eventUrlController.text.trim().isEmpty ? null : _eventUrlController.text.trim(),
         lat: currentUser.latitude,
         lng: currentUser.longitude,
          isForEveryOne: selectedEvent == eventTypeEveryone);
     Utils.showCopyToastMessage(message: 'Event created successfully');
     _onPopup(event);
    }catch(e){
      debugPrint("Could not create event: ${e.toString()}");
    }


    setState(()=>  _creatingEvent = false);
  }

  void _onPopup(EventModel event) {
    Navigator.of(context).pop(event);
  }
}