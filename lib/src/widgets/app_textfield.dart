import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/utils/formatters.dart';
import 'package:intl/intl.dart';
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.textEditingController,
    required this.hintText,
    this.textInputNumber = false,
    this.isReadOnly = false,
    this.onTextChange,
    this.isDatePicker = false,
    this.onEventDateChange
  });

  final TextEditingController textEditingController;
  final String hintText;
  final bool textInputNumber;
  final bool isReadOnly;
  final Function(String text)? onTextChange;
  final bool isDatePicker;

  final Function(DateTime eventDate)? onEventDateChange;
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool isFocused = false;
  bool isNotEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (val)=> setState(()=> isFocused = val),
      child: TextField(
        readOnly: widget.isReadOnly || widget.isDatePicker,
        onTap: ()=> widget.isDatePicker ? _pickDate() : null,
        inputFormatters: widget.textInputNumber ?  [
          PhoneNumberFormatter()
        ] :  null,
        controller: widget.textEditingController,
        textInputAction: TextInputAction.done,
        keyboardType: widget.textInputNumber ?  TextInputType.number : TextInputType.text,
        onTapOutside: (_)=> FocusManager.instance.primaryFocus!.unfocus(),
        onChanged: (val){
          if(widget.onTextChange != null){

            widget.onTextChange!(val);
          }
          setState(()=> isNotEmpty = val.isNotEmpty);
        },
        decoration: InputDecoration(
            hintText: widget.hintText,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!, width: 2)
            ),
            suffixIcon: (isNotEmpty && isFocused) ?  InkWell(
                onTap: (){
                  widget.textEditingController.clear();
                },
                child: const Icon(Icons.cancel,color: Colors.grey,)) : null,
            hintStyle: AppTextStyles.regularTextStyle.copyWith(color: AppColors.greyTextColor),
            labelStyle: AppTextStyles.regularTextStyle
        ),
      ),
    );
  }

  void _pickDate()async{
    DateTime now = DateTime.now();
   DateTime? selectedDate = await showDatePicker(context: context, firstDate: now, lastDate: DateTime(now.year, 12,));
   if(selectedDate != null){
     DateFormat dateFormat = DateFormat('MMM d');
     widget.textEditingController.text = dateFormat.format(selectedDate);
     widget.onEventDateChange!(selectedDate);
     setState(() {});
   }
  }
}