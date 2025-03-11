import 'package:intl/intl.dart';
import 'package:workorders/utils/utils.dart';

class Synchronization {
  static const _modelName = 'synchronizations';

  String id;
  String userId;
  String type;
  DateTime dateStart;
  DateTime? dateEnd;
  String? status;
  String? error;

  String get modelName {
    return _modelName;
  }

  static String get sModelName {
    return _modelName;
  }

  String get dateStartFormat {
    return DateFormat('yyyy-MM-dd').format(dateStart);
  }

  Synchronization(
      {required this.id,
      required this.userId,
      required this.type,
      required this.dateStart,
      required this.dateEnd,
      required this.status,
      this.error});

  Map<String, dynamic> toMapSQLite() => {
        'id': id,
        'user_id': userId,
        'type': type,
        'date_start': dateStart.toIso8601String(),
        'date_end': dateEnd?.toIso8601String(),
        'status': status,
        'error': error,
      };

  Synchronization.fromJsonSQLite(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        type = json['type'],
        dateStart = Utils.getDate(json['date_start'])!,
        dateEnd = Utils.getDate(json['date_end']),
        status = json['status'],
        error = json['error'];
}
