import 'package:flutter/material.dart';
import 'package:workorders/models/product.dart';
import 'package:workorders/services/product_service.dart';

class ProductController extends ChangeNotifier {
  late bool isProcessing;
  late List<Product> products;

  ProductController() {
    isProcessing = false;
    products = [];
  }

  Future<void> getProducts() async {
    isProcessing = true;
    notifyListeners();
    try {
      products = await ProductService.select();
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
