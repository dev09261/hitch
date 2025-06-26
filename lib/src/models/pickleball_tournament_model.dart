class PickleballTournamentModel {
  final TournamentData data;

  PickleballTournamentModel({required this.data});

  factory PickleballTournamentModel.fromJson(Map<String, dynamic> json) {
    return PickleballTournamentModel(
      data: TournamentData.fromJson(json['data']),
    );
  }
}

class TournamentData {
  final TournamentList tournaments;

  TournamentData({required this.tournaments});

  factory TournamentData.fromJson(Map<String, dynamic> json) {
    return TournamentData(
      tournaments: TournamentList.fromJson(json['tournaments']),
    );
  }
}

class TournamentList {
  final int totalCount;
  final List<Tournament> items;

  TournamentList({required this.totalCount, required this.items});

  factory TournamentList.fromJson(Map<String, dynamic> json) {
    return TournamentList(
      totalCount: json['totalCount'],
      items: (json['items'] as List)
          .map((item) => Tournament.fromJson(item))
          .toList(),
    );
  }
}

class Tournament {
  final String id;
  final String title;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String location;
  final double price;
  final bool isFree;
  final String logo;
  final int registrationCount;
  final double lat;
  final double lng;
  double distance;

  Tournament({
    required this.id,
    required this.title,
    required this.dateFrom,
    required this.dateTo,
    required this.location,
    required this.price,
    required this.isFree,
    required this.logo,
    required this.registrationCount,
    required this.lat,
    required this.lng,
    required this.distance
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      title: json['title'],
      dateFrom: DateTime.parse(json['dateFrom']),
      dateTo: DateTime.parse(json['dateTo']),
      location: json['location'],
      price: (json['price'] as num).toDouble(),
      isFree: json['isFree'],
      logo: json['logo'],
      registrationCount: json['registrationCount'] ?? 100,
      lat: (json['lat'] ?? 0) * 1.0,
      lng: (json['lng'] ?? 0) * 1.0,
      distance: json['distance'] ?? 0
    );
  }
}
