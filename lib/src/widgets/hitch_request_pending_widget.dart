import 'package:flutter/material.dart';
import 'package:hitch/src/models/hitches_model.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/hitches_service.dart';

class HitchRequestPendingWidget extends StatelessWidget{
  final HitchesModel hitchRequest;
  const HitchRequestPendingWidget({super.key, required this.hitchRequest});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: ()=> HitchesService.onAcceptRejectHitchTap(hitchRequest: hitchRequest, hitchStatus: hitchesStateAccepted),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(color: AppColors.primaryColorVariant1, borderRadius: BorderRadius.circular(99),),
          child: const Text("Accept Hitch", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),),));
  }

}