import 'package:workorders/models/sync_up.dart';
import 'package:workorders/utils/utils.dart';

class ProjectPhase {
  static const _entityName = 'ProjectPhase';
  static const _modelName = 'project_phases';

  String id;
  String projectId;
  int? seqNo;
  String name;
  String? description;
  DateTime? starting;
  DateTime? ending;
  String? productId;
  String? product;
  int? quantity;
  double? unitPrice;
  bool isComplete;
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

  ProjectPhase(
      {required this.id,
      required this.projectId,
      required this.seqNo,
      required this.name,
      required this.description,
      required this.starting,
      required this.ending,
      required this.productId,
      required this.product,
      required this.quantity,
      required this.unitPrice,
      required this.isComplete,
      required this.created,
      required this.updated,
      required this.syncUp});

  ProjectPhase.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        projectId = json['project'],
        seqNo = json['sequenceNumber'],
        name = json['name'],
        description = json['description'],
        starting = Utils.getDate(json['startingDate']),
        ending = Utils.getDate(json['endingDate']),
        productId = json['product'],
        product = json['product\$_identifier'],
        quantity = json['quantity'],
        unitPrice = Utils.getDouble(json['unitPrice']),
        isComplete = json['is_complete'] ?? false,
        created = Utils.getDate(json['creationDate']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(isRequired: false);

  Map<String, dynamic> toMapSQLite() => {
        'id': id,
        'project_id': projectId,
        'seqno': seqNo,
        'name': name,
        'description': description,
        'starting': starting?.toIso8601String(),
        'ending': ending?.toIso8601String(),
        'product_id': productId,
        'product': product,
        'quantity': quantity,
        'unit_price': unitPrice,
        'is_complete': isComplete ? 1 : 0,
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
        'sync_up': syncUp.isRequired ? 1 : 0,
        'sync_up_date': syncUp.date?.toIso8601String(),
        'sync_up_status': syncUp.status,
        'sync_up_error': syncUp.error
      };

  ProjectPhase.fromJsonSQLite(Map<String, dynamic> json)
      : id = json['id'],
        projectId = json['project_id'],
        seqNo = json['seqno'],
        name = json['name'],
        description = json['description'],
        starting = Utils.getDate(json['starting']),
        ending = Utils.getDate(json['ending']),
        productId = json['product_id'],
        product = json['product'],
        quantity = json['quantity'],
        unitPrice = json['unitPrice'],
        isComplete = json['is_complete'] == 1,
        created = Utils.getDate(json['created']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(
            isRequired: json['sync_up'] == 1,
            date: Utils.getDate(json['sync_up_date']),
            status: json['sync_up_status'],
            error: json['sync_up_error']);
}
