import 'package:dio/dio.dart';
import 'package:workorders/interceptors/ob_interceptor.dart';
import 'package:workorders/models/project_phase.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/services/user_service.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/db_helper.dart';
import 'package:sqflite/sqflite.dart';

abstract class ProjectPhaseService {
  static Future<List<ProjectPhase>> getProjectPhases(
      {String? dateStart, String? dateEnd}) async {
    User? _user = await UserService.current();

    String _path =
        "/$JSON_REST/${ProjectPhase.sEntityName}?_where=project.projectStatus!='OP' AND project.personInCharge.id='${_user?.businessPartnerId}'";
    if (dateStart != null) {
      _path += " AND project.creationDate>='$dateStart' ";
    }
    if (dateEnd != null) {
      _path += " AND project.creationDate<='$dateEnd' ";
    }

    Dio _dio = Dio();
    _dio.interceptors.addAll([
      OBInterceptor(),
    ]);
    Response _response = await _dio.get(_path);
    var _data = _response.data['response']['data'];

    List<ProjectPhase> _projectPhases = List.generate(_data.length, (i) {
      return ProjectPhase.fromJson(_data[i]);
    });

    return _projectPhases;
  }

  static Future<List<ProjectPhase>> select({String? id}) async {
    Database? _db = await DBHelper.db;

    String? _where;
    List<String> _whereArgs = [];
    if (id != null) {
      _where = ' id = ? ';
      _whereArgs.add(id);
    }

    List<Map<String, dynamic>> maps = await _db.query(ProjectPhase.sModelName,
        where: _where, whereArgs: _whereArgs);
    return List.generate(maps.length, (i) {
      return ProjectPhase.fromJsonSQLite(maps[i]);
    });
  }

  static Future<List<ProjectPhase>> selectByProject(
      {required String projectId}) async {
    Database? _db = await DBHelper.db;
    List<Map<String, dynamic>> maps = await _db.rawQuery(
        "SELECT DISTINCT pp.* FROM project_tasks pt JOIN project_phases pp ON pp.id = pt.project_phase_id WHERE pp.project_id = ? AND pt.product_id IS NULL ORDER BY pp.seqno",
        [projectId]);
    return List.generate(maps.length, (i) {
      return ProjectPhase.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> insertFromSync(ProjectPhase _projectPhase) async {
    Database _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(_projectPhase.modelName,
        where: " id = ? AND sync_up_status = 'ERROR' ",
        whereArgs: [_projectPhase.id]);
    List result = List.generate(maps.length, (i) {
      return ProjectPhase.fromJsonSQLite(maps[i]);
    });

    if (result.isEmpty) {
      await _db.insert(
        _projectPhase.modelName,
        _projectPhase.toMapSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
