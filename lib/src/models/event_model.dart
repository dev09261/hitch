class EventModel {
  final String eventID;
  final DateTime createdAt;
  final DateTime eventDate;
  final String title;
  final String description;
  final String eventImageUrl;
  final String? eventUrl;
  final bool isForEveryOne;
  final String createdByUserID;
  double? latitude;
  double? longitude;
  EventModel({
    required this.eventID,
    required this.createdAt,
    required this.eventDate,
    required this.title,
    required this.description,
    required this.eventImageUrl,
    this.eventUrl,
    required this.isForEveryOne,
    required this.createdByUserID,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventID': eventID,
      'createdAt': createdAt.toIso8601String(),
      'eventDate': eventDate.millisecondsSinceEpoch,
      'title': title,
      'description': description,
      'eventImageUrl': eventImageUrl,
      'eventUrl': eventUrl,
      'isForEveryOne': isForEveryOne,
      'createdByUserID' : createdByUserID,
      'latitude': latitude,
      'longitude':longitude,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventID: map['eventID'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      eventDate: DateTime.fromMillisecondsSinceEpoch(map['eventDate'] ?? DateTime.now().millisecondsSinceEpoch),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      eventImageUrl: map['eventImageUrl'] ?? '',
      eventUrl: map['eventUrl'],
      isForEveryOne: map['isForEveryOne'] ?? false,
      createdByUserID : map['createdByUserID'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
