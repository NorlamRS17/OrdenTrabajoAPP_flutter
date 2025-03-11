import 'package:dio/dio.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/interceptors/ob_interceptor.dart';
import 'package:workorders/models/expense_line.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/services/user_service.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

abstract class ExpenseLineService {
  static Future<List<ExpenseLine>> getExpenseLines(
      {String? dateStart, String? dateEnd}) async {
    User? _user = await UserService.current();

    String _path =
        "/$JSON_REST/${ExpenseLine.sEntityName}?_where=project!=null AND expenseSheet.project.projectStatus!='OP' AND expenseSheet.project.personInCharge.id='${_user?.businessPartnerId}'";
    if (dateStart != null) {
      _path += " AND expenseSheet.project.creationDate>='$dateStart' ";
    }
    if (dateEnd != null) {
      _path += " AND expenseSheet.project.creationDate<='$dateEnd' ";
    }

    Dio _dio = Dio();
    _dio.interceptors.addAll([
      OBInterceptor(),
    ]);
    Response _response = await _dio.get(_path);
    var _data = _response.data['response']['data'];

    List<ExpenseLine> _expenseLines = List.generate(_data.length, (i) {
      return ExpenseLine.fromJson(_data[i]);
    });

    return _expenseLines;
  }

  static Future<ExpenseLine> postExpenseLine(ExpenseLine expenseLine) async {
    SyncUp _syncUp = expenseLine.syncUp;
    String? _phoneId = expenseLine.phoneId;
    try {
      String _path = "/$JSON_REST/${ExpenseLine.sEntityName}";

      Dio _dio = Dio();
      _dio.interceptors.addAll([
        OBInterceptor(),
      ]);
      final _body = expenseLine.toMap();
      Response _response;
      try {
        _response = await _dio.post(_path, data: {'data': _body});
      } on DioError catch (e) {
        throw CustomException(e.message??"");
      }
      var _data = _response.data['response']['data'];
      ExpenseLine _expenseLine = ExpenseLine.fromJson(_data[0]);
      expenseLine = _expenseLine;
      _syncUp.isRequired = false;
      _syncUp.date = DateTime.now();
      expenseLine.syncUp = _syncUp;
      expenseLine.phoneId = _phoneId;
      await update(expenseLine);
    } catch (e) {
      _syncUp.date = DateTime.now();
      _syncUp.status = 'ERROR';
      _syncUp.error = e.toString();
      expenseLine.syncUp = _syncUp;
      await update(expenseLine);
      rethrow;
    }

    return expenseLine;
  }

  static Future<List<ExpenseLine>> selectByProject(
      {required String projectId}) async {
    Database? _db = await DBHelper.db;
    List<Map<String, dynamic>> maps = await _db.rawQuery(
        "SELECT el.* FROM expense_lines el JOIN expenses e ON el.expense_id IN (e.id, e.phone_id) WHERE e.project_id = ? ORDER BY el.lineno",
        [projectId]);

    return List.generate(maps.length, (i) {
      return ExpenseLine.fromJsonSQLite(maps[i]);
    });
  }

  static Future<ExpenseLine> insert(ExpenseLine _expenseLine) async {
    Database _db = await DBHelper.db;

    final _expenseLines =
        await selectByProject(projectId: _expenseLine.projectId);
    final _lineNo = (_expenseLines.length + 1) * 10;

    var _uuid = const Uuid();
    DateTime _date = DateTime.now();

    _expenseLine.phoneId = _uuid.v4();
    _expenseLine.lineNo = _lineNo;
    _expenseLine.created = _date;
    _expenseLine.updated = _date;

    await _db.insert(
      _expenseLine.modelName,
      _expenseLine.toMapSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return _expenseLine;
  }

  static Future<void> update(ExpenseLine _expenseLine) async {
    Database? _db = await DBHelper.db;

    String? _id = _expenseLine.id;
    String? _phoneId = _expenseLine.phoneId;
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
      _args.add(_expenseLine.id!);
    } else {
      _query = ' phone_id = ? ';
      _args.add(_expenseLine.phoneId!);
    }

    DateTime _date = DateTime.now();
    _expenseLine.updated = _date;

    await _db.update(
      _expenseLine.modelName,
      _expenseLine.toMapSQLite(),
      where: _query,
      whereArgs: _args,
    );
  }

  static Future<void> updateRelationships(
      {required String? expensePhoneId, required String expenseId}) async {
    Database? _db = await DBHelper.db;

    if (expensePhoneId != null) {
      await _db.rawUpdate(
          " UPDATE expense_lines SET expense_id = ? WHERE expense_id = ? ",
          [expenseId, expensePhoneId]);
    }
  }

  static Future<List<ExpenseLine>> selectToSync() async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    List<Map<String, dynamic>> maps = await _db.rawQuery(
        " SELECT el.* FROM expense_lines el JOIN expenses e ON e.id = el.expense_id JOIN projects p ON p.id = e.project_id WHERE p.person_in_charge_id = ? AND el.sync_up = 1 ORDER BY p.created, p.id ",
        [_user?.businessPartnerId]);
    return List.generate(maps.length, (i) {
      return ExpenseLine.fromJsonSQLite(maps[i]);
    });
  }

  static Future<void> insertFromSync(ExpenseLine _expenseLine) async {
    Database _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db.query(_expenseLine.modelName,
        where: " id = ? AND sync_up_status = 'ERROR' ",
        whereArgs: [_expenseLine.id]);
    List result = List.generate(maps.length, (i) {
      return ExpenseLine.fromJsonSQLite(maps[i]);
    });

    if (result.isEmpty) {
      await _db.insert(
        _expenseLine.modelName,
        _expenseLine.toMapSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
