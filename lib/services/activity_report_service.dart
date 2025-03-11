import 'package:dio/dio.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/interceptors/ob_interceptor.dart';
import 'package:workorders/models/activity_report.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/services/user_service.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

abstract class ActivityReportService {
  static Future<List<ActivityReport>> getActivityReports(
      {String? dateStart, String? dateEnd}) async {
    User? _user = await UserService.current();

    String _path =
        "/$JSON_REST/${ActivityReport.sEntityName}?_where=projectTask.projectPhase.project.projectStatus!='OP' AND projectTask.projectPhase.project.personInCharge.id='${_user?.businessPartnerId}'";
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

    List<ActivityReport> _activityReports = List.generate(_data.length, (i) {
      return ActivityReport.fromJson(_data[i]);
    });

    return _activityReports;
  }

  static Future<ActivityReport> postActivityReport(
      ActivityReport activityReport) async {
    SyncUp _syncUp = activityReport.syncUp;
    String? _phoneId = activityReport.phoneId;
    try {
      String _path = "/$JSON_REST/${ActivityReport.sEntityName}";

      Dio _dio = Dio();
      _dio.interceptors.addAll([
        OBInterceptor(),
      ]);
      final _body = activityReport.toMap();
      Response _response;
      try {
        _response = await _dio.post(_path, data: {'data': _body});
      } on DioError catch (e) {
        throw CustomException(e.message??"");
      }
      var _data = _response.data['response']['data'];
      ActivityReport _activityReport = ActivityReport.fromJson(_data[0]);
      activityReport = _activityReport;
      _syncUp.isRequired = false;
      _syncUp.date = DateTime.now();
      activityReport.syncUp = _syncUp;
      activityReport.phoneId = _phoneId;
      await update(activityReport);
    } catch (e) {
      _syncUp.date = DateTime.now();
      _syncUp.status = 'ERROR';
      _syncUp.error = e.toString();
      activityReport.syncUp = _syncUp;
      await update(activityReport);
      rethrow;
    }

    return activityReport;
  }

  static Future<List<ActivityReport>> selectByProjectTask(
      {required String projectTaskId}) async {
    Database? _db = await DBHelper.db;
    List<Map<String, dynamic>> maps = await _db.query(ActivityReport.sModelName,
        where: ' project_task_id = ? ', whereArgs: [projectTaskId]);
    return List.generate(maps.length, (i) {
      return ActivityReport.fromJsonSQLite(maps[i]);
    });
  }

  static Future<ActivityReport> insert(ActivityReport _activityReport) async {
    Database _db = await DBHelper.db;

    var _uuid = const Uuid();
    DateTime _date = DateTime.now();

    _activityReport.phoneId = _uuid.v4();
    _activityReport.created = _date;
    _activityReport.updated = _date;

    await _db.insert(
      _activityReport.modelName,
      _activityReport.toMapSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return _activityReport;
  }

  static Future<void> update(ActivityReport _activityReport) async {
    Database? _db = await DBHelper.db;

    String? _id = _activityReport.id;
    String? _phoneId = _activityReport.phoneId;
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
      _args.add(_activityReport.id!);
    } else {
      _query = ' phone_id = ? ';
      _args.add(_activityReport.phoneId!);
    }

    DateTime _date = DateTime.now();
    _activityReport.updated = _date;

    await _db.update(
      _activityReport.modelName,
      _activityReport.toMapSQLite(),
      where: _query,
      whereArgs: _args,
    );
  }

  static Future<List<ActivityReport>> selectToSync() async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    List<Map<String, dynamic>> maps = await _db.rawQuery(
        " SELECT ar.* FROM activity_reports ar JOIN project_tasks pt ON pt.id = ar.project_task_id JOIN project_phases pp ON pp.id = pt.project_phase_id JOIN projects p ON p.id = pp.project_id WHERE p.person_in_charge_id = ? AND ar.sync_up = 1 ORDER BY p.created, p.id ",
        [_user?.businessPartnerId]);
    return List.generate(maps.length, (i) {
      return ActivityReport.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> insertFromSync(ActivityReport _activityReport) async {
    Database _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(_activityReport.modelName,
        where: " id = ? AND sync_up_status = 'ERROR' ",
        whereArgs: [_activityReport.id]);
    List result = List.generate(maps.length, (i) {
      return ActivityReport.fromJsonSQLite(maps[i]);
    });

    if (result.isEmpty) {
      await _db.insert(
        _activityReport.modelName,
        _activityReport.toMapSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
