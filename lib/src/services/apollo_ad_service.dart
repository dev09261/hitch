import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hitch/src/models/promo_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/utils/show_snackbars.dart';

class ApolloAdService {
  static final _apolloColRef = FirebaseFirestore.instance.collection('apollo_link_clicks');

  Future clicked(UserModel user) async {
    await _apolloColRef.add({
      'userId': user.userID,
      'lat': user.latitude,
      'lng': user.longitude,
      'time': DateTime.now().millisecondsSinceEpoch
    });
  }
}