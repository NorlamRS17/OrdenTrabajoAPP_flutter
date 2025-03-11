import 'package:dio/dio.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/interceptors/ob_interceptor.dart';
import 'package:workorders/models/project_task.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/services/user_service.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/db_helper.dart';
import 'package:sqflite/sqflite.dart';

abstract class ProjectTaskService {
  static Future<List<ProjectTask>> getProjectTasks(
      {String? dateStart, String? dateEnd}) async {
    User? _user = await UserService.current();

    String _path =
        "/$JSON_REST/${ProjectTask.sEntityName}?_where=projectPhase.project.projectStatus!='OP' AND projectPhase.project.personInCharge.id='${_user?.businessPartnerId}'";
    if (dateStart != null) {
      _path += " AND projectPhase.project.creationDate>='$dateStart' ";
    }
    if (dateEnd != null) {
      _path += " AND projectPhase.project.creationDate<='$dateEnd' ";
    }

    Dio _dio = Dio();
    _dio.interceptors.addAll([
      OBInterceptor(),
    ]);
    Response _response = await _dio.get(_path);
    var _data = _response.data['response']['data'];

    List<ProjectTask> _projectTasks = List.generate(_data.length, (i) {
      return ProjectTask.fromJson(_data[i]);
    });

    return _projectTasks;
  }

  static Future<ProjectTask> postProjectTask(ProjectTask projectTask) async {
    SyncUp _syncUp = projectTask.syncUp;
    try {
      String _path = "/$JSON_REST/${ProjectTask.sEntityName}";

      Dio _dio = Dio();
      _dio.interceptors.addAll([
        OBInterceptor(),
      ]);
      final _body = projectTask.toMap();
      Response _response;
      try {
        _response = await _dio.post(_path, data: {'data': _body});
      } on DioError catch (e) {
        throw CustomException(e.message??"");
      }
      var _data = _response.data['response']['data'];
      ProjectTask _projectTask = ProjectTask.fromJson(_data[0]);
      projectTask = _projectTask;
      _syncUp.isRequired = false;
      _syncUp.date = DateTime.now();
      projectTask.syncUp = _syncUp;
      await DBHelper.update(projectTask);
    } catch (e) {
      _syncUp.date = DateTime.now();
      _syncUp.status = 'ERROR';
      _syncUp.error = e.toString();
      projectTask.syncUp = _syncUp;
      await DBHelper.update(projectTask);
      rethrow;
    }

    return projectTask;
  }

  static Future<List<ProjectTask>> select(
      {String? id, required String projectId, bool? isReturn}) async {
    Database? _db = await DBHelper.db;

    String _where = ' pp.project_id = ? AND pt.product_id IS NULL ';
    List _whereArgs = [projectId];
    if (id != null) {
      _where += ' AND pt.id = ? ';
      _whereArgs.add(id);
    }

    if (isReturn != null) {
      _where += ' AND pt.is_return = ? ';
      _whereArgs.add(isReturn ? 1 : 0);
    }

    List<Map<String, dynamic>> maps = await _db.rawQuery(
        " SELECT pt.* FROM project_tasks pt JOIN project_phases pp ON pp.id = pt.project_phase_id WHERE $_where ORDER BY pp.seqno, pt.seqno ",
        _whereArgs);
    return List.generate(maps.length, (i) {
      return ProjectTask.fromJsonSQLite(maps[i]);
    });
  }

  static Future<List<ProjectTask>> selectByStatus(
      {required String status, String? projectId}) async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    String _where = ' p.person_in_charge_id = ? AND pt.status = ? ';
    List _whereArgs = [_user?.businessPartnerId, status];
    if (projectId != null) {
      _where += ' AND p.id = ? ';
      _whereArgs.add(projectId);
    }

    List<Map<String, dynamic>> maps = await _db.rawQuery(
        " SELECT pt.* FROM project_tasks pt JOIN project_phases pp ON pp.id = pt.project_phase_id JOIN projects p ON p.id = pp.project_id WHERE $_where ORDER BY pp.seqno, pt.seqno ",
        _whereArgs);
    return List.generate(maps.length, (i) {
      return ProjectTask.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> update(ProjectTask _projectTask) async {
    Database? _db = await DBHelper.db;

    DateTime _date = DateTime.now();
    _projectTask.updated = _date;

    await _db.update(
      _projectTask.modelName,
      _projectTask.toMapSQLite(),
      where: ' id = ? ',
      whereArgs: [_projectTask.id],
    );
  }

  static Future<List<ProjectTask>> selectToSync() async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    List<Map<String, dynamic>> maps = await _db.rawQuery(
        " SELECT pt.* FROM project_tasks pt JOIN project_phases pp ON pp.id = pt.project_phase_id JOIN projects p ON p.id = pp.project_id WHERE p.person_in_charge_id = ? AND pt.sync_up = 1 ORDER BY p.created, p.id ",
        [_user?.businessPartnerId]);
    return List.generate(maps.length, (i) {
      return ProjectTask.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> insertFromSync(ProjectTask _projectTask) async {
    Database _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(_projectTask.modelName,
        where: " id = ? AND sync_up_status = 'ERROR' ",
        whereArgs: [_projectTask.id]);
    List result = List.generate(maps.length, (i) {
      return ProjectTask.fromJsonSQLite(maps[i]);
    });

    if (result.isEmpty) {
      await _db.insert(
        _projectTask.modelName,
        _projectTask.toMapSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
