import 'package:sqflite/sqflite.dart';
import 'package:dio/dio.dart';

import 'package:workorders/interceptors/ob_interceptor.dart';
import 'package:workorders/models/brand.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/db_helper.dart';

abstract class BrandService {
  static Future<List<Brand>> getBrands() async {
    String _path = "/$JSON_REST/${Brand.sEntityName}";

    Dio _dio = Dio();
    _dio.interceptors.addAll([
      OBInterceptor(),
    ]);
    Response _response = await _dio.get(_path);
    var _data = _response.data['response']['data'];

    List<Brand> _brands = List.generate(_data.length, (i) {
      return Brand.fromJson(_data[i]);
    });

    return _brands;
  }

  static Future<List<Brand>> select({String? id}) async {
    Database? _db = await DBHelper.db;

    String? _where;
    List<String> _whereArgs = [];
    if (id != null) {
      _where = 'id = ?';
      _whereArgs.add(id);
    }

    List<Map<String, dynamic>> maps =
        await _db.query(Brand.sModelName, where: _where, whereArgs: _whereArgs, orderBy: 'name');
    return List.generate(maps.length, (i) {
      return Brand.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> insertFromSync(Brand _brand) async {
    Database _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db
        .query(_brand.modelName, where: " id = ? ", whereArgs: [_brand.id]);
    List result = List.generate(maps.length, (i) {
      return Brand.fromJsonSQLite(maps[i]);
    });

    if (result.isEmpty) {
      await _db.insert(
        _brand.modelName,
        _brand.toMapSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
