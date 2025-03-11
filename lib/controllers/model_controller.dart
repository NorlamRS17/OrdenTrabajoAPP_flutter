import 'package:flutter/material.dart';
import 'package:workorders/models/model.dart';
import 'package:workorders/services/model_service.dart';

class ModelController extends ChangeNotifier {
  late bool isProcessing;
  late List<Model> models;

  ModelController() {
    isProcessing = false;
    models = [];
  }

  Future<void> getModels(String? brandId) async {
    isProcessing = true;
    notifyListeners();
    try {
      models = await ModelService.select(brandId);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
