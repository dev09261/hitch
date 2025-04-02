/*
class SponsoredClubModel {
  final String name;
  final String linkToSite;
  final bool status;
  final String address;
  final bool affiliateTurnedOn;
  final String affiliateLink;
  final String icon;
  final String clubPhoto;

  SponsoredClubModel({
    required this.name,
    required this.linkToSite,
    required this.status,
    required this.address,
    required this.affiliateTurnedOn,
    required this.affiliateLink,
    required this.icon,
    required this.clubPhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'linkToSite': linkToSite,
      'status': status,
      'address': address,
      'affiliateTurnedOn': affiliateTurnedOn,
      'affiliateLink': affiliateLink,
      'icon': icon,
      'clubPhoto': clubPhoto,
    };
  }

  factory SponsoredClubModel.fromMap(Map<String, dynamic> map) {
    return SponsoredClubModel(
      name: map['name'] ?? '',
      linkToSite: map['linkToSite'] ?? '',
      status: map['status'] ?? false,
      address: map['address'] ?? '',
      affiliateTurnedOn: map['affiliateTurnedOn'] ?? false,
      affiliateLink: map['affiliateLink'] ?? '',
      icon: map['icon'] ?? '',
      clubPhoto: map['clubPhoto'] ?? '',
    );
  }
}*/
class SponsoredClubModel {
  final String name;
  final String status;
  final String address;
  final bool affiliateOfferTurnedOn;
  final String affiliateLink;

  SponsoredClubModel({
    required this.name,
    required this.status,
    required this.address,
    required this.affiliateOfferTurnedOn,
    required this.affiliateLink,
  });

  /// Convert CSV row (List<dynamic>) to SponsoredClub object
  factory SponsoredClubModel.fromCsv(List<dynamic> row) {
    return SponsoredClubModel(
      name: row[0] as String,
      status: row[1] as String,
      address: row[2] as String,
      affiliateOfferTurnedOn: (row[3] as String).toUpperCase() == "YES",
      affiliateLink: row[4] as String,
    );
  }

  /// Convert SponsoredClub object to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
      'address': address,
      'affiliateOfferTurnedOn': affiliateOfferTurnedOn,
      'affiliateLink': affiliateLink,
    };
  }

  factory SponsoredClubModel.fromMap(Map<String, dynamic> map) {
    return SponsoredClubModel(
      name: map['name'] ?? '',
      status: map['status'] ?? false,
      address: map['address'] ?? '',
      affiliateLink: map['affiliateLink'] ?? '',
      affiliateOfferTurnedOn: map['affiliateOfferTurnedOn'],
    );
  }
}