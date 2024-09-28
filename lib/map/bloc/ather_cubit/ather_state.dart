part of 'ather_cubit.dart';

class AtherInitial extends AbstractState<List<Ime>> {
  List<String> get mRequest => request;

  const AtherInitial({
    required super.statuses,
    required super.result,
    required super.error,
    super.request,
  });

  factory AtherInitial.initial() {
    return const AtherInitial(
      result: [],
      error: '',
      statuses: CubitStatuses.init,
    );
  }

  @override
  List<Object> get props => [statuses, result, error, if (request != null) request];

  AtherInitial copyWith({
    CubitStatuses? statuses,
    List<Ime>? result,
    List<String>? request,
    String? error,
  }) {
    return AtherInitial(
      statuses: statuses ?? this.statuses,
      result: result ?? this.result,
      error: error ?? this.error,
      request: request ?? this.request,
    );
  }
}
