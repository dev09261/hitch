class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}

class Viewport {
  final Location northeast;
  final Location southwest;

  Viewport({required this.northeast, required this.southwest});

  factory Viewport.fromJson(Map<String, dynamic> json) {
    return Viewport(
      northeast: Location.fromJson(json['northeast']),
      southwest: Location.fromJson(json['southwest']),
    );
  }
}

class Geometry {
  final Location location;
  final Viewport viewport;

  Geometry({required this.location, required this.viewport});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: Location.fromJson(json['location']),
      viewport: Viewport.fromJson(json['viewport']),
    );
  }
}

class Photo {
  final int height;
  final String photoReference;
  final int width;

  Photo({required this.height, required this.photoReference, required this.width});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      height: json['height'],
      photoReference: json['photo_reference'],
      width: json['width'],
    );
  }
}

class NearbyCourts {
  final String businessStatus;
  final Geometry geometry;
  final String icon;
  final String name;
  // final bool? openNow;
  final List<Photo>? photos;  // Nullable list of photos
  final String placeId;
  final String vicinity;
  final double rating;
  final int userRatingsTotal;
  double distanceInMiles;
  NearbyCourts({
    required this.businessStatus,
    required this.geometry,
    required this.icon,
    required this.name,
    // this.openNow,
    this.photos,  // Nullable photos
    required this.placeId,
    required this.vicinity,
    required this.rating,
    required this.userRatingsTotal,
    this.distanceInMiles = 0,
  });

  factory NearbyCourts.fromJson(Map<String, dynamic> json) {
    var photosList = json['photos'] as List?;
    List<Photo>? photos = photosList?.map((i) => Photo.fromJson(i)).toList();

    return NearbyCourts(
      businessStatus: json['business_status'],
      geometry: Geometry.fromJson(json['geometry']),
      icon: json['icon'],
      name: json['name'],
      // openNow: json['opening_hours']['open_now'],
      photos: photos,
      placeId: json['place_id'],
      vicinity: json['vicinity'],
      rating: json['rating'].toDouble(),
      userRatingsTotal: json['user_ratings_total'],
    );
  }
}

class PlacesApiResponse {
  final List<NearbyCourts> results;

  PlacesApiResponse({required this.results});

  factory PlacesApiResponse.fromJson(Map<String, dynamic> json) {
    var resultsList = json['results'] as List;
    List<NearbyCourts> results = resultsList.map((i) => NearbyCourts.fromJson(i)).toList();

    return PlacesApiResponse(
      results: results,
    );
  }
}
