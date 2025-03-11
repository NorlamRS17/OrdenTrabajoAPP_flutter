import 'package:dio/dio.dart';
import 'package:workorders/exceptions/custom_exception.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);

    if (response.statusCode == 200) {
      var _result = response.data['response'];
      if (_result['data'] == null || _result['data'].length == 0) {
        // final error = DioError(
        //     requestOptions: response.requestOptions,
        //     response: response,
        //     type: DioErrorType.other);
        // return handler.reject(error);
        throw CustomException('Usuario o contraseña incorrecta');
      }
    }
  }
}
