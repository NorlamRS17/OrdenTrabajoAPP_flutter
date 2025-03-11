import 'package:workorders/models/synchronization.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/services/user_service.dart';
import 'package:workorders/utils/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

abstract class SynchronizationService {
  static Future<Synchronization> insert({required String type}) async {
    Database _db = await DBHelper.db;
    User? _user = await UserService.current();

    var _uuid = const Uuid();
    DateTime _date = DateTime.now();

    final _sync = Synchronization(
        id: _uuid.v4(),
        userId: (_user?.businessPartnerId)!,
        type: type,
        dateStart: _date,
        dateEnd: null,
        status: null);

    await _db.insert(
      _sync.modelName,
      _sync.toMapSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return _sync;
  }

  static Future<Synchronization?> selectLastSyncDown({String? id}) async {
    Database? _db = await DBHelper.db;
    User? _user = await UserService.current();

    List<Map<String, dynamic>> maps =
        await _db.query(Synchronization.sModelName,
            where: " type = 'DOWN' AND status = 'OK' AND user_id = ? ",
            whereArgs: [
              _user?.businessPartnerId,
            ],
            orderBy: ' date_start DESC ');
    List<Synchronization> _synchronizations = List.generate(maps.length, (i) {
      return Synchronization.fromJsonSQLite(maps[i]);
    });
    Synchronization? _synchronization;
    if (_synchronizations.isNotEmpty) {
      _synchronization = _synchronizations[0];
    }
    return _synchronization;
  }
}
