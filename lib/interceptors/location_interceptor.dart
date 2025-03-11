import 'dart:io';
import 'package:dio/dio.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/utils/constants.dart';

class LocationInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[HttpHeaders.contentTypeHeader] = "application/json";
    options.baseUrl = LOCATION_API_URL;
    options.connectTimeout = Duration(seconds: LOCATION_TIMEOUT);
    options.receiveTimeout = Duration(seconds: LOCATION_TIMEOUT);;

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);

    if (response.statusCode == 200) {
      var _result = response.data['response'];
      if (_result['status'] != 0) {
        throw CustomException(_result['error']['message']);
      }
    }
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);

    if (err.response?.statusCode == 401) {
      throw CustomException('Conexión no autorizada');
    } else if (err.response?.statusCode == 404) {
      throw CustomException('Recurso no disponible');
    } else {
      throw CustomException(err.message??"");
    }
  }
}
