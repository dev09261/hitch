import 'package:hitch/src/models/chat_user_model.dart';
import 'package:hitch/src/models/messages_model.dart';

class GroupChatModel {
  final String chatID;
  final String groupName;
  final DateTime createdAt;
  final List<String> memberIDs;
  final List<ChatUserModel> members;
  final String adminID;
  final MessagesModel? lastMessage;

  GroupChatModel({
    required this.chatID,
    required this.groupName,
    required this.createdAt,
    required this.members,
    required this.adminID,
    required this.memberIDs,
    this.lastMessage,
  });

  // Convert GroupChatModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'chatID': chatID,
      'groupName': groupName,
      'createdAt': createdAt.toIso8601String(),
      'memberIDs': memberIDs,
      'members': members.map((member) => member.toMap()).toList(),
      'adminID': adminID,
      'lastMessage': lastMessage?.toMap(),
    };
  }

  // Create GroupChatModel from a Map
  factory GroupChatModel.fromMap(Map<String, dynamic> map) {
    return GroupChatModel(
      chatID: map['chatID'] ?? '',
      groupName: map['groupName'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      memberIDs: List<String>.from(map['memberIDs'] ?? []),
      members: (map['members'] as List<dynamic>?)?.map((m) => ChatUserModel.fromMap(m)).toList() ?? [],
      adminID: map['adminID'] ?? '',
      lastMessage: map['lastMessage'] != null ? MessagesModel.fromMap(map['lastMessage']) : null,
    );
  }
}
