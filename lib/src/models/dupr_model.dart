class DuprModel {
  final String status;
  String? duprId;
  double? singleRating;
  double? doubleRating;

  // Constructor with required parameters
  DuprModel({
    required this.status,
    this.duprId,
    this.singleRating,
    this.doubleRating,
  });

  // Convert the object to a Map
  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'duprId': duprId,
      'singles': singleRating,
      'doubles': doubleRating,
    };
  }

  // Create an object from a Map
  factory DuprModel.fromMap(Map<String, dynamic> map) {
    return DuprModel(
      status: map['status'] ?? '',
      duprId: map['duprId'],
      singleRating: double.tryParse(map['singles']) ?? 0,
      doubleRating: double.tryParse(map['doubles']) ?? 0
    );
  }
}