part of 'courts_cubit.dart';
abstract class CourtsStates extends Equatable{}

class InitialCourtStates extends CourtsStates{
  @override
  List<Object?> get props => [];

}

class LoadingCourts extends CourtsStates{
  @override
  List<Object?> get props => [];
}
class LoadedCourts extends CourtsStates{
  final List<NearbyCourts> courtsNearby;
  LoadedCourts({required this.courtsNearby});
  @override
  List<Object?> get props => [];
}
class LoadingCourtsFailed extends CourtsStates{
  final String errorMessage;
  LoadingCourtsFailed({required this.errorMessage});

  @override
  List<Object?> get props => [];
}

class LocationPermissionDenied extends CourtsStates{
  @override
  List<Object?> get props => [];
}
class LocationPermissionDeniedForever extends CourtsStates{
  @override
  List<Object?> get props => [];
}

class CurrentLocationCameraPosition extends CourtsStates{
  final CameraPosition initialCameraPosition;

  CurrentLocationCameraPosition({required this.initialCameraPosition});
  @override
  // TODO: implement props
  List<Object?> get props => [initialCameraPosition];

}
class LoadedMarkersOfCourts extends CourtsStates{
  final Set<Marker> markers;
  LoadedMarkersOfCourts({required this.markers});

  @override
  List<Object?> get props => [markers];
}

class UserNotFound extends CourtsStates{
  @override
  List<Object?> get props => [];
}