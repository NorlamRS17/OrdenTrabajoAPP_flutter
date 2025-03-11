import 'package:intl/intl.dart';
import 'package:workorders/models/location.dart';
import 'package:workorders/models/project_task.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/utils/utils.dart';

class Project {
  static const _entityName = 'Project';
  static const _modelName = 'projects';

  String id;
  String? clientId;
  String? client;
  String? organizationId;
  String? organization;
  String searchKey;
  String name;
  String? description;
  String documentNo;
  String businessPartnerId;
  String businessPartner;
  String bPAddressId;
  String bPAddress;
  String currencyId;
  String currency;
  String? location;
  String? salesRepId;
  String? salesRep;
  String personInChargeId;
  String personInCharge;
  String? machineId;
  String? machine;
  String? brandId;
  String? brand;
  String? modelId;
  String? model;
  String? hourKm;
  String? serie;
  String? bPPhone;
  String? bPEmail;
  bool isOperative;
  DateTime? endDate;
  String? geolocation;
  String? signatureClientLink;
  String? signatureClientImgDir;
  String? signatureClientName;
  String? signatureClientCifNif;
  String? signatureTechLink;
  String? signatureTechImgDir;
  String? signatureTechName;
  String? signatureTechCifNif;
  String? remark;
  double? kmSummary;
  DateTime? created;
  DateTime? updated;
  SyncUp syncUp;
  bool downLocations;

