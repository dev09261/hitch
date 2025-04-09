import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../helpers/url_creator_helper.dart';
import '../../../models/pickleball_tournament_model.dart';
import '../../../res/app_colors.dart';
import '../../../res/app_text_styles.dart';
import '../../../utils/utils.dart';

class PickleBallTournamentItemWidget extends StatelessWidget{
  final Tournament tournament;
  const PickleBallTournamentItemWidget({super.key, required this.tournament});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        String url = UrlCreatorHelper.generateTournamentUrl(tournament.title);
        // debugPrint("Url found: $url");
        Utils.launchAppUrl(url: url);
      },
      child: Container(
        decoration: BoxDecoration(

            color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.grey, spreadRadius: 1)],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(imageUrl: tournament.logo),
            Padding(padding: const EdgeInsets.all(10), child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tournament.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.pageHeadingStyle.copyWith(color: Colors.black, fontWeight: FontWeight.w600),),
                Text(tournament.location, style: AppTextStyles.regularTextStyle,),
                Text('${DateFormat('MMM dd, yyyy').format(tournament.dateFrom)} - ${DateFormat('MMM dd, yyyy').format(tournament.dateTo)}', style: AppTextStyles.pageHeadingStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 75,
                      decoration: BoxDecoration(
                          color: AppColors.primaryDarkColor,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text('\$${tournament.price}', textAlign: TextAlign.center, style: AppTextStyles.regularTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w600),),
                    ),
                    Text('${tournament.registrationCount} players', style: AppTextStyles.regularTextStyle,)
                  ],
                )
              ],
            ),)
          ],
        ),
      ),
    );
  }

}