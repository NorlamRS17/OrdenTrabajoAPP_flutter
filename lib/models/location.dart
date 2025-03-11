import 'package:intl/intl.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/utils/utils.dart';

class Location {
  static const _entityName = 'locations';
  static const _modelName = 'locations';

  int? id;
  String? phoneId;
  String? userId;
  String? projectId;
  String? projectPhaseId;
  String? projectTaskId;
  double latitude;
  double longitude;
  String type;
  String description;
  String? error;
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

  String get createdFormat {
    return created != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(created!)
        : '';
  }

  Location(
      {required this.id,
      required this.phoneId,
      required this.userId,
      required this.projectId,
      required this.projectPhaseId,
      required this.projectTaskId,
      required this.latitude,
      required this.longitude,
      required this.type,
      required this.description,
      required this.created,
      required this.updated,
      required this.syncUp});

  Location.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        phoneId = json['phoneId'],
        userId = json['user_id'],
        projectId = json['order_id'],
        projectPhaseId = json['stage_id'],
        projectTaskId = json['task_id'],
        latitude = Utils.getDouble(json['latitude'])!,
        longitude = Utils.getDouble(json['longitude'])!,
        type = json['type'],
        description = json['description'],
        error = json['error'],
        created = Utils.getDate(json['created']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(isRequired: false);

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'order_id': projectId,
        'stage_id': projectPhaseId,
        'task_id': projectTaskId,
        'latitude': latitude,
        'longitude': longitude,
        'type': type,
        'description': description,
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
      };

  Map<String, dynamic> toMapSQLite() => {
        'id': id,
        'phone_id': phoneId,
        'user_id': userId,
        'project_id': projectId,
        'project_phase_id': projectPhaseId,
        'project_task_id': projectTaskId,
        'latitude': latitude,
        'longitude': longitude,
        'type': type,
        'description': description,
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
        'sync_up': syncUp.isRequired ? 1 : 0,
        'sync_up_date': syncUp.date?.toIso8601String(),
        'sync_up_status': syncUp.status,
        'sync_up_error': syncUp.error
      };

  Location.fromJsonSQLite(Map<String, dynamic> json)
      : id = json['id'],
        phoneId = json['phone_id'],
        userId = json['user_id'],
        projectId = json['project_id'],
        projectPhaseId = json['project_phase_id'],
        projectTaskId = json['project_task_id'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        type = json['type'],
        description = json['description'],
        created = Utils.getDate(json['created']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(
            isRequired: json['sync_up'] == 1,
            date: Utils.getDate(json['sync_up_date']),
            status: json['sync_up_status'],
            error: json['sync_up_error']);
}
