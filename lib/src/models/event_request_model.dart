class EventRequestModel {
  String eventID;
  DateTime createdAt;
  int eventDate;
  String createdByUserID;
  String requestUserId;
  String requestUserName;
  String requestUserImageUrl;
  String status; // Pending, Accepted
  String? docId;

  EventRequestModel({
    required this.eventID,
    required this.createdAt,
    required this.eventDate,
    required this.createdByUserID,
    required this.requestUserId,
    required this.requestUserName,
    required this.requestUserImageUrl,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventID': eventID,
      'createdAt': createdAt.toIso8601String(),
      'eventDate': eventDate,
      'createdByUserID' : createdByUserID,
      'requestUserId' : requestUserId,
      'requestUserName' : requestUserName,
      'requestUserImageUrl' : requestUserImageUrl,
      'status' : status,
    };
  }

  factory EventRequestModel.fromMap(Map<String, dynamic> map) {
    return EventRequestModel(
      eventID: map['eventID'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      eventDate: map['eventDate'],
      createdByUserID : map['createdByUserID'],
      requestUserId : map['requestUserId'],
      requestUserName : map['requestUserName'],
      requestUserImageUrl : map['requestUserImageUrl'],
      status : map['status'],
    );
  }
}
