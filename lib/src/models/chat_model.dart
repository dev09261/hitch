import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_user_model.dart';

class ChatModel {
  final String roomID;
  final ChatUserModel remoteUser;
  final Timestamp dateTimeCreated;

  // Constructor with required parameters
  ChatModel({
    required this.roomID,
    required this.remoteUser,
    required this.dateTimeCreated,
  });

  // Convert the object to a Map
  Map<String, dynamic> toMap() {
    return {
      'roomID': roomID,
      'remoteUser': remoteUser.toMap(),
      'dateTimeCreated': dateTimeCreated,
    };
  }

  // Create an object from a Map
  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      roomID: map['roomID'] ?? '',
      remoteUser: ChatUserModel.fromMap(map['remoteUser'] ?? {}),
      dateTimeCreated: map['dateTimeCreated'] ?? Timestamp.now(),
    );
  }
}