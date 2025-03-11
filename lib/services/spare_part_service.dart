import 'package:dio/dio.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/interceptors/ob_interceptor.dart';
import 'package:workorders/models/spare_part.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/services/user_service.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

abstract class SparePartService {
  static Future<List<SparePart>> getSpareParts(
      {String? dateStart, String? dateEnd}) async {
    User? _user = await UserService.current();

    String _path =
        "/$JSON_REST/${SparePart.sEntityName}?_where=projectTask.projectPhase.project.projectStatus!='OP' AND projectTask.projectPhase.project.personInCharge.id='${_user?.businessPartnerId}'";
    if (dateStart != null) {
      _path +=
          " AND projectTask.projectPhase.project.creationDate>='$dateStart' ";
    }
    if (dateEnd != null) {
      _path +=
          " AND projectTask.projectPhase.project.creationDate<='$dateEnd' ";
    }

    Dio _dio = Dio();
    _dio.interceptors.addAll([
      OBInterceptor(),
    ]);
    Response _response = await _dio.get(_path);
    var _data = _response.data['response']['data'];

    List<SparePart> _spareParts = List.generate(_data.length, (i) {
      return SparePart.fromJson(_data[i]);
    });

    return _spareParts;
  }

  static Future<SparePart> postSparePart(SparePart sparePart) async {
    SyncUp _syncUp = sparePart.syncUp;
    String? _phoneId = sparePart.phoneId;
    try {
      String _path = "/$JSON_REST/${SparePart.sEntityName}";

      Dio _dio = Dio();
      _dio.interceptors.addAll([
        OBInterceptor(),
      ]);
      final _body = sparePart.toMap();
      Response _response;
      try {
        _response = await _dio.post(_path, data: {'data': _body});
      } on DioError catch (e) {
        throw CustomException(e.message??"");
      }
      var _data = _response.data['response']['data'];
      SparePart _sparePart = SparePart.fromJson(_data[0]);
      sparePart = _sparePart;
      _syncUp.isRequired = false;
      _syncUp.date = DateTime.now();
      sparePart.syncUp = _syncUp;
      sparePart.phoneId = _phoneId;
      await update(sparePart);
    } catch (e) {
      _syncUp.date = DateTime.now();
      _syncUp.status = 'ERROR';
      _syncUp.error = e.toString();
      sparePart.syncUp = _syncUp;
      await update(sparePart);
      rethrow;
    }

    return sparePart;
  }

  static Future<List<SparePart>> selectByProjectTask(
      {required String projectTaskId}) async {
    Database? _db = await DBHelper.db;
    List<Map<String, dynamic>> maps = await _db.query(SparePart.sModelName,
        where: ' project_task_id = ? ', whereArgs: [projectTaskId]);
    return List.generate(maps.length, (i) {
      return SparePart.fromJsonSQLite(maps[i]);
    });
  }

  static Future<SparePart> insert(SparePart _sparePart) async {
    Database _db = await DBHelper.db;

    var _uuid = const Uuid();
    DateTime _date = DateTime.now();

    _sparePart.phoneId = _uuid.v4();
    _sparePart.created = _date;
    _sparePart.updated = _date;

    await _db.insert(
      _sparePart.modelName,
      _sparePart.toMapSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return _sparePart;
  }

  static Future<void> update(SparePart _sparePart) async {
    Database? _db = await DBHelper.db;

    String? _id = _sparePart.id;
    String? _phoneId = _sparePart.phoneId;
    String _query = '';
    List<String> _args = [];
    if (_id != null &&
        _id.isNotEmpty &&
        _phoneId != null &&
        _phoneId.isNotEmpty) {
      _query = ' (id = ? OR phone_id = ?) ';
      _args.add(_id);
      _args.add(_phoneId);
    } else if (_id != null && _id.isNotEmpty) {
      _query = ' id = ? ';
      _args.add(_sparePart.id!);
    } else {
      _query = ' phone_id = ? ';
      _args.add(_sparePart.phoneId!);
    }

    DateTime _date = DateTime.now();
    _sparePart.updated = _date;

    await _db.update(
      _sparePart.modelName,
      _sparePart.toMapSQLite(),
      where: _query,
      whereArgs: _args,
    );
  }

  static Future<List<SparePart>> selectToSync() async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    List<Map<String, dynamic>> maps = await _db.rawQuery(
        " SELECT sp.* FROM spare_parts sp JOIN project_tasks pt ON pt.id = sp.project_task_id JOIN project_phases pp ON pp.id = pt.project_phase_id JOIN projects p ON p.id = pp.project_id WHERE p.person_in_charge_id = ? AND sp.sync_up = 1 ORDER BY p.created, p.id ",
        [_user?.businessPartnerId]);
    return List.generate(maps.length, (i) {
      return SparePart.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> insertFromSync(SparePart _sparePart) async {
    Database _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(_sparePart.modelName,
        where: " id = ? AND sync_up_status = 'ERROR' ",
        whereArgs: [_sparePart.id]);
    List result = List.generate(maps.length, (i) {
      return SparePart.fromJsonSQLite(maps[i]);
    });

    if (result.isEmpty) {
      await _db.insert(
        _sparePart.modelName,
        _sparePart.toMapSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
