import 'dart:convert';

import 'package:m_cubit/m_cubit.dart';
import 'package:qareeb_models/extensions.dart';

import '../../../api_manager/api_service.dart';
import '../../../api_manager/pair_class.dart';
import '../../../api_manager/server_proxy/server_proxy_request.dart';
import '../../../api_manager/server_proxy/server_proxy_service.dart';
import '../../data/response/search_location_response.dart';

part 'search_location_state.dart';

class SearchLocationCubit extends MCubit<SearchLocationInitial> {
  SearchLocationCubit() : super(SearchLocationInitial.initial());

  @override
  String get nameCache => 'SearchLocationCubit';

  @override
  String get filter => state.filter;

  @override
  int get timeInterval => 200;

  Future<void> searchLocation({required String request}) async {
    if (request.isEmpty ||
        request.length < 3 ||
        request.removeSpace == state.request.removeSpace) {
      emit(state.copyWith(statuses: CubitStatuses.done, result: []));
      return;
    }

    request = 'دمشق $request';
    getDataAbstract(
      fromJson: SearchLocationResult.fromJson,
      state: state,
      getDataApi: _searchLocationApi,
    );
  }

  Future<Pair<List<SearchLocationResult>?, String?>> _searchLocationApi() async {
    final pair = await getServerProxyApi(
      request: ApiServerRequest(
        url: APIService().getUri(
          url: 'search.php',
          hostName: 'nominatim.openstreetmap.org',
          query: {
            'q': state.request,
            'format': 'jsonv2',
            'countrycodes': 'sy',
            'accept-language': 'ar',
          },
        ).toString(),
        headers: {"Accept": "application/json", "User-Agent": "android"},
        method: 'Get',
      ),
    );

    if (pair.first != null) {
      return Pair(SearchLocationResponse.fromJson(jsonDecode(pair.first)).result, null);
    } else {
      return Pair(null, 'Error Map Server  code: ${pair.second}');
    }
  }
}
