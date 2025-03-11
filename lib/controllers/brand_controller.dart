import 'package:flutter/material.dart';
import 'package:workorders/models/brand.dart';
import 'package:workorders/services/brand_service.dart';

class BrandController extends ChangeNotifier {
  late bool isProcessing;
  late List<Brand> brands;

  BrandController() {
    isProcessing = false;
    brands = [];
  }

  Future<void> getBrands() async {
    isProcessing = true;
    notifyListeners();
    try {
      brands = await BrandService.select();
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
