import 'package:workorders/utils/utils.dart';

import '../models/activity_report.dart';
import '../models/expense.dart';
import '../models/expense_line.dart';
import '../models/location.dart';
import '../models/picture.dart';
import '../models/project.dart';
import '../models/project_task.dart';
import '../models/spare_part.dart';
import '../services/activity_report_service.dart';
import '../services/expense_line_service.dart';
import '../services/expense_service.dart';
import '../services/location_service.dart';
import '../services/picture_service.dart';
import '../services/project_service.dart';
import '../services/project_task_service.dart';
import '../services/spare_part_service.dart';
import '../utils/constants.dart';

abstract class Sync {
  static bool isRunning = false;

  static Future<void> syncUp() async {
    if (!isRunning && (await Utils.hasConnection())) {
      isRunning = true;

      print('Iniciando sincronización hacia el servidor');

      print('------------------------------------------------------------');
      print('Ordenes');
      print('------------------------------------------------------------');
      try {
        List<Project> _projects = await ProjectService.selectToSync();
        print(' - Cargando (${_projects.length}) registros');
        for (var _project in _projects) {
          try {
            _project = await ProjectService.postProject(_project);
          } catch (e) {
            print(e.toString());
          }
        }
      } catch (e) {
        print(e.toString());
      }
      print(' - Carga finalizada');

      print('------------------------------------------------------------');
      print('Tareas');
      print('------------------------------------------------------------');
      try {
        List<ProjectTask> _projectTasks =
            await ProjectTaskService.selectToSync();
        print(' - Cargando (${_projectTasks.length}) registros');
        for (var _projectTask in _projectTasks) {
          try {
            _projectTask =
                await ProjectTaskService.postProjectTask(_projectTask);
          } catch (e) {
            print(e.toString());
          }
        }
      } catch (e) {
        print(e.toString());
      }
      print(' - Carga finalizada');

      print('------------------------------------------------------------');
      print('Informes de actividad');
      print('------------------------------------------------------------');
      try {
        List<ActivityReport> _activityReports =
            await ActivityReportService.selectToSync();
        print(' - Cargando (${_activityReports.length}) registros');
        for (var _activityReport in _activityReports) {
          try {
            _activityReport =
                await ActivityReportService.postActivityReport(_activityReport);
            await PictureService.updateRelationships(
                projectTaskPhoneId: _activityReport.phoneId,
                projectTaskId: _activityReport.id!);
          } catch (e) {
            print(e.toString());
          }
        }
      } catch (e) {
        print(e.toString());
      }
      print(' - Carga finalizada');

      print('------------------------------------------------------------');
      print('Fotos de informes de actividad');
      print('------------------------------------------------------------');
      try {
        List<Picture> _pictures = await PictureService.selectToSync();
        print(' - Cargando (${_pictures.length}) registros');
        for (var _picture in _pictures) {
          try {
            _picture = await PictureService.postPicture(_picture);
          } catch (e) {
            print(e.toString());
          }
        }
      } catch (e) {
        print(e.toString());
      }
      print(' - Carga finalizada');

      print('------------------------------------------------------------');
      print('Repuestos adicionates');
      print('------------------------------------------------------------');
      try {
        List<SparePart> _spareParts = await SparePartService.selectToSync();
        print(' - Cargando (${_spareParts.length}) registros');
        for (var _sparePart in _spareParts) {
          try {
            _sparePart = await SparePartService.postSparePart(_sparePart);
          } catch (e) {
            print(e.toString());
          }
        }
      } catch (e) {
        print(e.toString());
      }
      print(' - Carga finalizada');

      print('------------------------------------------------------------');
      print('Gastos');
      print('------------------------------------------------------------');
      try {
        List<Expense> _expenses = await ExpenseService.selectToSync();
        print(' - Cargando (${_expenses.length}) registros');
        for (var _expense in _expenses) {
          try {
            _expense = await ExpenseService.postExpense(_expense);
            await ExpenseLineService.updateRelationships(
                expensePhoneId: _expense.phoneId, expenseId: _expense.id!);
          } catch (e) {
            print(' - Gasto (${_expense.documentNo}). ${e.toString()}');
          }
        }
      } catch (e) {
        print(e.toString());
      }
      print(' - Carga finalizada');

      print('------------------------------------------------------------');
      print('Gastos (líneas)');
      print('------------------------------------------------------------');
      try {
        List<ExpenseLine> _expenseLines =
            await ExpenseLineService.selectToSync();
        print(' - Cargando (${_expenseLines.length}) registros');
        for (var _expenseLine in _expenseLines) {
          try {
            _expenseLine =
                await ExpenseLineService.postExpenseLine(_expenseLine);
          } catch (e) {
            print(' - Factura (${_expenseLine.invoiceNo}). ${e.toString()}');
          }
        }
      } catch (e) {
        print(e.toString());
      }
      print(' - Carga finalizada');

      print('------------------------------------------------------------');
      print('Sincronización hacia el servidor finalizada');
      print('------------------------------------------------------------');

      print('');
      print('Iniciando sincronización de localizaciones hacia el servidor');
      print('------------------------------------------------------------');
      print('Localizaciones');
      print('------------------------------------------------------------');
      try {
        List<Location> _locations = await LocationService.selectToSync();
        print(' - Cargando (${_locations.length}) registros');
        if (_locations.isNotEmpty) {
          int _errors = 0;
          int from = 0;
          int to = _locations.length > LOCATION_ARRAY_MAX_LENGTH
              ? LOCATION_ARRAY_MAX_LENGTH
              : _locations.length;
          do {
            if (from > 0) {
              to = to + LOCATION_ARRAY_MAX_LENGTH > _locations.length
                  ? _locations.length
                  : to + LOCATION_ARRAY_MAX_LENGTH;
            }
            List<Location> _subList = _locations.sublist(from, to);
            try {
              if (await Utils.hasConnection()) {
                _errors += await LocationService.postLocations(_subList);
              }
            } catch (e) {
              print(e.toString());
            }
            from = to;
          } while (to < _locations.length);
          if (_errors > 0) {
            print(' - Con errores: $_errors');
          }
        }
      } catch (e) {
        print(e.toString());
      }
      print(' - Carga finalizada');

      print('------------------------------------------------------------');
      print('Sincronización de localizaciones hacia el servidor finalizada');
      print('------------------------------------------------------------');

      isRunning = false;
    }
  }
}
