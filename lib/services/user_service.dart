import 'package:workorders/utils/db_helper.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/utils/utils.dart';
import 'package:sqflite/sqflite.dart';

abstract class UserService {
  static Future<User?> current() async {
    User? _user;
    String? userId = await Utils.getSPString('user_id');

    Database? _db = await DBHelper.db;
    List<Map<String, dynamic>> _maps = await _db.query(
      User.sModelName,
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (_maps.length == 1) _user = User.fromJsonSQLite(_maps[0]);

    return _user;
  }

  static Future<List<User>> select({String? id}) async {
    Database? _db = await DBHelper.db;

    String? _where;
    List _whereArgs = [];
    if (id != null) {
      _where = ' id = ? ';
      _whereArgs.add(id);
    }

    List<Map<String, dynamic>> maps =
        await _db.query(User.sModelName, where: _where, whereArgs: _whereArgs);
    return List.generate(maps.length, (i) {
      return User.fromJsonSQLite(maps[i]);
    });
  }

  static Future<List<User>> selectByUsername({required String username}) async {
    Database? _db = await DBHelper.db;

    List<Map<String, dynamic>> maps = await _db
        .query(User.sModelName, where: ' username = ? ', whereArgs: [username]);
    return List.generate(maps.length, (i) {
      return User.fromJsonSQLite(maps[i]);
    });
  }
}
