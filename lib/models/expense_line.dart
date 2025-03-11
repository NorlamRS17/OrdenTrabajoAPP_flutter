import 'package:workorders/models/sync_up.dart';
import 'package:workorders/utils/utils.dart';

class ExpenseLine {
  static const _entityName = 'TimeAndExpenseSheetLine';
  static const _modelName = 'expense_lines';

  String? id;
  String? clientId;
  String? client;
  String? organizationId;
  String? organization;
  String? phoneId;
  String expenseId;
  String projectId;
  String? projectPhaseId;
  String? projectPhase;
  int? lineNo;
  String? invoiceNo;
  String ruc;
  String? name;
  DateTime? date;
  DateTime? expenseDate;
  double? expenseAmount;
  double? convertedAmount;
  double? invoicePrice;
  String productId;
  String product;
  String? city;
  String? description;
  String uOMId;
  String currencyId;
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

  ExpenseLine(
      {this.id,
      required this.clientId,
      required this.client,
      required this.organizationId,
      required this.organization,
      this.phoneId,
      required this.expenseId,
      required this.projectId,
      this.projectPhaseId,
      this.projectPhase,
      this.lineNo,
      required this.invoiceNo,
      required this.ruc,
      required this.name,
      this.date,
      this.expenseDate,
      this.expenseAmount,
      this.convertedAmount,
      this.invoicePrice,
      required this.productId,
      required this.product,
      required this.city,
      required this.description,
      required this.uOMId,
      required this.currencyId,
      this.created,
      this.updated,
      required this.syncUp});

  factory ExpenseLine.fromJson(Map<String, dynamic> json) {
    final _expenseLine = ExpenseLine(
      id: json['id'],
      clientId: json['client'],
      client: json['client\$_identifier'],
      organizationId: json['organization'],
      organization: json['organization\$_identifier'],
      phoneId: json['phoneId'],
      expenseId: json['expenseSheet'],
      projectId: json['project'],
      projectPhaseId: json['projectPhase'],
      projectPhase: json['projectPhase\$_identifier'],
      lineNo: json['lineNo'],
      invoiceNo: json['sotpeInvoiceno'],
      ruc: json['sotpeRuc'],
      name: json['sotpeName'],
      date: Utils.getDate(json['sotpeDate']),
      expenseDate: Utils.getDate(json['expenseDate']),
      expenseAmount: Utils.getDouble(json['expenseAmount']),
      convertedAmount: Utils.getDouble(json['convertedAmount']),
      invoicePrice: Utils.getDouble(json['invoicePrice']),
      productId: json['product'],
      product: json['product\$_identifier'],
      city: json['sotpeCity'],
      description: json['sotpeDescription'],
      uOMId: json['uOM'],
      currencyId: json['currency'],
      created: Utils.getDate(json['creationDate']),
      updated: Utils.getDate(json['updated']),
      syncUp: SyncUp(isRequired: false),
    );
    return _expenseLine;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'expenseSheet': expenseId,
      'project': projectId,
      'projectPhase': projectPhaseId,
      'lineNo': lineNo,
      'sotpeInvoiceno': invoiceNo,
      'sotpeRuc': ruc,
      'sotpeName': name,
      'sotpeDate': Utils.getDateOBFormat(date),
      'expenseDate': Utils.getDateOBFormat(expenseDate),
      'expenseAmount': expenseAmount,
      'convertedAmount': convertedAmount,
      'invoicePrice': invoicePrice,
      'product': productId,
      'sotpeCity': city,
      'sotpeDescription': description,
      'uOM': uOMId,
      'currency': currencyId,
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
        'expense_id': expenseId,
        'project_id': projectId,
        'project_phase_id': projectPhaseId,
        'project_phase': projectPhase,
        'lineno': lineNo,
        'invoiceno': invoiceNo,
        'ruc': ruc,
        'name': name,
        'date': date?.toIso8601String(),
        'expense_date': expenseDate?.toIso8601String(),
        'expense_amount': expenseAmount,
        'converted_amount': convertedAmount,
        'invoice_price': invoicePrice,
        'product_id': productId,
        'product': product,
        'city': city,
        'description': description,
        'uom_id': uOMId,
        'currency_id': currencyId,
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
        'sync_up': syncUp.isRequired ? 1 : 0,
        'sync_up_date': syncUp.date?.toIso8601String(),
        'sync_up_status': syncUp.status,
        'sync_up_error': syncUp.error
      };

  ExpenseLine.fromJsonSQLite(Map<String, dynamic> json)
      : id = json['id'],
        clientId = json['client_id'],
        client = json['client'],
        organizationId = json['organization_id'],
        organization = json['organization'],
        phoneId = json['phone_id'],
        expenseId = json['expense_id'],
        projectId = json['project_id'],
        projectPhaseId = json['project_phase_id'],
        projectPhase = json['project_phase'],
        lineNo = json['lineno'],
        invoiceNo = json['invoiceno'],
        ruc = json['ruc'],
        name = json['name'],
        date = Utils.getDate(json['date']),
        expenseDate = Utils.getDate(json['expense_date']),
        expenseAmount = Utils.getDouble(json['expense_amount']),
        convertedAmount = Utils.getDouble(json['converted_amount']),
        invoicePrice = Utils.getDouble(json['invoice_price']),
        productId = json['product_id'],
        product = json['product'],
        city = json['city'],
        description = json['description'],
        uOMId = json['uom_id'],
        currencyId = json['currency_id'],
        created = Utils.getDate(json['created']),
        updated = Utils.getDate(json['updated']),
        syncUp = SyncUp(
            isRequired: json['sync_up'] == 1,
            date: Utils.getDate(json['sync_up_date']),
            status: json['sync_up_status'],
            error: json['sync_up_error']);
}
