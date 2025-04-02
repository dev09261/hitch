import 'package:hitch/src/models/user_model.dart';

class HitchesModel {
  final String hitchID;
  final UserModel user;
  final String hitchesStatus;
  final bool isRequestViewed;
  final int hitchCount;
  final DateTime? dateTime; // New variable, nullable to manage older records

  HitchesModel({
    required this.hitchID,
    required this.user,
    required this.hitchesStatus,
    this.isRequestViewed = false,
    this.hitchCount = -1,
    this.dateTime, // Default is null for older records
  });

  Map<String, dynamic> toMap() {
    return {
      'hitchID': hitchID,
      'user': user.toMap(),
      'hitchesStatus': hitchesStatus,
      'isRequestViewed': isRequestViewed,
      'hitchCount': hitchCount,
      'dateTime': dateTime?.toIso8601String(), // Convert to string for serialization
    };
  }

  factory HitchesModel.fromMap(Map<String, dynamic> map) {
    return HitchesModel(
      hitchID: map['hitchID'],
      user: UserModel.fromMap(map['user']),
      hitchesStatus: map['hitchesStatus'],
      isRequestViewed: map['isRequestViewed'] ?? false,
      hitchCount: map['hitchCount'] ?? -1,
      dateTime: map['dateTime'] != null
          ? DateTime.parse(map['dateTime'])
          : null, // Handle missing dateTime
    );
  }
}