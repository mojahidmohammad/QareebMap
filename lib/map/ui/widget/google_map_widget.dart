import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:drawable_text/drawable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_multi_type/image_multi_type.dart';
import 'package:map_package/api_manager/api_service.dart';
import 'package:qareeb_models/global.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'dart:math' as math;
import '../../../generated/assets.dart';
import '../../bloc/ather_cubit/ather_cubit.dart';
import '../../bloc/map_controller_cubit/map_controller_cubit.dart';

import '../../bloc/my_location_cubit/my_location_cubit.dart';
import '../../data/models/my_marker.dart';
import '../../data/response/ather_response.dart';
import '../../util.dart';
import 'package:http/http.dart' as http;

bool isAppleTestFromMapPackage = false;

final List<String> imeis = [];

class GMapWidget extends StatefulWidget {
  const GMapWidget({
    Key? key,
    this.onMapReady,
    this.initialPoint,
    this.search,
    this.updateMarkerWithZoom,
    this.onMapClick,
    this.atherListener = true,
  }) : super(key: key);

  final Function(GoogleMapController controller)? onMapReady;
  final Function(LatLng latLng)? onMapClick;
  final Function()? search;
  final LatLng? initialPoint;
  final bool? updateMarkerWithZoom;
  final bool atherListener;

  static initImeis(List<String> imei) => imeis
    ..clear()
    ..addAll(imei)
    ..removeWhere((element) => element.isEmpty);

  GlobalKey<GMapWidgetState> getKey() {
    return GlobalKey<GMapWidgetState>();
  }

  @override
  State<GMapWidget> createState() => GMapWidgetState();
}

class GMapWidgetState extends State<GMapWidget> with TickerProviderStateMixin {
  late MapControllerCubit mapControllerCubit;

  final mapWidgetKey = GlobalKey();

