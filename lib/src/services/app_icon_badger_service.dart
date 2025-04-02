import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:hitch/src/services/hitches_service.dart';

class AppIconBadgerService {

  static void updateAppIconBadge()async{
    getTotalUnreadMessagesCount();
  }

  static Future<int> getTotalUnreadMessagesCount() async {
    int totalUnreadCount = 0;

    totalUnreadCount =  await HitchesService.getPendingAndUnReadCount();

    FlutterAppBadger.updateBadgeCount(totalUnreadCount);
    // debugPrint("Total Unread count: $totalUnreadCount");
    return totalUnreadCount;
  }
}