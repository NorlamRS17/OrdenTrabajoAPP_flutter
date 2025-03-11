import 'package:workorders/models/sync_up.dart';
import 'package:workorders/utils/utils.dart';

class Model {
  static const _entityName = 'ssfi_model_prod';
  static const _modelName = 'models';

  String id;
  String brandId;
  String value;
  String name;
  String? description;
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

  Model(
      {required this.id,
      required this.brandId,
      required this.value,
      required this.name,
      required this.description,
      required this.created,
      required this.updated,
      required this.syncUp});

  Model.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        brandId = json['brand'],
        value = json['value'],
        name = json['name'],
        description = json['description'],
        created = Utils.getDate(json['creationDate']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(isRequired: false);

  Map<String, dynamic> toMapSQLite() => {
        'id': id,
        'brand_id': brandId,
        'value': value,
        'name': name,
        'description': description,
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
        'sync_up': syncUp.isRequired ? 1 : 0,
        'sync_up_date': syncUp.date?.toIso8601String(),
        'sync_up_status': syncUp.status,
        'sync_up_error': syncUp.error
      };

  Model.fromJsonSQLite(Map<String, dynamic> json)
      : id = json['id'],
        brandId = json['brand_id'],
        value = json['value'],
        name = json['name'],
        description = json['description'],
        created = Utils.getDate(json['created']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(
            isRequired: json['sync_up'] == 1,
            date: Utils.getDate(json['sync_up_date']),
            status: json['sync_up_status'],
            error: json['sync_up_error']);
}
