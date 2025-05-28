import 'package:cloud_firestore/cloud_firestore.dart';

class PendingHitchesModel {
  final String uid;
  final String? senderName;
  final String? receiverName;
  final String? senderId;
  final String? receiverId;
  final String? senderToken;
  final String? receiverToken;
  static final CollectionReference _pendingHitchesColRef =   FirebaseFirestore.instance.collection('pendingHitches');

  // Constructor with required parameters
  PendingHitchesModel({
    required this.uid,
    this.senderName,
    this.receiverName,
    this.senderId,
    this.senderToken,
    this.receiverToken,
    this.receiverId,
  });

  // Convert the object to a Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'senderName': senderName,
      'receiverName': receiverName,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderToken': senderToken,
      'receiverToken': receiverToken,
      'createdAt': Timestamp.now()
    };
  }

  Future<void> create() async {
    await _pendingHitchesColRef.doc(uid).set(toMap());
  }

  Future<void> delete() async {
    await _pendingHitchesColRef.doc(uid).delete();
  }
}