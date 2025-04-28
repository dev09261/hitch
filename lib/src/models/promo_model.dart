class PromoModel {
  final String code;
  final int limit;
  final int used;
  // Constructor
  PromoModel({
    required this.code,
    required this.limit,
    required this.used,
  });

  // Convert UploadedFileModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'limit': limit,
      'used': used,
    };
  }

  // Create UploadedFileModel from a Map
  factory PromoModel.fromMap(Map<String, dynamic> map) {
    return PromoModel(
      code: map['code'] as String,
      limit: map['limit'] ?? 0,
      used: map['used'] ?? 0,
    );
  }
}