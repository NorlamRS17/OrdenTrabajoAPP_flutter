import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/services/session_service.dart';
import 'package:workorders/services/user_service.dart';
import 'package:workorders/utils/db_helper.dart';
import 'package:workorders/utils/utils.dart';

class SessionController extends ChangeNotifier {
  late bool isProcessing;

  SessionController() {
    isProcessing = false;
  }

  Future<void> login(String _user, String _pass) async {
    isProcessing = true;
    notifyListeners();
    try {
      User user = await SessionService.getLogin(_user.trim(), _pass.trim());
      await DBHelper.insert(user);
      await Utils.setSPString('user_id', user.id);
    } on DioError catch (e) {
      print("e.messagee.message");
print(e.message);
print(e.message);
      throw CustomException(e.message??"");
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  static Future<bool> isLogged() async {
    bool result = false;
    try {
      String? userId = await Utils.getSPString('user_id');
      if (userId != null && userId.isNotEmpty) {
        List<User> users = await UserService.select(id: userId);
        result = users.length > 0;
      }
    } catch (e) {}
    return result;
  }

  static Future<bool> logout() async {
    bool? result = await Utils.removeSPString('user_id');
    return result == true;
  }
}
