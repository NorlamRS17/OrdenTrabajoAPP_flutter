import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  late bool isProcessing;
  int index;

  HomeController({required this.index}) {
    isProcessing = false;
  }

  Future<void> setBottomNavigationBarIndex(int _index) async {
    index = _index;
    notifyListeners();
  }
}
