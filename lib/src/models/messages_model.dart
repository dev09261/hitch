import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesModel {
  final String messageID;
  final String senderID;
  final String messageText;
  final String type;
  final String fileUrl;
  final Timestamp timestamp;
  final bool isReadByReceiver;
  List<dynamic> readByUsers;

  MessagesModel(
      {required this.messageID,
      required this.senderID,
      required this.messageText,
      required this.type,
      this.fileUrl = '',
      required this.timestamp,
      this.isReadByReceiver = false,
      this.readByUsers = const []});

  // Convert MessagesModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'messageID': messageID,
      'senderID': senderID,
      'messageText': messageText,
      'type': type,
      'fileUrl': fileUrl,
      'timestamp': timestamp,
      'isReadByReceiver': isReadByReceiver,
      'readByUsers': readByUsers
    };
  }

  // Create MessagesModel from a Map
  factory MessagesModel.fromMap(Map<String, dynamic> map) {
    return MessagesModel(
        messageID: map['messageID'] ?? '',
        senderID: map['senderID'] ?? '',
        messageText: map['messageText'] ?? '',
        fileUrl: map['fileUrl'] ?? '',
        type: map['type'] ?? 'text',
        timestamp: map['timestamp'] ?? Timestamp.now(),
        isReadByReceiver: map['isReadByReceiver'] ?? false,
        readByUsers: map['readByUsers'] ?? []);
  }
}
