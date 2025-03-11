import 'dart:io';

import 'package:dio/dio.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/interceptors/ob_interceptor.dart';
import 'package:workorders/models/picture.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/services/user_service.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

abstract class PictureService {
  static Future<List<Picture>> getPictures(
      {String? dateStart, String? dateEnd}) async {
    User? _user = await UserService.current();

    String _path =
        "/$JSON_REST/${Picture.sEntityName}?_where=sotpeActivityreport.projectTask.projectPhase.project.projectStatus!='OP' AND sotpeActivityreport.projectTask.projectPhase.project.personInCharge.id='${_user?.businessPartnerId}'";
    if (dateStart != null) {
      _path +=
          " AND sotpeActivityreport.projectTask.projectPhase.project.creationDate>='$dateStart' ";
    }
    if (dateEnd != null) {
      _path +=
          " AND sotpeActivityreport.projectTask.projectPhase.project.creationDate<='$dateEnd' ";
    }

    Dio _dio = Dio();
    _dio.interceptors.addAll([
      OBInterceptor(),
    ]);
    Response _response = await _dio.get(_path);
    var _data = _response.data['response']['data'];

    List<Picture> _pictures = List.generate(_data.length, (i) {
      return Picture.fromJson(_data[i]);
    });

    return _pictures;
  }

  static Future<Picture> postPicture(Picture picture) async {
    SyncUp _syncUp = picture.syncUp;
    String? _phoneId = picture.phoneId;
    try {
      String _path = "/ws/$APP_OTS.pictures";

      Dio _dio = Dio();
      _dio.interceptors.addAll([
        OBInterceptor(),
      ]);
      File _imgDirFile = File(picture.imgDir!);
      Map<String, dynamic> _map = picture.toMap();
      _map.addAll({
        "imgdirFile": await MultipartFile.fromFile(_imgDirFile.path),
      });
      FormData _formData = FormData.fromMap(_map);
      Response _response;
      try {
        _response = await _dio.post(_path, data: _formData);
      } on DioError catch (e) {
        throw CustomException(e.message??"");
      }
      var _data = _response.data['response']['data'];
      Picture _picture = Picture.fromJson(_data[0]);
      picture = _picture;
      _syncUp.isRequired = false;
      _syncUp.date = DateTime.now();
      picture.syncUp = _syncUp;
      picture.phoneId = _phoneId;
      await update(picture);
    } catch (e) {
      _syncUp.date = DateTime.now();
      _syncUp.status = 'ERROR';
      _syncUp.error = e.toString();
      picture.syncUp = _syncUp;
      await update(picture);
      rethrow;
    }

    return picture;
  }

  static Future<List<Picture>> selectByActivityReport(
      {required String activityReportId}) async {
    Database? _db = await DBHelper.db;
    List<Map<String, dynamic>> maps = await _db.query(Picture.sModelName,
        where: ' activity_report_id = ? ', whereArgs: [activityReportId]);
    return List.generate(maps.length, (i) {
      return Picture.fromJsonSQLite(maps[i]);
    });
  }

  static Future<Picture> insert(Picture _picture) async {
    Database _db = await DBHelper.db;

    var _uuid = const Uuid();
    DateTime _date = DateTime.now();

    _picture.phoneId = _uuid.v4();
    _picture.created = _date;
    _picture.updated = _date;

    await _db.insert(
      _picture.modelName,
      _picture.toMapSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return _picture;
  }

  static Future<void> update(Picture _picture) async {
    Database? _db = await DBHelper.db;

    String? _id = _picture.id;
    String? _phoneId = _picture.phoneId;
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
      _args.add(_picture.id!);
    } else {
      _query = ' phone_id = ? ';
      _args.add(_picture.phoneId!);
    }

    DateTime _date = DateTime.now();
    _picture.updated = _date;

    await _db.update(
      _picture.modelName,
      _picture.toMapSQLite(),
      where: _query,
      whereArgs: _args,
    );
  }

  static Future<void> updateRelationships(
      {required String? projectTaskPhoneId,
      required String projectTaskId}) async {
    Database? _db = await DBHelper.db;

    if (projectTaskPhoneId != null) {
      await _db.rawUpdate(
          " UPDATE pictures SET activity_report_id = ? WHERE activity_report_id = ? ",
          [projectTaskId, projectTaskPhoneId]);
    }
  }

  static Future<List<Picture>> selectToSync() async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    List<Map<String, dynamic>> maps = await _db.rawQuery(
        " SELECT pic.* FROM pictures AS pic JOIN activity_reports ar ON ar.id = pic.activity_report_id JOIN project_tasks pt ON pt.id = ar.project_task_id JOIN project_phases pp ON pp.id = pt.project_phase_id JOIN projects p ON p.id = pp.project_id WHERE p.person_in_charge_id = ? AND pic.sync_up = 1 ORDER BY p.created, p.id ",
        [_user?.businessPartnerId]);
    return List.generate(maps.length, (i) {
      return Picture.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> insertFromSync(Picture _picture) async {
    Database _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(_picture.modelName,
        where: " id = ? AND sync_up_status = 'ERROR' ",
        whereArgs: [_picture.id]);
    List result = List.generate(maps.length, (i) {
      return Picture.fromJsonSQLite(maps[i]);
    });

    if (result.isEmpty) {
      await _db.insert(
        _picture.modelName,
        _picture.toMapSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
