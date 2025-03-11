import 'package:sqflite/sqflite.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/interceptors/location_interceptor.dart';
import 'package:workorders/models/location.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/services/user_service.dart';
import 'package:workorders/utils/db_helper.dart';
import 'package:workorders/utils/utils.dart';

abstract class LocationService {
  static Future<List<Location>> getLocations(
      {String? dateStart,
      String? dateEnd,
      String? projectId,
      required int skip,
      required int take}) async {
    User? _user = await UserService.current();

    String _path = '/api/${Location.sEntityName}?skip=$skip&take=$take';
    Map<String, dynamic> params = {};
    if (dateStart != null) {
      params['dateStart'] = dateStart;
    }
    if (dateEnd != null) {
      params['dateEnd'] = dateEnd;
    }
    if (projectId != null) {
      params['order_id'] = projectId;
    } else {
      params['user_id'] = _user?.businessPartnerId;
    }
    String query = Uri(queryParameters: params).query;
    _path += "&$query";

    Dio _dio = Dio();
    _dio.interceptors.addAll([
      LocationInterceptor(),
    ]);
    Response _response = await _dio.get(_path);
    var _data = _response.data['response']['data'];

    List<Location> _locations = List.generate(_data.length, (i) {
      return Location.fromJson(_data[i]);
    });

    return _locations;
  }

  static Future<int> getTotalRows(
      {String? dateStart, String? dateEnd, String? projectId}) async {
    User? _user = await UserService.current();

    String _path = '/api/${Location.sEntityName}/getTotalRows?';
    Map<String, dynamic> params = {};
    if (dateStart != null) {
      params['dateStart'] = dateStart;
    }
    if (dateEnd != null) {
      params['dateEnd'] = dateEnd;
    }
    if (projectId != null) {
      params['order_id'] = projectId;
    } else {
      params['user_id'] = _user?.businessPartnerId;
    }
    String query = Uri(queryParameters: params).query;
    _path += query;

    Dio _dio = Dio();
    _dio.interceptors.addAll([
      LocationInterceptor(),
    ]);
    Response _response = await _dio.get(_path);
    var _data = _response.data['response'];

    return _data['totalRows'];
  }

  static Future<Location> postLocation(Location location) async {
    SyncUp _syncUp = location.syncUp;
    String? _phoneId = location.phoneId;
    try {
      String _path = "/api/${Location.sEntityName}";

      Dio _dio = Dio();
      _dio.interceptors.addAll([
        LocationInterceptor(),
      ]);
      final _body = location.toMap();
      Response _response;
      try {
        _response = await _dio.post(_path, data: _body);
      } on DioError catch (e) {
        throw CustomException(e.message??"");
      }
      var _data = _response.data;
      Location _location = Location.fromJson(_data);
      location = _location;
      _syncUp.isRequired = false;
      _syncUp.date = DateTime.now();
      location.syncUp = _syncUp;
      location.phoneId = _phoneId;
      await update(location);
    } catch (e) {
      _syncUp.date = DateTime.now();
      _syncUp.status = 'ERROR';
      _syncUp.error = e.toString();
      location.syncUp = _syncUp;
      await update(location);
      rethrow;
    }

    return location;
  }

  static Future<int> postLocations(List<Location> locations) async {
    int _errors = 0;
    try {
      final _date = DateTime.now();
      String _path = "/api/${Location.sEntityName}/array";

      Dio _dio = Dio();
      _dio.interceptors.addAll([
        LocationInterceptor(),
      ]);

      List<Map> _body = List.generate(locations.length, (i) {
        return locations[i].toMap();
      });

      Response _response;
      try {
        _response = await _dio.post(_path, data: {'data': _body});
      } on DioError catch (e) {
        throw CustomException(e.message??"");
      }
      final _data = _response.data['response']['data'];
      _data.asMap().forEach((index, item) async {
        SyncUp _syncUp = locations[index].syncUp;
        String? _phoneId = locations[index].phoneId;
        final _location = Location.fromJson(item);
        _syncUp.date = _date;
        _location.phoneId = _phoneId;
        if (_location.error != null && _location.error != '') {
          _errors++;
          _syncUp.status = 'ERROR';
          _syncUp.error = _location.error;
        } else {
          _syncUp.isRequired = false;
          _syncUp.status = 'OK';
        }
        _location.syncUp = _syncUp;
        await update(_location);
      });
    } catch (e) {
      rethrow;
    }

    return _errors;
  }

  static Future<List<Location>> selectByUser() async {
    User? _user = await UserService.current();
    Database? _db = await DBHelper.db;
    List<Map<String, dynamic>> maps = await _db.query(Location.sModelName,
        where: 'user_id = ?', whereArgs: [_user!.id]);
    return List.generate(maps.length, (i) {
      return Location.fromJsonSQLite(maps[i]);
    });
  }

  static Future<List<Location>> selectEventsByProject(
      {required String projectId}) async {
    Database? _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(Location.sModelName,
        where:
            " project_id = ? AND project_task_id IS NULL AND type != 'Pulso' ",
        whereArgs: [projectId],
        orderBy: ' created ');
    return List.generate(maps.length, (i) {
      return Location.fromJsonSQLite(maps[i]);
    });
  }

