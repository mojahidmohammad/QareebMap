import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:m_cubit/m_cubit.dart';

import 'package:qareeb_models/global.dart';

import '../ather_cubit/ather_cubit.dart';

part 'my_location_state.dart';

class MyLocationCubit extends Cubit<MyLocationInitial> {
  MyLocationCubit() : super(MyLocationInitial.initial());

  Future<void> getMyLocation({bool? latestLocation}) async {
    if (!(await _checkLocationsService)) return;

    emit(state.copyWith(statuses: CubitStatuses.loading));

      final pos = (latestLocation == true)
          ? await Geolocator.getLastKnownPosition()
          : await Geolocator.getCurrentPosition();

      if (pos != null) {
        final latLng = LatLng(pos.latitude, pos.longitude);
      emit(state.copyWith(result: latLng, statuses: CubitStatuses.done));
    } else {
      emit(state.copyWith(error: 'Error My Location ', statuses: CubitStatuses.error));
    }
  }

  Future<bool> get _checkLocationsService async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(state.copyWith(
          error: 'Location services are disabled.', statuses: CubitStatuses.error));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(state.copyWith(
            error: 'Location permissions are denied', statuses: CubitStatuses.error));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(state.copyWith(
        error:
            'Location permissions are permanently denied,we cannot request permissions.',
        statuses: CubitStatuses.error,
      ));
      return false;
    }
    return true;
  }
}
