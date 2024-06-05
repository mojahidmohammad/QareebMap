
class PostUrl {
  static const serverProxy =
      'api/services/app/HttpRequestService/ExecuteRequest';
}

String get baseUrl {
  // return liveUrl;
  return testLocal1Url;
}

const liveUrl = 'live.qareeb-maas.com';
const testUrl = 'qareeb-api.first-pioneers.com.tr';
const testLocal1Url = 'demo1.qareeb-maas.com';