  List<ProjectTask>? projectTasks = [];
  List<Location>? locationEvents = [];

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
    return created != null ? DateFormat('yyyy-MM-dd').format(created!) : '';
  }

  Project(
      {required this.id,
      required this.clientId,
      required this.client,
      required this.organizationId,
      required this.organization,
      required this.searchKey,
      required this.name,
      required this.description,
      required this.documentNo,
      required this.businessPartnerId,
      required this.businessPartner,
      required this.bPAddressId,
      required this.bPAddress,
      required this.currencyId,
      required this.currency,
      required this.location,
      required this.salesRepId,
      required this.salesRep,
      required this.personInChargeId,
      required this.personInCharge,
      required this.machineId,
      required this.machine,
      required this.brandId,
      required this.brand,
      required this.modelId,
      required this.model,
      required this.hourKm,
      required this.serie,
      required this.bPPhone,
      required this.bPEmail,
      required this.isOperative,
      required this.endDate,
      required this.geolocation,
      required this.signatureClientLink,
      required this.signatureClientImgDir,
      required this.signatureClientName,
      required this.signatureClientCifNif,
      required this.signatureTechLink,
      required this.signatureTechImgDir,
      required this.signatureTechName,
      required this.signatureTechCifNif,
      required this.remark,
      required this.kmSummary,
      required this.created,
      required this.updated,
      required this.syncUp,
      required this.downLocations});

  Project.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        searchKey = json['searchKey'],
        clientId = json['client'],
        client = json['client\$_identifier'],
        organizationId = json['organization'],
        organization = json['organization\$_identifier'],
        name = json['name'],
        description = json['description'],
        documentNo = json['maspmqDocumentno'],
        businessPartnerId = json['businessPartner'],
        businessPartner = json['businessPartner\$_identifier'],
        bPAddressId = json['partnerAddress'],
        bPAddress = json['partnerAddress\$_identifier'],
        currencyId = json['currency'],
        currency = json['currency\$_identifier'],
        location = json['maspmqLocate'],
        salesRepId = json['salesRepresentative'],
        salesRep = json['salesRepresentative\$_identifier'],
        personInChargeId = json['personInCharge'],
        personInCharge = json['personInCharge\$_identifier'],
        machineId = json['maspmqMachine'],
        machine = json['maspmqMachine\$_identifier'],
        brandId = json['maspmqMbrand'],
        brand = json['maspmqMbrand\$_identifier'],
        modelId = json['maspmqModel'],
        model = json['maspmqModel\$_identifier'],
        hourKm = json['sotpeHourkm'],
        serie = json['maspmqSerie'],
        bPPhone = json['maspmqBpartnerphone'],
        bPEmail = json['maspmqBpartnermail'],
        isOperative = json['maspmqIsoperative'] ?? false,
        endDate = Utils.getDate(json['sotpeEnddate']),
        geolocation = json['sotpeGeolocation'],
        signatureClientLink = json['sotpeAccSignature'],
        signatureClientImgDir = json['sotpeAccSignatureImgDir'],
        signatureClientName = json['sotpeAccName'],
        signatureClientCifNif = json['sotpeAccCifnif'],
        signatureTechLink = json['sotpeAccSignatureTech'],
        signatureTechImgDir = json['sotpeAccSignatureTechImgDir'],
        signatureTechName = json['sotpeAccNameTech'],
        signatureTechCifNif = json['sotpeAccCifnifTech'],
        remark = json['sotpeGeneralobs'],
        kmSummary = Utils.getDouble(json['sotpeKmSummary']),
        created = Utils.getDate(json['creationDate']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(isRequired: false),
        downLocations = false;

  Map<String, dynamic> toMap() => {
        'id': id,
        'maspmqMbrand': brandId,
        'maspmqModel': modelId,
        'maspmqSerie': serie,
        'maspmqLocate': location,
        'maspmqIsoperative': isOperative,
        'sotpeHourkm': hourKm,
        'sotpeEnddate': Utils.getDateOBFormat(endDate),
        'sotpeGeolocation': geolocation,
        'sotpeAccName': signatureClientName,
        'sotpeAccCifnif': signatureClientCifNif,
        'sotpeAccNameTech': signatureTechName,
        'sotpeAccCifnifTech': signatureTechCifNif,
        'sotpeGeneralobs': remark,
        'sotpeKmSummary': kmSummary,
      };

  Map<String, dynamic> toMapSQLite() => {
        'id': id,
        'client_id': clientId,
        'client': client,
        'organization_id': organizationId,
        'organization': organization,
        'searchkey': searchKey,
        'name': name,
        'description': description,
        'documentno': documentNo,
        'business_partner_id': businessPartnerId,
        'business_partner': businessPartner,
        'bp_address_id': bPAddressId,
        'bp_address': bPAddress,
        'currency_id': currencyId,
        'currency': currency,
        'location': location,
        'sales_rep_id': salesRepId,
        'sales_rep': salesRep,
        'person_in_charge_id': personInChargeId,
        'person_in_charge': personInCharge,
        'machine_id': machineId,
        'machine': machine,
        'brand_id': brandId,
        'brand': brand,
        'model_id': modelId,
        'model': model,
        'hour_km': hourKm,
        'serie': serie,
        'bp_phone': bPPhone,
        'bp_email': bPEmail,
        'is_operative': isOperative ? 1 : 0,
        'end_date': endDate?.toIso8601String(),
        'geolocation': geolocation,
        'signature_client_link': signatureClientLink,
        'signature_client_img_dir': signatureClientImgDir,
        'signature_client_name': signatureClientName,
        'signature_client_cif_nif': signatureClientCifNif,
        'signature_tech_link': signatureTechLink,
        'signature_tech_img_dir': signatureTechImgDir,
        'signature_tech_name': signatureTechName,
        'signature_tech_cif_nif': signatureTechCifNif,
        'remark': remark,
        'km_summary': kmSummary,
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
        'sync_up': syncUp.isRequired ? 1 : 0,
        'sync_up_date': syncUp.date?.toIso8601String(),
        'sync_up_status': syncUp.status,
        'sync_up_error': syncUp.error,
        'down_locations': downLocations ? 1 : 0
      };

  Project.fromJsonSQLite(Map<String, dynamic> json)
      : id = json['id'],
        clientId = json['client_id'],
        client = json['client'],
        organizationId = json['organization_id'],
        organization = json['organization'],
        searchKey = json['searchkey'],
        name = json['name'],
        description = json['description'],
        documentNo = json['documentno'],
        businessPartnerId = json['business_partner_id'],
        businessPartner = json['business_partner'],
        bPAddressId = json['bp_address_id'],
        bPAddress = json['bp_address'],
        currencyId = json['currency_id'],
        currency = json['currency'],
        location = json['location'],
        salesRepId = json['sales_rep_id'],
        salesRep = json['sales_rep'],
        personInChargeId = json['person_in_charge_id'],
        personInCharge = json['person_in_charge'],
        machineId = json['machine_id'],
        machine = json['machine'],
        brandId = json['brand_id'],
        brand = json['brand'],
        modelId = json['model_id'],
        model = json['model'],
        hourKm = json['hour_km'],
        serie = json['serie'],
        bPPhone = json['bp_phone'],
        bPEmail = json['bp_email'],
        isOperative = json['is_operative'] == 1,
        endDate = Utils.getDate(json['end_date']),
        geolocation = json['geolocation'],
        signatureClientLink = json['signature_client_link'],
        signatureClientImgDir = json['signature_client_img_dir'],
        signatureClientName = json['signature_client_name'],
        signatureClientCifNif = json['signature_client_cif_nif'],
        signatureTechLink = json['signature_tech_link'],
        signatureTechImgDir = json['signature_tech_img_dir'],
        signatureTechName = json['signature_tech_name'],
        signatureTechCifNif = json['signature_tech_cif_nif'],
        remark = json['remark'],
        kmSummary = json['km_summary'],
        created = Utils.getDate(json['created']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(
            isRequired: json['sync_up'] == 1,
            date: Utils.getDate(json['sync_up_date']),
            status: json['sync_up_status'],
            error: json['sync_up_error']),
        downLocations = json['down_locations'] == 1;
}
