
import 'package:collection/collection.dart';
import 'package:drawable_text/drawable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:map_package/map/bloc/map_controller_cubit/map_controller_cubit.dart';
import 'package:qareeb_models/extensions.dart';
import 'package:qareeb_models/global.dart';
import 'package:qareeb_models/trip_path/data/models/trip_path.dart';
import 'package:qareeb_models/trip_process/data/response/trip_response.dart';

import '../generated/assets.dart';
import 'data/models/my_marker.dart';


const initialPoint = LatLng(33.514631885313264, 36.27654397981723);

const initialPointBaghdad = LatLng(33.313120604340895, 44.37581771812867);

const singleMarkerKey = -5622;

extension PathMap on TripPath {
  List<MyMarker> getMarkers({Function(dynamic item)? onTapMarker}) {
    final list = <MyMarker>[];
    edges.forEachIndexed(
      (i, e) {
        if (i == 0) {
          list.add(
            MyMarker(
              item: i,
              point: e.startPoint.getLatLng,
              markerKey: e.startPoint.getLatLng.hashCode,
              type: MyMarkerType.sharedPint,
            ),
          );
        }

        list.add(
          MyMarker(
            item: i + 1,
            markerKey: e.startPoint.getLatLng.hashCode,
            point: e.endPoint.getLatLng,
            type: MyMarkerType.sharedPint,
            onTapMarker: onTapMarker,
          ),
        );
      },
    );

    return list;
  }

  List<MyPolyLine> getPolyLines() {
    final list = <MyPolyLine>[];

    edges.forEachIndexed((i, e) {
      list.add(MyPolyLine(key: i, encodedPolyLine: e.steps, color: getColor(i)));
    });

    return list;
  }
}

extension IconPoint on num {
  String get iconPoint {
    final data = toInt() + 1;
    switch (data) {
      case 1:
        return Assets.icons1;
      case 2:
        return Assets.icons2;
      case 3:
        return Assets.icons3;
      case 4:
        return Assets.icons4;
      case 5:
        return Assets.icons5;
      case 6:
        return Assets.icons6;
      case 7:
        return Assets.icons7;
      case 8:
        return Assets.icons8;
      case 9:
        return Assets.icons9;
      case 10:
        return Assets.icons10;
      case 11:
        return Assets.icons11;
      case 12:
        return Assets.icons12;
      case 13:
        return Assets.icons13;
      case 14:
        return Assets.icons14;
      case 15:
        return Assets.icons15;
      case 16:
        return Assets.icons16;
      case 17:
        return Assets.icons17;
      case 18:
        return Assets.icons18;
      case 19:
        return Assets.icons19;
      case 20:
        return Assets.icons20;
      case 21:
        return Assets.icons21;
      case 22:
        return Assets.icons22;
      case 23:
        return Assets.icons23;
      case 24:
        return Assets.icons24;
      case 25:
        return Assets.icons25;
      case 26:
        return Assets.icons26;
    }
    return Assets.icons26;
  }
}

extension NormalTripMap on Trip {
  List<MyMarker> getMarkers() {
    return [
      MyMarker(
          point: startPoint,
          type: MyMarkerType.sharedPint,
          markerKey: startPoint.hashCode),
      MyMarker(
          point: endPoint, type: MyMarkerType.sharedPint, markerKey: endPoint.hashCode),
      if (preAcceptPoint != null)
        MyMarker(
            point: preAcceptPoint!,
            costumeMarker: 0.0.verticalSpace,
            markerKey: preAcceptPoint!.hashCode),
    ];
  }
}

class PathLengthWidget extends StatelessWidget {
  const PathLengthWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0.r),
      ),
      margin: EdgeInsets.only(bottom: 20.0.h),
      alignment: Alignment.center,
      child: Text(
        text,
        style:const  TextStyle(
          color: Colors.black,

        ),
      ),
    );
  }
}
