class ChatUserModel {
  final String userID;
  final String userName;
  final String profilePicture;

  // Constructor with required parameters
  ChatUserModel({
    required this.userID,
    required this.userName,
    required this.profilePicture,
  });

  // Convert the object to a Map
  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'userName': userName,
      'profilePicture': profilePicture,
    };
  }

  // Create an object from a Map
  factory ChatUserModel.fromMap(Map<String, dynamic> map) {
    return ChatUserModel(
      userID: map['userID'] ?? '',
      userName: map['userName'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
    );
  }
}