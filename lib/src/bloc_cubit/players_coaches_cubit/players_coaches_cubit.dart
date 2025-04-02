import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitch/src/models/user_model.dart';

import '../../models/permission_accepted_rejected_model.dart';
import '../../utils/utils.dart';
part 'players_coaches_states.dart';

class PlayersCoachesCubit extends Cubit<PlayersCoachesState>{
  PlayersCoachesCubit() : super(InitialPlayersState());

  void onShowLetsPlayAnim(){
    emit(ShowLetsPlayAnim());
  }

  void onHideLetsPlayAnim(){
    emit(HideLetsPlayAnim());
  }

  void checkLocPermission()async{
    LocationPermissionResponseModel response = await Utils.getUpdateUserLocation();
    if(!response.permissionGranted){
      emit(LocationPermissionDeniedForever());
    }else{
      emit(InitialPlayersState());
    }
  }
}