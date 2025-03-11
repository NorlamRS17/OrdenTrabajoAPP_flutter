import 'dart:async';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class DBHelper {
  DBHelper._privateConstructor();
  static Database? _db;

  static Future<Database> get db async {
    if (_db == null || !_db!.isOpen) {
      _db = await initDb();
    }
    return _db!;
  }

  static close() {
    if (_db != null) {
      print('**************************************************');
      _db?.close();
      print("Closed DB");
    }
  }

  static initDb() async {
    print('**************************************************');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String path = await getDatabasesPath();
    String pathDB = join(path, "${packageInfo.packageName}.db");
    var theDb = await openDatabase(pathDB,
        version: 5, onCreate: onCreate, onUpgrade: onUpgrade);
    print("Open DB");
    return theDb;
  }

  static backupDb() async {
    print('**************************************************');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String path = await getDatabasesPath();
    String pathDB = join(path, "${packageInfo.packageName}.db");

    if (await databaseExists(pathDB)) {
      // final pathEx = await getExternalStorageDirectory();

      // if (!await pathEx!.exists()) {
      //   await pathEx.create(recursive: true);
      // }

      final copy = File(join(
          'storage/emulated/0/Download/', "${packageInfo.packageName}.db"));
      print(copy.path);

      final db = File(pathDB);

      await db.copy(copy.path);
    }
    print('**************************************************');
  }

  static deleteDb() async {
    print('**************************************************');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String path = await getDatabasesPath();
    String pathDB = join(path, "${packageInfo.packageName}.db");
    if (_db!.isOpen) {
      _db!.close();
    }
    deleteDatabase(pathDB);
  }

  static Future<void> insert(final _object) async {
    Database _db = await DBHelper.db;
    await _db.insert(
      _object.modelName,
      _object.toMapSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> update(final _object) async {
    Database? _db = await DBHelper.db;
    await _db.update(
      _object.modelName,
      _object.toMapSQLite(),
      where: ' id = ? ',
      whereArgs: [_object.id],
    );
  }

  static Future<void> delete(final _object) async {
    Database? _db = await DBHelper.db;
    await _db.delete(
      _object.modelName,
      where: 'id = ?',
      whereArgs: [_object.id],
    );
  }

  static void onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE IF NOT EXISTS synchronizations (' +
        'id INT PRIMARY KEY,' +
        'user_id TEXT,' +
        'type TEXT,' +
        'date_start TEXT,' +
        'date_end TEXT,' +
        'status TEXT,' +
        'error TEXT' +
        ')');
    print("synchronizations table created");
    await db.execute('CREATE TABLE IF NOT EXISTS users (' +
        'id TEXT PRIMARY KEY,' +
        'username TEXT,' +
        'firstname TEXT,' +
        'lastname TEXT,' +
        'business_partner_id TEXT,' +
        'business_partner TEXT,' +
        'is_technical INTEGER,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT' +
        ')');
    print('**************************************************');
    print("users table created");
    await db.execute('CREATE TABLE IF NOT EXISTS projects (' +
        'id TEXT PRIMARY KEY,' +
        'client_id TEXT,' +
        'client TEXT,' +
        'organization_id TEXT,' +
        'organization TEXT,' +
        'searchkey TEXT,' +
        'name TEXT,' +
        'description TEXT,' +
        'documentno TEXT,' +
        'business_partner_id TEXT,' +
        'business_partner TEXT,' +
        'bp_address_id TEXT,' +
        'bp_address TEXT,' +
        'currency_id TEXT,' +
        'currency TEXT,' +
        'location TEXT,' +
        'sales_rep_id TEXT,' +
        'sales_rep TEXT,' +
        'person_in_charge_id TEXT,' +
        'person_in_charge TEXT,' +
        'machine_id TEXT,' +
        'machine TEXT,' +
        'brand_id TEXT,' +
        'brand TEXT,' +
        'model_id TEXT,' +
        'model TEXT,' +
        'hour_km TEXT,' +
        'serie TEXT,' +
        'bp_phone TEXT,' +
        'bp_email TEXT,' +
        'is_operative INT,' +
        'end_date TEXT,' +
        'geolocation TEXT,' +
        'signature_client_link TEXT,' +
        'signature_client_img_dir TEXT,' +
        'signature_client_name TEXT,' +
        'signature_client_cif_nif TEXT,' +
        'signature_tech_link TEXT,' +
        'signature_tech_img_dir TEXT,' +
        'signature_tech_name TEXT,' +
        'signature_tech_cif_nif TEXT,' +
        'remark TEXT,' +
        'km_summary REAL,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT,' +
        'down_locations INT' +
        ')');
    print('**************************************************');
    print("projects table created");
    await db.execute('CREATE TABLE IF NOT EXISTS project_phases (' +
        'id TEXT PRIMARY KEY,' +
        'project_id TEXT,' +
        'seqno INT,' +
        'name TEXT,' +
        'description TEXT,' +
        'starting TEXT,' +
        'ending TEXT,' +
        'product_id TEXT,' +
        'product TEXT,' +
        'quantity INT,' +
        'unit_price REAL,' +
        'is_complete INT,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT' +
        ')');
    print('**************************************************');
    print("project phases table created");
    await db.execute('CREATE TABLE IF NOT EXISTS project_tasks (' +
        'id TEXT PRIMARY KEY,' +
        'project_phase_id TEXT,' +
        'project_phase TEXT,' +
        'seqno INT,' +
        'name TEXT,' +
        'description TEXT,' +
        'starting TEXT,' +
        'ending TEXT,' +
        'idle_time REAL,' +
        'product_id TEXT,' +
        'product TEXT,' +
        'quantity REAL,' +
        'unit_price REAL,' +
        'is_going INT,' +
        'is_return INT,' +
        'status INT,' +
        'is_complete INT,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT' +
        ')');
    print('**************************************************');
    print("project tasks table created");
    await db.execute('CREATE TABLE IF NOT EXISTS activity_reports (' +
        'id TEXT PRIMARY KEY,' +
        'client_id TEXT,' +
        'client TEXT,' +
        'organization_id TEXT,' +
        'organization TEXT,' +
        'phone_id TEXT,' +
        'project_task_id TEXT,' +
        'report TEXT,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT' +
        ')');
    print('**************************************************');
    print("activity reports table created");
    await db.execute('CREATE TABLE IF NOT EXISTS pictures (' +
        'id TEXT PRIMARY KEY,' +
        'client_id TEXT,' +
        'client TEXT,' +
        'organization_id TEXT,' +
        'organization TEXT,' +
        'phone_id TEXT,' +
        'activity_report_id TEXT,' +
        'link TEXT,' +
        'img_dir TEXT,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT' +
        ')');
    print('**************************************************');
    print("pictures table created");
    await db.execute('CREATE TABLE IF NOT EXISTS spare_parts (' +
        'id TEXT PRIMARY KEY,' +
        'client_id TEXT,' +
        'client TEXT,' +
        'organization_id TEXT,' +
        'organization TEXT,' +
        'phone_id TEXT,' +
        'project_task_id TEXT,' +
        'code TEXT,' +
        'description TEXT,' +
        'quantity REAL,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT' +
        ')');
    print('**************************************************');
    print("spare parts table created");
    await db.execute('CREATE TABLE IF NOT EXISTS expenses (' +
        'id TEXT PRIMARY KEY,' +
        'client_id TEXT,' +
        'client TEXT,' +
        'organization_id TEXT,' +
        'organization TEXT,' +
        'phone_id TEXT,' +
        'project_id TEXT,' +
        'documentno TEXT,' +
        'business_partner_id TEXT,' +
        'report_date TEXT,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT' +
        ')');
    print('**************************************************');
    print("expenses table created");
    await db.execute('CREATE TABLE IF NOT EXISTS expense_lines (' +
        'id TEXT PRIMARY KEY,' +
        'client_id TEXT,' +
        'client TEXT,' +
        'organization_id TEXT,' +
        'organization TEXT,' +
        'phone_id TEXT,' +
        'expense_id TEXT,' +
        'project_id TEXT,' +
        'project_phase_id TEXT,' +
        'project_phase TEXT,' +
        'lineno INT,' +
        'invoiceno TEXT,' +
        'ruc TEXT,' +
        'name TEXT,' +
        'date TEXT,' +
        'expense_date TEXT,' +
        'expense_amount REAL,' +
        'converted_amount REAL,' +
        'invoice_price REAL,' +
        'product_id TEXT,' +
        'product TEXT,' +
        'city TEXT,' +
        'description TEXT,' +
        'uom_id TEXT,' +
        'currency_id TEXT,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT' +
        ')');
    print('**************************************************');
    print("expense lines table created");
    await db.execute('CREATE TABLE IF NOT EXISTS products (' +
        'id TEXT PRIMARY KEY,' +
        'name TEXT,' +
        'uom_id TEXT,' +
        'uom TEXT,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT' +
        ')');
    print('**************************************************');
    print("products table created");
    await db.execute('CREATE TABLE IF NOT EXISTS locations (' +
        'id INT PRIMARY KEY,' +
        'phone_id TEXT,' +
        'user_id TEXT,' +
        'project_id TEXT,' +
        'project_phase_id TEXT,' +
        'project_task_id TEXT,' +
        'latitude REAL,' +
        'longitude REAL,' +
        'type TEXT,' +
        'description TEXT,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT' +
        ')');
    print('**************************************************');
    print("locations table created");
    await db.execute('CREATE TABLE IF NOT EXISTS brands (' +
        'id TEXT PRIMARY KEY,' +
        'name TEXT,' +
        'description TEXT,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT' +
        ')');
    print('**************************************************');
    print("brands table created");
    await db.execute('CREATE TABLE IF NOT EXISTS models (' +
        'id TEXT PRIMARY KEY,' +
        'brand_id TEXT,' +
        'value TEXT,' +
        'name TEXT,' +
        'description TEXT,' +
        'created TEXT,' +
        'updated TEXT,' +
        'sync_up INT,' +
        'sync_up_date TEXT,' +
        'sync_up_status TEXT,' +
        'sync_up_error TEXT' +
        ')');
    print('**************************************************');
    print("models table created");
    print('**************************************************');
  }

  static void onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      try {
        await db.execute('ALTER TABLE project_tasks ADD COLUMN idle_time REAL');
      } catch (_) {}
      print('**************************************************');
      print("project_tasks table altered");

      await db.execute('CREATE TABLE IF NOT EXISTS brands (' +
          'id TEXT PRIMARY KEY,' +
          'name TEXT,' +
          'description TEXT,' +
          'created TEXT,' +
          'updated TEXT,' +
          'sync_up INT,' +
          'sync_up_date TEXT,' +
          'sync_up_status TEXT,' +
          'sync_up_error TEXT' +
          ')');
      print('**************************************************');
      print("brands table created");
      await db.execute('CREATE TABLE IF NOT EXISTS models (' +
          'id TEXT PRIMARY KEY,' +
          'brand_id TEXT,' +
          'value TEXT,' +
          'name TEXT,' +
          'description TEXT,' +
          'created TEXT,' +
          'updated TEXT,' +
          'sync_up INT,' +
          'sync_up_date TEXT,' +
          'sync_up_status TEXT,' +
          'sync_up_error TEXT' +
          ')');
      print('**************************************************');
      print("models table created");
      print('**************************************************');
    }
  }
}
