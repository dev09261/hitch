part of 'user_info_cubit.dart';
abstract class UserInfoStates extends Equatable{}

class InitialUserState extends UserInfoStates{
  @override
  List<Object?> get props => [];
}

class UpdatingUserInfo extends UserInfoStates{
  @override
  List<Object?> get props => [];
}
class UpdatedUserInfo extends UserInfoStates{
  final UserModel userModel;
  UpdatedUserInfo({required this.userModel});
  @override
  List<Object?> get props => [userModel];
}
class UpdatingUserInfoFailed extends UserInfoStates{
  final String errorMessage;
  UpdatingUserInfoFailed({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

class LoadingUserInfo extends UserInfoStates{
  @override
  List<Object?> get props => [];
}
class LoadedUserInfo extends UserInfoStates{
  final Map<String, dynamic> userMap;
  LoadedUserInfo({required this.userMap});
  @override
  List<Object?> get props => [userMap];
}
class LoadingUserInfoFailed extends UserInfoStates{
  final String errorMessage;
  LoadingUserInfoFailed({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

class GoogleSigningIn extends UserInfoStates{
  @override
  List<Object?> get props => [];
}
class GoogleSignedUp extends UserInfoStates{
  final UserCredential user;
  GoogleSignedUp({required this.user});
  @override
  List<Object?> get props => [user];
}
class GoogleSignedIn extends UserInfoStates{
  @override
  List<Object?> get props => [];
}

class AppleSigningIn extends UserInfoStates{
  @override
  List<Object?> get props => [];
}
class AppleSignedUp extends UserInfoStates{
  final String email;
  final String userID;
  final String userName;
  AppleSignedUp({required this.email, required this.userName, required this.userID});
  @override
  List<Object?> get props => [email, userName, userID];
}
class AppleSignedIn extends UserInfoStates{
  @override
  List<Object?> get props => [];
}

class SigningUpError extends UserInfoStates{
  final String errorMessage;
  SigningUpError({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}
class UserNotFoundInDB extends UserInfoStates{
  final String email;
  final String userID;
  final String userName;
  UserNotFoundInDB({required this.email, required this.userName, required this.userID});
  @override
  List<Object?> get props => [email, userName, userID];
}

class UserSportsMediaUploading extends UserInfoStates{
  @override
  List<Object?> get props => [];
}
class UserSportsMediaUploaded extends UserInfoStates{
  @override
  List<Object?> get props => [];
}
class UserSportsMediaUploadingFailed extends UserInfoStates{
  final String errorMessage;
  UserSportsMediaUploadingFailed({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}