import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hitch/src/models/promo_model.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/utils/show_snackbars.dart';

class PromoService {
  static final _promoColRef = FirebaseFirestore.instance.collection(promoCollection);

  Future<bool> checkPromoCode(String code, BuildContext context) async {
    try {
      QuerySnapshot querySnapshot = await _promoColRef.where("code", isEqualTo: code).get();
      List<PromoModel> promos = querySnapshot.docs.map((doc)=> PromoModel.fromMap(doc.data() as Map<String,dynamic>)).toList();

      if (promos.isEmpty) {
        ShowSnackbars.showErrorSnackBar(context, errorMsgTitle: "Incorrect Promo Code", errorMsgTxt: "Please try another!");
        return false;
      }

      bool hasPromo = false;
      for (var item in promos) {
        if (item.limit > item.used) {
          hasPromo = true;
        }
      }
      if (!hasPromo) {
        ShowSnackbars.showErrorSnackBar(context, errorMsgTitle: "Expired Promo Code", errorMsgTxt: "Please try another!");
      }

      return hasPromo;
    } catch (e) {
      ShowSnackbars.showErrorSnackBar(context, errorMsgTitle: "Something went wrong", errorMsgTxt: "Please try later again!");
      return false;
    }
  }

  Future updateUsePromo(String code) async {
    QuerySnapshot querySnapshot = await _promoColRef.where("code", isEqualTo: code).get();
    List<PromoModel> promos = querySnapshot.docs.map((doc)=> PromoModel.fromMap(doc.data() as Map<String,dynamic>)).toList();
    if (promos.isNotEmpty) {
      await _promoColRef.doc(querySnapshot.docs.first.id).update({
        'used': promos.first.used + 1
      });
    }
  }
}