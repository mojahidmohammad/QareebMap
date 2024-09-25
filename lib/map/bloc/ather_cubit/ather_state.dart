part of 'ather_cubit.dart';

class AtherInitial extends Equatable {
  final MapCubitStatuses statuses;
  final List<Ime> result;
  final String error;

  const AtherInitial({
    required this.statuses,
    required this.result,
    required this.error,
  });

  factory AtherInitial.initial() {
    return const AtherInitial(
      result: [],
      error: '',
      statuses: MapCubitStatuses.init,
    );
  }

  @override
  List<Object> get props => [statuses, result, error];

  AtherInitial copyWith({
    MapCubitStatuses? statuses,
    List<Ime>? result,
    String? error,
  }) {
    return AtherInitial(
      statuses: statuses ?? this.statuses,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }

}
