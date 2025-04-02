part of 'players_coaches_cubit.dart';
abstract class PlayersCoachesState extends Equatable{}

class InitialPlayersState extends PlayersCoachesState{
  @override
  List<Object?> get props => [];
}

class ShowLetsPlayAnim extends PlayersCoachesState{
  @override
  List<Object?> get props => [];
}
class HideLetsPlayAnim extends PlayersCoachesState{
  @override
  List<Object?> get props => [];
}

class LoadingPlayers extends PlayersCoachesState{
  @override
  List<Object?> get props => [];
}
class LoadedPlayers extends PlayersCoachesState{
  final List<UserModel> players;
  LoadedPlayers({required this.players});
  @override
  List<Object?> get props => [];
}
class LoadingPlayersFailed extends PlayersCoachesState{
  final String errorMessage;
  LoadingPlayersFailed({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

class LoadingCoaches extends PlayersCoachesState{
  @override
  List<Object?> get props => [];
}
class LoadedCoaches extends PlayersCoachesState{
  final List<UserModel> coaches;
  LoadedCoaches({required this.coaches});
  @override
  List<Object?> get props => [];
}
class LoadingCoachesFailed extends PlayersCoachesState{
  final String errorMessage;
  LoadingCoachesFailed({required this.errorMessage});
  @override
  List<Object?> get props => [];
}

class LocationPermissionDeniedForever extends PlayersCoachesState{
  @override
  List<Object?> get props => [];
}