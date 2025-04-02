import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/permission_accepted_rejected_model.dart';
import '../../utils/utils.dart';
part 'hitches_states.dart';

class HitchesCubit extends Cubit<HitchesState>{
  HitchesCubit() : super(HitchesInitialState());

  void checkLocPermission()async{
    LocationPermissionResponseModel response = await Utils.getUpdateUserLocation();
    if(!response.permissionGranted){
      emit(HitchesLocationPermissionDeniedForever());
    }else{
      emit(HitchesInitialState());
    }
  }
}