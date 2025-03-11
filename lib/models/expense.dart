import 'package:workorders/models/sync_up.dart';
import 'package:workorders/utils/utils.dart';

class Expense {
  static const _entityName = 'TimeAndExpenseSheet';
  static const _modelName = 'expenses';

  String? id;
  String? clientId;
  String? client;
  String? organizationId;
  String? organization;
  String? phoneId;
  String projectId;
  String? documentNo;
  String? businessPartnerId;
  DateTime? reportDate;
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

  Expense(
      {this.id,
      required this.clientId,
      required this.client,
      required this.organizationId,
      required this.organization,
      this.phoneId,
      required this.projectId,
      required this.documentNo,
      this.businessPartnerId,
      this.reportDate,
      this.created,
      this.updated,
      required this.syncUp});

  Expense.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        clientId = json['client'],
        client = json['client\$_identifier'],
        organizationId = json['organization'],
        organization = json['organization\$_identifier'],
        phoneId = json['phoneId'],
        projectId = json['project'],
        documentNo = json['documentNo'],
        businessPartnerId = json['businessPartner'],
        reportDate = Utils.getDate(json['reportDate'])!,
        created = Utils.getDate(json['creationDate']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(isRequired: false);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'project': projectId,
      'documentNo': documentNo,
      'businessPartner': businessPartnerId,
      'reportDate': Utils.getDateOBFormat(reportDate)
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
        'project_id': projectId,
        'documentno': documentNo,
        'business_partner_id': businessPartnerId,
        'report_date': reportDate?.toIso8601String(),
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
        'sync_up': syncUp.isRequired ? 1 : 0,
        'sync_up_date': syncUp.date?.toIso8601String(),
        'sync_up_status': syncUp.status,
        'sync_up_error': syncUp.error
      };

  Expense.fromJsonSQLite(Map<String, dynamic> json)
      : id = json['id'],
        clientId = json['client_id'],
        client = json['client'],
        organizationId = json['organization_id'],
        organization = json['organization'],
        phoneId = json['phone_id'],
        projectId = json['project_id'],
        documentNo = json['documentno'],
        businessPartnerId = json['business_partner_id'],
        reportDate = Utils.getDate(json['report_date']),
        created = Utils.getDate(json['created']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(
            isRequired: json['sync_up'] == 1,
            date: Utils.getDate(json['sync_up_date']),
            status: json['sync_up_status'],
            error: json['sync_up_error']);
}
