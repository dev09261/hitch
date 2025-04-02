import 'package:flutter/widgets.dart';

class ContactedPlayersProvider extends ChangeNotifier{
  List<String> _contactedPlayers = [];

  List<String> get contactedPlayers => _contactedPlayers;

  void addToContactedPlayers({required String userID}){
    _contactedPlayers.add(userID);
    notifyListeners();
  }

 /* bool isContactedPlayer({required String userID}){
    return _contactedPlayers.contains(userID);
  }*/

  void addContactedPlayers(List<String> contactedPlayersList) {
    _contactedPlayers = contactedPlayersList;
    notifyListeners();
  }
}