import 'package:dio/dio.dart';
import 'package:workorders/interceptors/auth_interceptor.dart';
import 'package:workorders/interceptors/ob_interceptor.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/utils/constants.dart';

abstract class SessionService {
  static Future<User> getLogin(String _user, String _pass) async {
    String _path =
        "/$JSON_REST/${User.sEntityName}?_where=active=true AND sotpeIstechnical=true AND username='$_user' AND sotpePassword='$_pass'";
    Dio _dio = Dio();
    _dio.interceptors.addAll([
      AuthInterceptor(),
      OBInterceptor(),
    ]);
    Response _response = await _dio.get(_path);
    var _data = _response.data['response']['data'];
    User user = User.fromJson(_data[0]);
    return user;
  }
}
