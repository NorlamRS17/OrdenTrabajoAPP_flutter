import 'package:workorders/models/sync_up.dart';
import 'package:workorders/utils/utils.dart';

class User {
  static const _entityName = 'ADUser';
  static const _modelName = 'users';

  String id;
  String username;
  String? firstName;
  String? lastName;
  String businessPartnerId;
  String businessPartner;
  bool isTechnical;
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

  User(
      {required this.id,
      required this.username,
      required this.firstName,
      required this.lastName,
      required this.businessPartnerId,
      required this.businessPartner,
      required this.isTechnical,
      required this.created,
      required this.updated,
      required this.syncUp});

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        businessPartnerId = json['businessPartner'],
        businessPartner = json['businessPartner\$_identifier'],
        isTechnical = json['sotpeIstechnical'] ?? false,
        created = Utils.getDate(json['creationDate']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(isRequired: false);

  Map<String, dynamic> toMapSQLite() => {
        'id': id,
        'username': username,
        'firstname': firstName,
        'lastname': lastName,
        'business_partner_id': businessPartnerId,
        'business_partner': businessPartner,
        'is_technical': isTechnical ? 1 : 0,
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
        'sync_up': syncUp.isRequired ? 1 : 0,
        'sync_up_date': syncUp.date?.toIso8601String(),
        'sync_up_status': syncUp.status,
        'sync_up_error': syncUp.error
      };

  User.fromJsonSQLite(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        firstName = json['firstname'],
        lastName = json['lastname'],
        businessPartnerId = json['business_partner_id'],
        businessPartner = json['business_partner'],
        isTechnical = json['is_technical'] == 1,
        created = Utils.getDate(json['created']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(
            isRequired: json['sync_up'] == 1,
            date: Utils.getDate(json['sync_up_date']),
            status: json['sync_up_status'],
            error: json['sync_up_error']);
}
