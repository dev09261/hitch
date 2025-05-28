import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/utils/utils.dart';

class PlayersCoachesService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Stream<List<UserModel>> getPlayers({
    required UserModel user,
  }) {
    GeoBox box = Utils.calculateBoundingBox(
        user.latitude!, user.longitude!, user.distanceFromCurrentLocation);
    return _usersCollection
        .where('userID', isNotEqualTo: user.userID)
        .where('latitude', isGreaterThanOrEqualTo: box.minLat)
        .where('latitude', isLessThanOrEqualTo: box.maxLat)
        .where('longitude', isGreaterThanOrEqualTo: box.minLng)
        .where('longitude', isLessThanOrEqualTo: box.maxLng)
        .snapshots()
        .map((snapshot) {
      List<UserModel> players = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        UserModel user = UserModel.fromMap(data);
        return user;
      }).toList();

      if (user.playerTypeCoach) {
        return _getPlayersOfSimilarMatchGenderType(
            players: players, currentUser: user);
      }

      players = fetchPlayersOfSimilarLevel(
          currentUser: user,
          playerList: players,
          isPickleball: user.playerTypePickle);

      return players;
    });
  }

  Stream<List<UserModel>> getCoaches() {
    return _usersCollection
        .where('playerTypeCoach', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      List<UserModel> coaches = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data);
      }).toList();
      coaches = coaches
          .where(
              (player) => player.latitude != null || player.longitude != null)
          .toList();
      coaches = coaches
          .where(
              (user) => user.userID != FirebaseAuth.instance.currentUser!.uid)
          .toList();
      return coaches;
    });
  }

  List<UserModel> fetchPlayersOfSimilarLevel({
    required UserModel currentUser,
    required List<UserModel> playerList,
    required bool isPickleball,
  }) {
    final players = playerList.where((player) {
      //Now we have to check here if player has old version or newer version
      //Current user will always have newer version we have to verify the old users

      if ((player.playerTypePickle && player.isConnectedToDupr) ||
          (player.pickleBallPlayerLevel != null && player.playerTypePickle) ||
          (player.tennisBallPlayerLevel != null && player.playerTypeTennis) ||
          (player.padelBallPlayerLevel != null && player.playerTypePadel)) {
        // debugPrint("New player found: ${player.userName}, and Pickle level: ${player.pickleBallPlayerLevel?.levelRank}, Tennis level: ${player.tennisBallPlayerLevel?.levelRank}");
        // It means player has newer version installed
        bool isPickle = false;
        bool isTennis = player.tennisBallPlayerLevel?.levelRank ==
                currentUser.tennisBallPlayerLevel?.levelRank &&
            currentUser.tennisBallPlayerLevel?.levelRank != '';
        bool isPadel = player.padelBallPlayerLevel?.levelRank ==
                currentUser.padelBallPlayerLevel?.levelRank &&
            currentUser.padelBallPlayerLevel?.levelRank != '';

        if (player.playerTypePickle && player.isConnectedToDupr) {
          if (currentUser.pickleBallPlayerLevel?.levelRank != null) {
            double level =
                double.tryParse(currentUser.pickleBallPlayerLevel!.levelRank) ??
                    0;
            if (level == 2.0 && player.duprDoubleRating! < 3) {
              isPickle = true;
            }
            if (player.duprDoubleRating! >= level &&
                player.duprDoubleRating! < level + 1) {
              isPickle = true;
            }
          }
        } else {
          isPickle = player.pickleBallPlayerLevel?.levelRank ==
              currentUser.pickleBallPlayerLevel?.levelRank
              && currentUser.pickleBallPlayerLevel?.levelRank != '';
        }
        // debugPrint("isPickle: $isPickle , isTennis: $isTennis");
        if (!player.playerTypePickle || !currentUser.playerTypePickle) {
          isPickle = false;
        }

        if (!player.playerTypeTennis || !currentUser.playerTypeTennis) {
          isTennis = false;
        }

        if (!player.playerTypePadel || !currentUser.playerTypePadel) {
          isPadel = false;
        }

        return isPickle || isTennis || isPadel;
      } else {
        // debugPrint("Old player found: ${player.userName}, and level: ${player.level}");
        //Breaking down the level

        List<String> levels = player.level.split(" - ");

        // Player has older version installed then compare player level with current user levels
        return player.level == currentUser.level && currentUser.level != '';
      }
    }).toList();

    return _getPlayersOfSimilarMatchGenderType(
        players: players, currentUser: currentUser);
  }

  List<UserModel> _getPlayersOfSimilarMatchGenderType(
      {required List<UserModel> players, required UserModel currentUser}) {
    return players.where((player) {
      // Check genderType match
      bool isGenderMatch = currentUser.genderType == "Both" ||
          (currentUser.genderType
                      .substring(0, currentUser.genderType.length - 1) ==
                  "Male" &&
              player.gender == "Male") ||
          (currentUser.genderType
                      .substring(0, currentUser.genderType.length - 1) ==
                  "Female" &&
              player.gender == "Female");

      // Check matchType match
      bool isMatchTypeMatch = currentUser.matchType == "Both" ||
          currentUser.matchType == player.matchType ||
          player.matchType == "Both";

      return isGenderMatch && isMatchTypeMatch;
    }).toList();
  }
}
