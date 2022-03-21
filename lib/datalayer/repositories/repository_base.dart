

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class BaseTrandryRepository {

}

class BaseBackendClient {

  late final Future<void> Function()? onAccessTokenExpired;
  late final Function()? onRefreshTokenExpired;

  String getApiUrl() {
    //return BackApiConst.backendBaseApi;
    throw Exception();
  }

  Future<Map> makeDeleteResponse(String method, {Map<String, dynamic>? query}) async {
    final headers = await getHeaders(isDelete: true);
    final uri = Uri.http(getApiUrl(), method, query);
    var response = await delete(uri, headers: headers);
    final message = utf8.decode(response.bodyBytes);
    print('DELETE Request -- address: $uri with code: ' + response.statusCode.toString());
    if (response != null && response.statusCode == 200) {
      return json.decode(response.body);
    }
    if (response.statusCode == 403) {
      throw RefreshTokenExpiredException(data: response, message: message);
    }
    if (response.statusCode == 401) {
      print('Access token expired');
      await onAccessTokenExpired!();
      var response = await delete(uri, headers: headers);
      final message = utf8.decode(response.bodyBytes);
      if (response != null && response.statusCode == 200) {
        return json.decode(response.body);
      }
      if (response.statusCode == 403) {
        throw RefreshTokenExpiredException(data: response, message: message);
      }
    }
    throw UnknownServerException(data: response, message: message);
  }

  Future<Map<String, dynamic>> makeGetResponse(String method, {Map<String, dynamic>? queryParam}) async {
    print('GET Request address: ${getApiUrl() + method}');
    print('GET Request query: $queryParam');
    queryParam?.removeWhere((key, value) => value == null);
    final headers = await getHeaders();
    final uri = Uri.http(getApiUrl(), method, queryParam);
    var response = await get(uri, headers: headers);
    final message = utf8.decode(response.bodyBytes);
    print('GET Request code: ' + response.statusCode.toString() + ' For uri: $uri');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    if (response.statusCode == 403) {
      throw RefreshTokenExpiredException(data: response, message: message);
    }
    if (response.statusCode == 401) {
      print('Access token expired');
      await onAccessTokenExpired!();
      var response = await get(uri, headers: headers);
      final message = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      if (response.statusCode == 403) {
        throw RefreshTokenExpiredException(data: response, message: message);
      }
    }
    throw UnknownServerException(data: response, message: message);

  }

  Future<Map<String, dynamic>> makePostResponse(String method, {Map<String, String>? queryParameters, Map<String, dynamic> body = const {}}) async {
    final headers = await getHeaders(isPost: true);
    print('POST Request -- body: ${jsonEncode(body)} API - $method');
    final uri = Uri.http(getApiUrl(), method, queryParameters);
    final response = await post(uri, body: jsonEncode(body), headers: headers);
    print('POST Request address: $uri with code: ' + response.statusCode.toString());
    final message = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    if (response.statusCode == 403 || message == '{"status":"error","message":"Token is expired"}') { // TODO Исправления на бэке
      throw RefreshTokenExpiredException(data: response, message: message);
    }
    if (response.statusCode == 401) {
      print('Access token expired');
      await onAccessTokenExpired!();
      final response = await post(uri, body: jsonEncode(body), headers: headers);
      final message = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      if (response.statusCode == 403 || message == '{"status":"error","message":"Token is expired"}') { // TODO Исправления на бэке
        throw RefreshTokenExpiredException(data: response, message: message);
      }
    }
    throw UnknownServerException(data: response, message: message);

  }

  /*Future<Map<String, dynamic>> makeMultipartResponse(String method, List<MultipartFile> files) async {
    final uri = Uri.https(getApiUrl(), method);
    final headers = await getHeaders(isPost: true);
    final request = MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.files.addAll(files);
    final response = await request.send();
    print('Multipart Request address: ${getApiUrl() + method} with code: ' + response.statusCode.toString());

    if (response != null && response.statusCode == 200) {
      final result = await response.stream.transform(utf8.decoder).single;
      return json.decode(result);
    } else {
      final body = await response.stream.bytesToString();
      throw await _handleServerError(body);
    }
  }*/


  Future<Map<String, String>> getHeaders({
    bool isPost = false,
    bool isDelete = false,
  }) async {
    //final token = await SecureStorageProvider().getAccessToken();
    const token = ""; // TODO
    final headers = <String, String>{'x-client-info': await generateClientInfo()};
    if (!isDelete) {
      headers[HttpHeaders.contentTypeHeader] = 'application/json';
      headers[HttpHeaders.acceptHeader] = 'application/json';
    }
    if (token != null) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer %s'.replaceAll('%s', token);
      //print(HttpHeaders.authorizationHeader + ': ' + Constants.TOKEN_HEADER.replaceAll('%s', token));
    } else {
      //assert(false, 'Token is null');
      print('Token is null');
    }
    print('Headers: $headers');
    return headers;
  }

  Future<String> generateClientInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final appName = packageInfo.appName;
    final packageName = packageInfo.packageName;
    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;
    final platform = Platform.isAndroid ? 'Android' : 'iOS';
    final time = DateTime.now().toIso8601String();

    return '$appName/$version (bundle: $packageName; build: $buildNumber; ocName: $platform; ocVersion: ${Platform.operatingSystemVersion}; time: $time)';
  }
}

class RefreshTokenExpiredException implements Exception {
  final dynamic data;
  final String message;
  RefreshTokenExpiredException({required this.data, required this.message});
}

class UnknownServerException implements Exception {
  final dynamic data;
  final String message;
  UnknownServerException({required this.data, required this.message});
}