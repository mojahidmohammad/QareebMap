part of 'my_location_cubit.dart';

class MyLocationInitial extends AbstractState<LatLng> {
  const MyLocationInitial({
    required super.result,
    required super.error,
    required super.statuses,
  });

  factory MyLocationInitial.initial() {
    return const MyLocationInitial(
      result: LatLng(0, 0),
      error: '',
      statuses: CubitStatuses.init,
    );
  }

  @override
  List<Object?> get props => [result, error, statuses];

  MyLocationInitial copyWith({
    LatLng? result,
    CubitStatuses? statuses,
    String? error,
  }) {
    return MyLocationInitial(
      result: result ?? this.result,
      statuses: statuses ?? this.statuses,
      error: error ?? this.error,
    );
  }


}
