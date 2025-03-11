import 'package:sqflite/sqflite.dart';
import 'package:dio/dio.dart';

import 'package:workorders/interceptors/ob_interceptor.dart';
import 'package:workorders/models/model.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/db_helper.dart';

abstract class ModelService {
  static Future<List<Model>> getModels() async {
    String _path = "/$JSON_REST/${Model.sEntityName}";

    Dio _dio = Dio();
    _dio.interceptors.addAll([
      OBInterceptor(),
    ]);
    Response _response = await _dio.get(_path);
    var _data = _response.data['response']['data'];

    List<Model> _brands = List.generate(_data.length, (i) {
      return Model.fromJson(_data[i]);
    });

    return _brands;
  }

  static Future<List<Model>> select(String? brandId) async {
    Database? _db = await DBHelper.db;

    String? _where;
    List<String> _whereArgs = [];
    if (brandId != null) {
      _where = 'brand_id = ?';
      _whereArgs.add(brandId);
    }

    List<Map<String, dynamic>> maps =
        await _db.query(Model.sModelName, where: _where, whereArgs: _whereArgs, orderBy: 'name');
    return List.generate(maps.length, (i) {
      return Model.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> insertFromSync(Model _model) async {
    Database _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db
        .query(_model.modelName, where: " id = ? ", whereArgs: [_model.id]);
    List result = List.generate(maps.length, (i) {
      return Model.fromJsonSQLite(maps[i]);
    });

    if (result.isEmpty) {
      await _db.insert(
        _model.modelName,
        _model.toMapSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
