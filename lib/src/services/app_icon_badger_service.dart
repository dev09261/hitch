import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:hitch/src/services/hitches_service.dart';

class AppIconBadgerService {

  static void updateAppIconBadge()async{
    getTotalUnreadMessagesCount();
  }

  static Future<int> getTotalUnreadMessagesCount() async {
    int totalUnreadCount = 0;

    totalUnreadCount =  await HitchesService.getPendingAndUnReadCount();

    FlutterAppBadgeControl.updateBadgeCount(totalUnreadCount);
    // debugPrint("Total Unread count: $totalUnreadCount");
    return totalUnreadCount;
  }
}