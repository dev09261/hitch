// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_icons.dart';

class SecondaryBtn extends StatelessWidget{
  final String btnText;
  final VoidCallback onTap;
  final bool messageToPlayer;
  const SecondaryBtn({super.key, required this.btnText, required this.onTap, this.messageToPlayer = false});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          side: const BorderSide(color: Colors.black),
          padding: const EdgeInsets.symmetric( vertical: 6)
        ),
        onPressed: onTap, child: messageToPlayer ?  Row(
      mainAxisSize: MainAxisSize.min,
      children: [
          Image.asset(AppIcons.icMessage, color: Colors.black, height: 40,),
      const SizedBox(width: 8,),
      const Text("Message", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xff5E5D5D)))
    ],) : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Text(
        btnText,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xff5E5D5D)),
      ),
    ));
  }

}