  static Future<List<Location>> selectPulsesByProject(
      {required String projectId}) async {
    Database? _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(Location.sModelName,
        where: " project_id = ? AND type = 'Pulso' ",
        whereArgs: [projectId],
        orderBy: ' created ');
    return List.generate(maps.length, (i) {
      return Location.fromJsonSQLite(maps[i]);
    });
  }

  static Future<List<Location>> selectEventsByProjectTask(
      {required String projectId, required String projectTaskId}) async {
    Database? _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(Location.sModelName,
        where: " project_id = ? AND project_task_id = ? AND type != 'Pulso' ",
        whereArgs: [projectId, projectTaskId],
        orderBy: ' created ');
    return List.generate(maps.length, (i) {
      return Location.fromJsonSQLite(maps[i]);
    });
  }

  static Future<List<Location>> selectPulsesByProjectTask(
      {required String projectTaskId}) async {
    Database? _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(Location.sModelName,
        where: " project_task_id = ? AND type = 'Pulso' ",
        whereArgs: [projectTaskId],
        orderBy: ' created ');
    return List.generate(maps.length, (i) {
      return Location.fromJsonSQLite(maps[i]);
    });
  }

  static Future<Location> insert(
      {required String projectId,
      String? projectPhaseId,
      String? projectTaskId,
      required double latitude,
      required double longitude,
      required String type,
      required String description}) async {
    User? _user = await UserService.current();
    Database _db = await DBHelper.db;

    var uuid = const Uuid();
    DateTime _now = DateTime.now();

    Location _location = Location(
        id: null,
        phoneId: uuid.v4(),
        userId: _user!.businessPartnerId,
        projectId: projectId,
        projectPhaseId: projectPhaseId,
        projectTaskId: projectTaskId,
        latitude: latitude,
        longitude: longitude,
        type: type,
        description: description,
        created: _now,
        updated: _now,
        syncUp: SyncUp(isRequired: true));

    await _db.insert(
      _location.modelName,
      _location.toMapSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return _location;
  }

  static Future<void> update(Location _location) async {
    Database? _db = await DBHelper.db;

    int? _id = _location.id;
    String? _phoneId = _location.phoneId;
    String _query = '';
    List<dynamic> _args = [];
    if (_id != null && _phoneId != null && _phoneId.isNotEmpty) {
      _query = ' (id = ? OR phone_id = ?) ';
      _args.add(_id);
      _args.add(_phoneId);
    } else if (_id != null) {
      _query = ' id = ? ';
      _args.add(_location.id!);
    } else {
      _query = ' phone_id = ? ';
      _args.add(_location.phoneId!);
    }

    DateTime _date = DateTime.now();
    _location.updated = _date;

    await _db.update(
      _location.modelName,
      _location.toMapSQLite(),
      where: _query,
      whereArgs: _args,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Location>> selectToSync() async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    List<Map<String, dynamic>> maps = await _db.rawQuery(
        " SELECT * FROM locations WHERE user_id = ? AND sync_up = 1 ORDER BY created ",
        [_user?.businessPartnerId]);
    return List.generate(maps.length, (i) {
      return Location.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> insertFromSync(Location _location) async {
    Database _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(_location.modelName,
        where: " id = ? AND sync_up_status = 'ERROR' ",
        whereArgs: [_location.id]);
    List result = List.generate(maps.length, (i) {
      return Location.fromJsonSQLite(maps[i]);
    });

    if (result.isEmpty) {
      await _db.insert(
        _location.modelName,
        _location.toMapSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<double> getProjectTaskIdleTime(
      {required String projectTaskId}) async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    List<Map<String, dynamic>> maps = await _db.rawQuery(
        "SELECT A.seqno, A.created starting, B.created ending, SUM((strftime('%s', B.created) - strftime('%s', A.created))/60) idle_time " +
            "FROM ( " +
            "SELECT ROW_NUMBER() OVER(ORDER BY seqno, created) rowno, * " +
            "FROM ( " +
            "SELECT DISTINCT pt.seqno, pt.name, l.type, l.created " +
            "FROM project_tasks pt " +
            "JOIN project_phases pp ON pp.id = pt.project_phase_id " +
            "JOIN projects p ON p.id = pp.project_id " +
            "JOIN locations l ON l.project_task_id = pt.id " +
            "WHERE pt.id = ? AND l.user_id = ? AND l.type = 'Pausada: Tarea' " +
            "ORDER BY pt.seqno, l.created " +
            ") A " +
            ") A " +
            "LEFT JOIN ( " +
            "SELECT ROW_NUMBER() OVER(ORDER BY seqno, created) rowno, * " +
            "FROM ( " +
            "SELECT DISTINCT pt.seqno, pt.name, l.type, l.created " +
            "FROM project_tasks pt " +
            "JOIN project_phases pp ON pp.id = pt.project_phase_id " +
            "JOIN projects p ON p.id = pp.project_id " +
            "JOIN locations l ON l.project_task_id = pt.id " +
            "WHERE pt.id = ? AND l.user_id = ? AND l.type = 'Reanudada: Tarea' " +
            " ORDER BY pt.seqno, l.created " +
            ") B " +
            ") B ON B.rowno = A.rowno " +
            "GROUP BY A.seqno ",
        [
          projectTaskId,
          _user?.businessPartnerId,
          projectTaskId,
          _user?.businessPartnerId
        ]);

    double idleTime = 0.0;
    if (maps.length > 0) {
      idleTime = Utils.getDouble(maps[0]['idle_time']) ?? 0.0;
    }

    return idleTime;
  }
}
