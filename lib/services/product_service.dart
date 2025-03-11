import 'package:sqflite/sqflite.dart';
import 'package:dio/dio.dart';

import 'package:workorders/interceptors/ob_interceptor.dart';
import 'package:workorders/models/product.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/db_helper.dart';

abstract class ProductService {
  static Future<List<Product>> getProducts() async {
    String _path =
        "/$JSON_REST/${Product.sEntityName}?_where=sotpeExpensereport=true";

    Dio _dio = Dio();
    _dio.interceptors.addAll([
      OBInterceptor(),
    ]);
    Response _response = await _dio.get(_path);
    var _data = _response.data['response']['data'];

    List<Product> _products = List.generate(_data.length, (i) {
      return Product.fromJson(_data[i]);
    });

    return _products;
  }

  static Future<List<Product>> select({String? id}) async {
    Database? _db = await DBHelper.db;

    String? _where;
    List<String> _whereArgs = [];
    if (id != null) {
      _where = 'id = ?';
      _whereArgs.add(id);
    }

    List<Map<String, dynamic>> maps = await _db.query(Product.sModelName,
        where: _where, whereArgs: _whereArgs);
    return List.generate(maps.length, (i) {
      return Product.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> insertFromSync(Product _product) async {
    Database _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db
        .query(_product.modelName, where: " id = ? ", whereArgs: [_product.id]);
    List result = List.generate(maps.length, (i) {
      return Product.fromJsonSQLite(maps[i]);
    });

    if (result.isEmpty) {
      await _db.insert(
        _product.modelName,
        _product.toMapSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
