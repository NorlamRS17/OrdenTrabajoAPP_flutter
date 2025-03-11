import 'package:dio/dio.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/interceptors/ob_interceptor.dart';
import 'package:workorders/models/expense.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/services/user_service.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

abstract class ExpenseService {
  static Future<List<Expense>> getExpenses(
      {String? dateStart, String? dateEnd}) async {
    User? _user = await UserService.current();

    String _path =
        "/$JSON_REST/${Expense.sEntityName}?_where=project.projectStatus!='OP' AND project.personInCharge.id='${_user?.businessPartnerId}'";
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

    List<Expense> _expenses = List.generate(_data.length, (i) {
      return Expense.fromJson(_data[i]);
    });

    return _expenses;
  }

  static Future<Expense> postExpense(Expense expense) async {
    SyncUp _syncUp = expense.syncUp;
    String? _phoneId = expense.phoneId;
    try {
      String _path = "/$JSON_REST/${Expense.sEntityName}";

      Dio _dio = Dio();
      _dio.interceptors.addAll([
        OBInterceptor(),
      ]);
      final _body = expense.toMap();
      Response _response;
      try {
        _response = await _dio.post(_path, data: {'data': _body});
      } on DioError catch (e) {
        throw CustomException(e.message??"");
      }
      var _data = _response.data['response']['data'];
      Expense _expense = Expense.fromJson(_data[0]);
      expense = _expense;
      _syncUp.isRequired = false;
      _syncUp.date = DateTime.now();
      expense.syncUp = _syncUp;
      expense.phoneId = _phoneId;
      await update(expense);
    } catch (e) {
      _syncUp.date = DateTime.now();
      _syncUp.status = 'ERROR';
      _syncUp.error = e.toString();
      expense.syncUp = _syncUp;
      await update(expense);
      rethrow;
    }

    return expense;
  }

  static Future<List<Expense>> selectByProject(
      {required String projectId}) async {
    Database? _db = await DBHelper.db;
    List<Map<String, dynamic>> maps = await _db.query(Expense.sModelName,
        where: ' project_id = ? ', whereArgs: [projectId]);
    return List.generate(maps.length, (i) {
      return Expense.fromJsonSQLite(maps[i]);
    });
  }

  static Future<Expense> insert(Expense _expense) async {
    Database _db = await DBHelper.db;
    User? _user = await UserService.current();

    var _uuid = const Uuid();
    DateTime _date = DateTime.now();

    _expense.phoneId = _uuid.v4();
    _expense.businessPartnerId = _user?.businessPartnerId;
    _expense.reportDate = _date;
    _expense.created = _date;
    _expense.updated = _date;

    await _db.insert(
      _expense.modelName,
      _expense.toMapSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return _expense;
  }

  static Future<void> update(Expense _expense) async {
    Database? _db = await DBHelper.db;

    String? _id = _expense.id;
    String? _phoneId = _expense.phoneId;
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
      _args.add(_expense.id!);
    } else {
      _query = ' phone_id = ? ';
      _args.add(_expense.phoneId!);
    }

    DateTime _date = DateTime.now();
    _expense.updated = _date;

    await _db.update(
      _expense.modelName,
      _expense.toMapSQLite(),
      where: _query,
      whereArgs: _args,
    );
  }

  static Future<List<Expense>> selectToSync() async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    List<Map<String, dynamic>> maps = await _db.rawQuery(
        " SELECT e.* FROM expenses e JOIN projects p ON p.id = e.project_id WHERE p.person_in_charge_id = ? AND e.sync_up = 1 ORDER BY p.created, p.id ",
        [_user?.businessPartnerId]);
    return List.generate(maps.length, (i) {
      return Expense.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> insertFromSync(Expense _expense) async {
    Database _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(_expense.modelName,
        where: " id = ? AND sync_up_status = 'ERROR' ",
        whereArgs: [_expense.id]);
    List result = List.generate(maps.length, (i) {
      return Expense.fromJsonSQLite(maps[i]);
    });

    if (result.isEmpty) {
      await _db.insert(
        _expense.modelName,
        _expense.toMapSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
