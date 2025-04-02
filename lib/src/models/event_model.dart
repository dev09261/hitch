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
  });

  Map<String, dynamic> toMap() {
    return {
      'eventID': eventID,
      'createdAt': createdAt.toIso8601String(),
      'eventDate': eventDate.toIso8601String(),
      'title': title,
      'description': description,
      'eventImageUrl': eventImageUrl,
      'eventUrl': eventUrl,
      'isForEveryOne': isForEveryOne,
      'createdByUserID' : createdByUserID
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventID: map['eventID'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      eventDate: DateTime.tryParse(map['eventDate'] ?? '') ?? DateTime.now(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      eventImageUrl: map['eventImageUrl'] ?? '',
      eventUrl: map['eventUrl'],
      isForEveryOne: map['isForEveryOne'] ?? false,
      createdByUserID : map['createdByUserID']
    );
  }
}
