import 'package:flutter/material.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/services/user_service.dart';

class UserController extends ChangeNotifier {
  late bool isProcessing;
  late List<User> users;

  UserController() {
    isProcessing = false;
    users = [];
  }

  Future<void> getUsers() async {
    isProcessing = true;
    notifyListeners();
    try {
      users = await UserService.select();
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<User?> getUser(String _username) async {
    User? _user;
    try {
      users = await UserService.selectByUsername(username: _username.trim());
      if (users.isNotEmpty) {
        _user = users[0];
      }
    } catch (e) {
      rethrow;
    }
    return _user;
  }

  Future<User?> getCurrentUser() async {
    User? _currentUser;
    try {
      _currentUser = await UserService.current();
    } catch (e) {
      rethrow;
    }
    return _currentUser;
  }
}
