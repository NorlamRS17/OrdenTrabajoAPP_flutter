import 'dart:io';

import 'package:dio/dio.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/interceptors/ob_interceptor.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/services/user_service.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/db_helper.dart';
import 'package:workorders/models/project.dart';
import 'package:sqflite/sqflite.dart';

abstract class ProjectService {
  static Future<List<Project>> getProject(
      {String? dateStart, String? dateEnd}) async {
    User? _user = await UserService.current();

    String _path =
        "/$JSON_REST/${Project.sEntityName}?_where=projectStatus!='OP' AND personInCharge='${_user?.businessPartnerId}'";
    if (dateStart != null) {
      _path += " AND creationDate>='$dateStart' ";
    }
    if (dateEnd != null) {
      _path += " AND creationDate<='$dateEnd' ";
    }

    Dio _dio = Dio();
    _dio.interceptors.addAll([
      OBInterceptor(),
    ]);
    Response _response = await _dio.get(_path);
    var _data = _response.data['response']['data'];

    List<Project> _projects = List.generate(_data.length, (i) {
      return Project.fromJson(_data[i]);
    });

    return _projects;
  }

  static Future<Project> postProject(Project project) async {
    SyncUp _syncUp = project.syncUp;
    try {
      String _path = "/ws/$APP_OTS.projects";

      Dio _dio = Dio();
      _dio.interceptors.addAll([
        OBInterceptor(),
      ]);
      Response _response;
      try {
        if (project.endDate != null && project.signatureClientLink == null) {
          File _signatureClient = File(project.signatureClientImgDir!);
          File _signatureTech = File(project.signatureTechImgDir!);
          // String fileName = file.path.split('/').last;
          Map<String, dynamic> _map = project.toMap();
          _map.addAll({
            "sotpeAccImgFile":
                await MultipartFile.fromFile(_signatureClient.path),
            "sotpeAccTechImgFile":
                await MultipartFile.fromFile(_signatureTech.path),
          });
          FormData _formData = FormData.fromMap(_map);
          _response = await _dio.post(_path, data: _formData);
        } else {
          _path = "/$JSON_REST/${Project.sEntityName}";
          final _body = project.toMap();
          _response = await _dio.post(_path, data: {'data': _body});
        }
      } on DioError catch (e) {
        throw CustomException(e.message??"");
      }

      var _data = _response.data['response']['data'];
      Project _project = Project.fromJson(_data[0]);
      project = _project;
      _syncUp.isRequired = false;
      _syncUp.date = DateTime.now();
      project.syncUp = _syncUp;
      await DBHelper.update(project);
    } catch (e) {
      _syncUp.date = DateTime.now();
      _syncUp.status = 'ERROR';
      _syncUp.error = e.toString();
      project.syncUp = _syncUp;
      await DBHelper.update(project);
      rethrow;
    }

    return project;
  }

  static Future<List<Project>> select(
      {String? id,
      bool? isCompleted,
      String? dateStart,
      String? dateEnd,
      String? documentNo}) async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    String _where = ' person_in_charge_id = ? ';
    List _whereArgs = [_user?.businessPartnerId];
    if (id != null) {
      _where += ' AND id = ? ';
      _whereArgs.add(id);
    }

    if (isCompleted != null) {
      if (isCompleted) {
        _where += " AND (end_date IS NOT NULL AND end_date != '') ";
      } else {
        _where += " AND (end_date IS NULL OR end_date = '') ";
      }
    }

    if (dateStart != null) {
      _where += ' AND DATE(created) >= ? ';
      _whereArgs.add(dateStart);
    }

    if (dateEnd != null) {
      _where += ' AND DATE(created) <= ? ';
      _whereArgs.add(dateEnd);
    }

    if (documentNo != null) {
      _where += " AND documentno LIKE '%$documentNo%' ";
    }

    List<Map<String, dynamic>> maps = await _db.query(Project.sModelName,
        where: _where, whereArgs: _whereArgs, orderBy: 'created DESC');
    return List.generate(maps.length, (i) {
      return Project.fromJsonSQLite(maps[i]);
    });
  }

  static Future<List<Project>> selectInProcess(
      {String? dateStart, String? dateEnd, String? documentNo}) async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    String _where = " p.person_in_charge_id = ? AND pt.status = 'En proceso' ";
    List _whereArgs = [_user?.businessPartnerId];
    if (dateStart != null && dateStart.isNotEmpty) {
      _where += ' AND DATE(p.created) >= ? ';
      _whereArgs.add(dateStart);
    }

    if (dateEnd != null && dateEnd.isNotEmpty) {
      _where += ' AND DATE(p.created) <= ? ';
      _whereArgs.add(dateEnd);
    }

    if (documentNo != null && documentNo.isNotEmpty) {
      _where += " AND p.documentno LIKE '%?%' ";
      _whereArgs.add(documentNo);
    }

    List<Map<String, dynamic>> maps = await _db.rawQuery(
        " SELECT DISTINCT p.* FROM project_tasks pt JOIN project_phases pp ON pp.id = pt.project_phase_id JOIN projects p ON p.id = pp.project_id WHERE $_where ORDER BY p.created DESC ",
        _whereArgs);
    return List.generate(maps.length, (i) {
      return Project.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> update(Project _project) async {
    Database? _db = await DBHelper.db;

    DateTime _date = DateTime.now();
    _project.updated = _date;

    await _db.update(
      _project.modelName,
      _project.toMapSQLite(),
      where: ' id = ? ',
      whereArgs: [_project.id],
    );
  }

  static Future<List<Project>> selectToSync() async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    List<Map<String, dynamic>> maps = await _db.query(Project.sModelName,
        where: ' person_in_charge_id = ? AND sync_up = 1 ',
        whereArgs: [_user?.businessPartnerId],
        orderBy: 'documentno');
    return List.generate(maps.length, (i) {
      return Project.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> insertFromSync(Project _project) async {
    Database _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(_project.modelName,
        where: " id = ? AND sync_up_status = 'ERROR' ",
        whereArgs: [_project.id]);
    List result = List.generate(maps.length, (i) {
      return Project.fromJsonSQLite(maps[i]);
    });

    if (result.isEmpty) {
      await _db.insert(
        _project.modelName,
        _project.toMapSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
