import 'package:workorders/models/sync_up.dart';
import 'package:workorders/utils/utils.dart';

class ActivityReport {
  static const _entityName = 'sotpe_activityreport';
  static const _modelName = 'activity_reports';

  String? id;
  String? clientId;
  String? client;
  String? organizationId;
  String? organization;
  String? phoneId;
  String projectTaskId;
  String report;
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

  ActivityReport(
      {this.id,
      required this.clientId,
      required this.client,
      required this.organizationId,
      required this.organization,
      this.phoneId,
      required this.projectTaskId,
      required this.report,
      this.created,
      this.updated,
      required this.syncUp});

  ActivityReport.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        clientId = json['client'],
        client = json['client\$_identifier'],
        organizationId = json['organization'],
        organization = json['organization\$_identifier'],
        phoneId = json['phoneId'],
        projectTaskId = json['projectTask'],
        report = json['report'],
        created = Utils.getDate(json['creationDate']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(isRequired: false);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'projectTask': projectTaskId,
      'report': report,
    };
    if (clientId != null && clientId!.isNotEmpty) {
      map['client'] = clientId;
    }
    if (organizationId != null && organizationId!.isNotEmpty) {
      map['organization'] = organizationId;
    }
    return map;
  }

  Map<String, dynamic> toMapSQLite() => {
        'id': id,
        'client_id': clientId,
        'client': client,
        'organization_id': organizationId,
        'organization': organization,
        'phone_id': phoneId,
        'project_task_id': projectTaskId,
        'report': report,
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
        'sync_up': syncUp.isRequired ? 1 : 0,
        'sync_up_date': syncUp.date?.toIso8601String(),
        'sync_up_status': syncUp.status,
        'sync_up_error': syncUp.error
      };

  ActivityReport.fromJsonSQLite(Map<String, dynamic> json)
      : id = json['id'],
        clientId = json['client_id'],
        client = json['client'],
        organizationId = json['organization_id'],
        organization = json['organization'],
        phoneId = json['phone_id'],
        projectTaskId = json['project_task_id'],
        report = json['report'],
        created = Utils.getDate(json['created']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(
            isRequired: json['sync_up'] == 1,
            date: Utils.getDate(json['sync_up_date']),
            status: json['sync_up_status'],
            error: json['sync_up_error']);
}
