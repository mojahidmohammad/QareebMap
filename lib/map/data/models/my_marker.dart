import 'dart:ui' as ui;

import 'package:drawable_text/drawable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:image_multi_type/image_multi_type.dart';
import 'package:map_package/map/util.dart';
import 'package:qareeb_models/global.dart';
import 'package:qareeb_models/points/data/model/trip_point.dart';

import '../../../generated/assets.dart';

import 'package:widget_to_marker/widget_to_marker.dart';

class MyMarker {
  final LatLng point;
   int? markerKey;
  final double bearing;
  final MyMarkerType type;
  final Size markerSize;
  Widget? costumeMarker;
  dynamic item;
  Function(dynamic item)? onTapMarker;

  MyMarker({
    required this.point,
     this.markerKey,
    this.bearing = 0,
    this.type = MyMarkerType.location,
    this.item,
    this.markerSize = const Size(100.0, 100.0),
    this.onTapMarker,
    this.costumeMarker,
  });

  Future<BitmapDescriptor> getBitmapFromType(MyMarkerType type, int index) async {
    if (costumeMarker != null) {
      return costumeMarker!.toBitmapDescriptor(
        logicalSize: markerSize,
        imageSize: markerSize,
      );
    }

    final imageMarker = ImageMultiType(
      url: (MyMarkerType.location == type || type == MyMarkerType.point) // normal marker
          ? Assets.iconsMainColorMarker
          : (type == MyMarkerType.bus || type == MyMarkerType.driver) // car marker
              ? Assets.iconsCarTopView
              : (type == MyMarkerType.sharedPint) // shred point
                  ? item is int
                      ? (item as int).iconPoint
                      : index.iconPoint
                  : '',
      height: 300.0.r,
      width: 300.0.r,
    );

    return imageMarker.toBitmapDescriptor(
      logicalSize: markerSize,
      imageSize: markerSize,
    );
  }

  Future<Marker> getMarker({
    required int index,
    required num key,
    Function(MyMarker marker)? onTapMarker,
  }) async {
    return Marker(
      markerId: MarkerId(key.toString()),
      position: point,
      anchor: const Offset(0.5, 0.5),
      icon: await getBitmapFromType(type, index),
      onTap: () => onTapMarker?.call(item),
    );
  }
}

class MyPolyLine {
  TripPoint? endPoint;
  int? key;
  String encodedPolyLine;
  Color? color;

  MyPolyLine({this.endPoint, this.key, this.encodedPolyLine = '', this.color});
}
