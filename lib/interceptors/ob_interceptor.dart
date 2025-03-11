import 'dart:io';
import 'package:dio/dio.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/utils.dart';

class OBInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[HttpHeaders.authorizationHeader] = Utils.getBasicAuth();
    options.headers[HttpHeaders.contentTypeHeader] = "application/json";
    options.baseUrl = OB_API_URL;
    options.connectTimeout = Duration(milliseconds: 60000);
    options.receiveTimeout =  Duration(milliseconds: 60000);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);

    if (response.statusCode == 200) {
      var _result = response.data['response'];
      if (_result['status'] != 0) {
        String _message = _result.containsKey('error')
            ? _result['error']['message']
            : _result['errors'].toString();
        throw CustomException(_message);
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
