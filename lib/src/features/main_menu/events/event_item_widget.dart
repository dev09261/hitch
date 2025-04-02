import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/models/event_model.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:intl/intl.dart';
class EventItemWidget extends StatelessWidget{
  final EventModel event;
  const EventItemWidget({super.key, required this.event});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder(future: UserAuthService.instance.getUserByID(userID: event.createdByUserID), builder: (ctx, snapshot){
          if(snapshot.hasData){
            return Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: CachedNetworkImageProvider(snapshot.requireData!.profilePicture),
                ),
                const SizedBox(width: 10,),
                Expanded(child: Text('Posted by ${snapshot.requireData!.userName}', style: const TextStyle(fontSize: 10),),)
              ],
            );

          }

          return const SizedBox();
        }),
        const SizedBox(height: 10,),
        Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xff525151)),),
        const SizedBox(height: 10,),
        ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(imageUrl: event.eventImageUrl)),
        const SizedBox(height: 10,),
        Text(DateFormat('MMM d').format(event.eventDate), style: const TextStyle(fontSize: 14, fontFamily: 'Inter', color: AppColors.headingColor),),
        const SizedBox(height: 5,),
        Text(event.description, style: const TextStyle(fontSize: 14, fontFamily: 'Inter', color: AppColors.darkGreyTextColor),),
        if(event.eventUrl != null)
          TextButton(
              style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: (){
                Utils.launchAppUrl(url: event.eventUrl!);
              }, child: const Text('Event link', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.primaryColor),))
      ],
    );
  }

}