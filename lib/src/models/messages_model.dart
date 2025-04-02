import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesModel {
  final String messageID;
  final String senderID;
  final String messageText;
  final Timestamp timestamp;
  final bool isReadByReceiver;
  List<dynamic> readByUsers;

  MessagesModel({
    required this.messageID,
    required this.senderID,
    required this.messageText,
    required this.timestamp,
    this.isReadByReceiver = false,
    this.readByUsers = const []
  });

  // Convert MessagesModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'messageID': messageID,
      'senderID': senderID,
      'messageText': messageText,
      'timestamp': timestamp,
      'isReadByReceiver': isReadByReceiver,
      'readByUsers' : readByUsers
    };
  }

  // Create MessagesModel from a Map
  factory MessagesModel.fromMap(Map<String, dynamic> map) {
    return MessagesModel(
      messageID: map['messageID'] ?? '',
      senderID: map['senderID'] ?? '',
      messageText: map['messageText'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      isReadByReceiver: map['isReadByReceiver'] ?? false,
      readByUsers: map['readByUsers'] ?? []
    );
  }
}