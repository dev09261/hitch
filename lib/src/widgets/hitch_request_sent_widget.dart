import 'package:flutter/material.dart';

class HitchRequestSentWidget extends StatelessWidget{
  const HitchRequestSentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99), border: Border.all(color: Colors.black)),
        child: const Text("Request Sent", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),),);
  }

}