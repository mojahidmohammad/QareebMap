part of 'search_location_cubit.dart';

class SearchLocationInitial extends AbstractState<List<SearchLocationResult>> {


  const SearchLocationInitial({
    required super.statuses,
    required super.result,
    required super.error,
    required super.request,
  });

  factory SearchLocationInitial.initial() {
    return const SearchLocationInitial(
      result: [],
      error: '',
      request: '',
      statuses: CubitStatuses.init,
    );
  }

  @override
  List<Object> get props => [statuses, result, error];

  SearchLocationInitial copyWith({
    CubitStatuses? statuses,
    List<SearchLocationResult>? result,
    String? error,
    String? request,
  }) {
    return SearchLocationInitial(
      statuses: statuses ?? this.statuses,
      result: result ?? this.result,
      error: error ?? this.error,
      request: request ?? this.request,
    );
  }
}
