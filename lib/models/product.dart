import 'package:workorders/models/sync_up.dart';
import 'package:workorders/utils/utils.dart';

class Product {
  static const _entityName = 'Product';
  static const _modelName = 'products';

  String id;
  String name;
  String uOMId;
  String uOM;
  DateTime? created;
  DateTime? updated;
  SyncUp syncUp;

  String get entityName {
    return _entityName;
  }

  String get modelName {
    return _modelName;
  }

  static String get sEntityName {
    return _entityName;
  }

  static String get sModelName {
    return _modelName;
  }

  Product(
      {required this.id,
      required this.name,
      required this.uOMId,
      required this.uOM,
      required this.created,
      required this.updated,
      required this.syncUp});

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        uOMId = json['uOM'],
        uOM = json['uOM\$_identifier'],
        created = Utils.getDate(json['creationDate']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(isRequired: false);

  Map<String, dynamic> toMapSQLite() => {
        'id': id,
        'name': name,
        'uom_id': uOMId,
        'uom': uOM,
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
        'sync_up': syncUp.isRequired ? 1 : 0,
        'sync_up_date': syncUp.date?.toIso8601String(),
        'sync_up_status': syncUp.status,
        'sync_up_error': syncUp.error
      };

  Product.fromJsonSQLite(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        uOMId = json['uom_id'],
        uOM = json['uom'],
        created = Utils.getDate(json['created']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(
            isRequired: json['sync_up'] == 1,
            date: Utils.getDate(json['sync_up_date']),
            status: json['sync_up_status'],
            error: json['sync_up_error']);
}