  Timer? timer;

  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};
  Uint8List? markerIcon;
  Future<Uint8List> _getBytesFromNetworkImage(String url,
      {int width = 100}) async {
    final http.Response response = await http.get(Uri.parse(url));
    final ui.Codec codec = await ui.instantiateImageCodec(
      response.bodyBytes,
      targetWidth: width,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  Future<void> _loadCustomMarker() async {
    markerIcon = await _getBytesFromNetworkImage(
      'https://e7.pngegg.com/pngimages/840/61/png-clipart-google-map-maker-google-maps-computer-icons-map-collection-map-marker-angle-pin.png',
      // Replace with your image URL
      width: 100, // Width of the marker icon
    );
  }

  List<Ime> getNearestPoints(LatLng startLocation, List<Ime> points) {
    // Sort the points based on their distance from the start location
    points.sort((a, b) {
      double distanceToA = Geolocator.distanceBetween(
          startLocation.latitude, startLocation.longitude, a.lat, a.lng);
      double distanceToB = Geolocator.distanceBetween(
          startLocation.latitude, startLocation.longitude, b.lat, b.lng);
      return distanceToA.compareTo(distanceToB);
    });

    // Return the top 10 nearest points
    return points.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [

        // if (widget.atherListener )
        //   BlocListener<AtherCubit, AtherInitial>(
        //     listener: (context, state) async {
        //       final pos = await Geolocator.getCurrentPosition();
        //       final latLng = LatLng(pos.latitude, pos.longitude);
        //       markers.removeWhere((e) => e.markerId.value.startsWith('__'));
        //
        //       final list = state.result.map((e) async {
        //         final icon = await ImageMultiType(
        //           url: Assets.iconsCarTopView,
        //           height: 150.0.r,
        //           width: 150.0.r,
        //         ).toBitmapDescriptor(
        //           logicalSize: Size(150.0.r, 150.0.r),
        //           imageSize: Size(150.0.r, 150.0.r),
        //         );
        //         return Marker(
        //           //هون عم يتم تحديد ماركر السائق
        //           markerId: MarkerId('__${e.ime}'),
        //           position: latLng,
        //           icon: icon,
        //         );
        //       }).toList();
        //
        //       for (var e in list) {
        //         markers.add(await e);
        //       }
        //
        //       if (list.length == 1 && context.mounted) {
        //         mapLogger.w((state.result.first).getLatLng());
        //         context
        //             .read<MapControllerCubit>()
        //             .movingCamera(point: (state.result.first).getLatLng());
        //       }
        //
        //       setState(() {});
        //     },
        //   ),
        BlocListener<AtherCubit, AtherInitial>(
          listener: (context, state) async {
            final myLocation = context.read<MyLocationCubit>().state.result;

            final markers = getNearestPoints(myLocation, state.result).map(
              (e) {
                return MyMarker(
                  point: e.getLatLng(),
                  markerSize: Size(90.0.r, 90.0.r),
                  type: MyMarkerType.location,
                );
              },
            ).toList();
            context.read<MapControllerCubit>().addMarkers(
                  markers: markers,
                  update: true,
                  centerZoom: true,
                );
          },
        ),
        BlocListener<MyLocationCubit, MyLocationInitial>(
          listenWhen: (p, c) => (c.done),
          listener: (context, state) {
            context.read<MapControllerCubit>().addSingleMarker(
                  marker: MyMarker(
                    type: MyMarkerType.driver,
                    point: state.result,
                    markerSize: Size(90.0.r, 90.0.r),
                  ),
                  moveTo: true,
                );
          },
        ),

        BlocListener<MapControllerCubit, MapControllerInitial>(
          listenWhen: (p, c) => p.markerNotifier != c.markerNotifier,
          listener: (context, state) async {
            final pos = await Geolocator.getCurrentPosition();
            final latLng = LatLng(pos.latitude, pos.longitude);
            final listMarkers = await initMarker(state);
            markers.removeWhere((e) => !e.markerId.value.startsWith('__'));
            final icon = await ImageMultiType(
              url: Assets.iconsCarTopView,
              height: 150.0.r,
              width: 150.0.r,
            ).toBitmapDescriptor(
              logicalSize: Size(150.0.r, 150.0.r),
              imageSize: Size(150.0.r, 150.0.r),
            );

            List<Marker> markerRest = [
              Marker(
                //هون عم يتم تحديد ماركر السائق
                markerId: MarkerId('1'),
                position: latLng,
                icon: icon,
              ),
              // Marker(
              //   //هون عم يتم تحديد ماركر السائق
              //     markerId: MarkerId('2'),
              //     position: LatLng(33.5026205, 36.237409),
              //     icon: BitmapDescriptor.fromBytes(markerIcon!),
              //     onTap: () {
              //       showModalBottomSheet(
              //         isScrollControlled: true,
              //         isDismissible: false,
              //         context: context,
              //         builder: (context) {
              //           return restaurantButtonSheet();
              //         },
              //       );
              //     }),
              // Marker(
              //   //هون عم يتم تحديد ماركر السائق
              //     markerId: MarkerId('3'),
              //     position: LatLng(33.5170502, 36.2367966),
              //     icon: BitmapDescriptor.fromBytes(markerIcon!),
              //     onTap: () {
              //       showModalBottomSheet(
              //         isScrollControlled: true,
              //         isDismissible: false,
              //         context: context,
              //         builder: (context) {
              //           return restaurantButtonSheet();
              //         },
              //       );
              //     }),
            ];
            for (var e in markerRest) {
              markers.add(e);
            }
            for (var e in listMarkers) {
              markers.add(await e);
            }
            if (mounted) setState(() {});
          },
        ),
        BlocListener<MapControllerCubit, MapControllerInitial>(
          listenWhen: (p, c) => p.polylineNotifier != c.polylineNotifier,
          listener: (context, state) async {
            polyLines
              ..clear()
              ..addAll(initPolyline(state));
            setState(() {});
          },
        ),
        BlocListener<MapControllerCubit, MapControllerInitial>(
          listener: (context, state) async {
            final pos = await Geolocator.getCurrentPosition();
            if (state.point != null) {
              print ("state.point");
              mapLogger.w(state.point ?? initialPoint);
              await mapControllerCubit.controller?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(pos.latitude, pos.longitude),
                    zoom: state.zoom,
                  ),
                ),
              );
            }

            if (state.centerZoomPoints.isNotEmpty) {
              print ("state.centerZoomPoints");
              final bound = calculateLatLngBounds(state.centerZoomPoints);

              final midpoint = LatLng(
                (bound.southwest.latitude + bound.northeast.latitude) / 2,
                (bound.southwest.longitude + bound.northeast.longitude) / 2,
              );

              await mapControllerCubit.controller?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(pos.latitude, pos.longitude),
                    zoom: getZoomLevel(
                      bound.southwest,
                      bound.northeast,
                      mapWidgetKey.currentContext?.size?.width ?? 1.0.sw,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ],
      child: GoogleMap(
        key: mapWidgetKey,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: widget.initialPoint ?? initialPoint,
          zoom: 13.0,
        ),
        minMaxZoomPreference: const MinMaxZoomPreference(0, 16.5),
        onMapCreated: (controller) {
          widget.onMapReady?.call(controller);
          mapControllerCubit.setGoogleMap(controller);

          mapControllerCubit.controller?.animateCamera(
            CameraUpdate.newCameraPosition(CameraPosition(
              target: widget.initialPoint ?? initialPoint,
              zoom: 13.0,
            )),
          );
        },
        onTap: (argument) => widget.onMapClick?.call(argument),
        markers: markers,

        polylines: polyLines,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    ///initial map controller
    mapControllerCubit = context.read<MapControllerCubit>();
    context.read<AtherCubit>().getDriverLocation(imeis);
    _loadCustomMarker();
    if (widget.atherListener) {
      timer = Timer.periodic(
        Duration(
          seconds: 15,
          hours: isAppleTestFromMapPackage ? 10 : 0,
        ),
        (timer) {
          if (!mounted) return;
          context.read<AtherCubit>().getDriverLocation(imeis);
        },
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    mapControllerCubit.controller?.dispose();
    mapControllerCubit.setGoogleMap(null);
    super.dispose();
  }

  Future<List<Future<Marker>>> initMarker(MapControllerInitial state) async {
    return state.markers.keys.mapIndexed(
      (i, key) async {
        return await state.markers[key]!.getMarker(
          index: i,
          key: key,
        );
      },
    ).toList();
  }

  List<Polyline> initPolyline(MapControllerInitial state) {
    return state.polyLines.values.mapIndexed(
      (i, e) {
        return Polyline(
          points: e.first,
          color: e.second,
          width: 5.0.r.toInt(),
          polylineId: PolylineId(e.hashCode.toString()),
        );
      },
    ).toList();
  }
}

//---------------------------------------

LatLngBounds calculateLatLngBounds(List<LatLng> latLngList) {
  double minLat = 90.0;
  double maxLat = -90.0;
  double minLng = 180.0;
  double maxLng = -180.0;

  for (LatLng latLng in latLngList) {
    minLat = math.min(minLat, latLng.latitude);
    maxLat = math.max(maxLat, latLng.latitude);
    minLng = math.min(minLng, latLng.longitude);
    maxLng = math.max(maxLng, latLng.longitude);
  }

  LatLng southwest = LatLng(minLat, minLng);
  LatLng northeast = LatLng(maxLat, maxLng);

  return LatLngBounds(southwest: southwest, northeast: northeast);
}

Widget restaurantButtonSheet() {
  return Container(
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
    height: 800.h,
    child: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 300.h,
            child: Stack(
              children: [
                ImageMultiType(
                  url:
                      "https://mir-s3-cdn-cf.behance.net/projects/404/94c37759271923.Y3JvcCwxNjU4LDEyOTcsMCw4Mzk.jpg",
                  height: 200.r,
                  width: double.infinity,
                ),
                Positioned(
                    bottom: 20,
                    right: 10,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          minRadius: 75,
                          maxRadius: 75,
                          backgroundImage: NetworkImage(
                            'https://mir-s3-cdn-cf.behance.net/projects/404/a2a31168327603.Y3JvcCwxNjE2LDEyNjQsMTkyLDM1Ng.jpg',
                          ),
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DrawableText.header(
                              text: "big Tasty ",
                            ),
                            DrawableText.title(text: "تصنيف : مطعم ")
                          ],
                        )
                      ],
                    )),
              ],
            ),
          ),
          Container(
            margin:
                const EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 20),
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
          ),
          Container(
            margin:
                const EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 20),
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
          ),
          Container(
            margin:
                const EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 20),
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
          ),
          Container(
            margin:
                const EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 20),
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
