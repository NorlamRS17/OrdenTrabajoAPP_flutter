import 'package:intl/intl.dart';
import 'package:workorders/models/location.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/utils/utils.dart';

class ProjectTask {
  static const _entityName = 'ProjectTask';
  static const _modelName = 'project_tasks';

  String id;
  String projectPhaseId;
  String projectPhase;
  int? seqNo;
  String name;
  String? description;
  DateTime? starting;
  DateTime? ending;
  double? idleTime;
  String? productId;
  String? product;
  double? quantity;
  double? unitPrice;
  bool isGoing;
  bool isReturn;
  String status;
  bool isComplete;
  DateTime? created;
  DateTime? updated;
  SyncUp syncUp;

  List<Location>? locationEvents = [];
  List<Location>? locationPulses = [];

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

  String get startingFormat {
    return starting != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(starting!)
        : '';
  }

  String get endingFormat {
    return ending != null ? DateFormat('yyyy-MM-dd HH:mm').format(ending!) : '';
  }

  ProjectTask(
      {required this.id,
      required this.projectPhaseId,
      required this.projectPhase,
      required this.seqNo,
      required this.name,
      required this.description,
      required this.starting,
      required this.ending,
      required this.idleTime,
      required this.productId,
      required this.product,
      required this.quantity,
      required this.unitPrice,
      required this.isGoing,
      required this.isReturn,
      required this.status,
      required this.isComplete,
      required this.created,
      required this.updated,
      required this.syncUp});

  ProjectTask.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        projectPhaseId = json['projectPhase'],
        projectPhase = json['projectPhase\$_identifier'],
        seqNo = json['sequenceNumber'],
        name = json['name'],
        description = json['description'],
        starting = Utils.getDate(json['startingDate']),
        ending = Utils.getDate(json['endingDate']),
        idleTime = Utils.getDouble(json['scotapIdleTime']),
        productId = json['product'],
        product = json['product\$_identifier'],
        quantity = Utils.getDouble(json['quantity']),
        unitPrice = Utils.getDouble(json['unitPrice']),
        isGoing = json['sotpeMovgoing'] ?? false,
        isReturn = json['sotpeMobreturn'] ?? false,
        status = json['sotpeStatus'] ?? 'Sin iniciar',
        isComplete = json['complete'] ?? false,
        created = Utils.getDate(json['creationDate']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(isRequired: false);

  Map<String, dynamic> toMap() => {
        'id': id,
        'startingDate': Utils.getDateOBFormat(starting),
        'endingDate': Utils.getDateOBFormat(ending),
        'scotapIdleTime': idleTime,
        'sotpeStatus': status,
        'complete': isComplete,
      };

  Map<String, dynamic> toMapSQLite() => {
        'id': id,
        'project_phase_id': projectPhaseId,
        'project_phase': projectPhase,
        'seqno': seqNo,
        'name': name,
        'description': description,
        'starting': starting?.toIso8601String(),
        'ending': ending?.toIso8601String(),
        'idle_time': idleTime,
        'product_id': productId,
        'product': product,
        'quantity': quantity,
        'unit_price': unitPrice,
        'is_going': isGoing ? 1 : 0,
        'is_return': isReturn ? 1 : 0,
        'status': status,
        'is_complete': isComplete ? 1 : 0,
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
        'sync_up': syncUp.isRequired ? 1 : 0,
        'sync_up_date': syncUp.date?.toIso8601String(),
        'sync_up_status': syncUp.status,
        'sync_up_error': syncUp.error
      };

  ProjectTask.fromJsonSQLite(Map<String, dynamic> json)
      : id = json['id'],
        projectPhaseId = json['project_phase_id'],
        projectPhase = json['project_phase'],
        seqNo = json['seqno'],
        name = json['name'],
        description = json['description'],
        starting = Utils.getDate(json['starting']),
        ending = Utils.getDate(json['ending']),
        idleTime = json['idle_time'],
        productId = json['product_id'],
        product = json['product'],
        quantity = json['quantity'],
        isGoing = json['is_going'] == 1,
        isReturn = json['is_return'] == 1,
        status = json['status'],
        unitPrice = Utils.getDouble(json['unitPrice']),
        isComplete = json['is_complete'] == 1,
        created = Utils.getDate(json['created']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(
            isRequired: json['sync_up'] == 1,
            date: Utils.getDate(json['sync_up_date']),
            status: json['sync_up_status'],
            error: json['sync_up_error']);
}
