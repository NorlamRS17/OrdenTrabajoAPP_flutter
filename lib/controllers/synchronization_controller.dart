import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workorders/models/activity_report.dart';
import 'package:workorders/models/brand.dart';
import 'package:workorders/models/expense.dart';
import 'package:workorders/models/expense_line.dart';
import 'package:workorders/models/location.dart';
import 'package:workorders/models/model.dart';
import 'package:workorders/models/picture.dart';
import 'package:workorders/models/product.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/project_phase.dart';
import 'package:workorders/models/project_task.dart';
import 'package:workorders/models/spare_part.dart';
import 'package:workorders/models/synchronization.dart';
import 'package:workorders/services/activity_report_service.dart';
import 'package:workorders/services/brand_service.dart';
import 'package:workorders/services/expense_line_service.dart';
import 'package:workorders/services/expense_service.dart';
import 'package:workorders/services/location_service.dart';
import 'package:workorders/services/model_service.dart';
import 'package:workorders/services/picture_service.dart';
import 'package:workorders/services/product_service.dart';
import 'package:workorders/services/project_phase_service.dart';
import 'package:workorders/services/project_service.dart';
import 'package:workorders/services/project_task_service.dart';
import 'package:workorders/services/spare_part_service.dart';
import 'package:workorders/services/synchronization_service.dart';
import 'package:workorders/utils/db_helper.dart';
import 'package:workorders/utils/utils.dart';

import '../utils/constants.dart';

class SynchronizationController extends ChangeNotifier {
  late bool isProcessing;
  List<String> log = [];
  String? dateStart;
  String? dateEnd;

  SynchronizationController() {
    isProcessing = false;
  }

  Future<void> synchronizationDown() async {
    isProcessing = true;
    notifyListeners();
    Synchronization? _sync;
    try {
      DateTime _date;
      Synchronization? _lastSyncDown =
          await SynchronizationService.selectLastSyncDown();

      _sync = await SynchronizationService.insert(type: 'DOWN');
      if (_lastSyncDown != null) {
        dateStart ??= _lastSyncDown.dateStartFormat;
        if (dateEnd == null) {
          log.add('Iniciando sincronización desde el servidor (>= $dateStart)');
        } else {
          log.add(
              'Iniciando sincronización desde el servidor (>= $dateStart & <= $dateEnd)');
          _date = Utils.getDate(dateEnd)!;
          _date = _date.add(Duration(days: 1));
          dateEnd = DateFormat('yyyy-MM-dd').format(_date);
        }
      } else {
        _date = DateTime.now();
        _date = _date.subtract(Duration(days: SYNC_DAYS_AGO));
        dateStart = DateFormat('yyyy-MM-dd').format(_date);
        log.add('Iniciando sincronización desde el servidor (>= $dateStart)');
      }

      log.add('------------------------------------------------------------');
      log.add('Ordenes');
      log.add('------------------------------------------------------------');

      notifyListeners();
      List<Project> _projects = await ProjectService.getProject(
          dateStart: dateStart, dateEnd: dateEnd);
      log.add(' - Descargando (${_projects.length}) registros');
      notifyListeners();
      for (var _project in _projects) {
        await ProjectService.insertFromSync(_project);
      }

      log.add(' - Descarga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Fases');
      log.add('------------------------------------------------------------');

      notifyListeners();
      List<ProjectPhase> _projectPhases =
          await ProjectPhaseService.getProjectPhases(
              dateStart: dateStart, dateEnd: dateEnd);
      log.add(' - Descargando (${_projectPhases.length}) registros');
      notifyListeners();
      for (var _projectPhase in _projectPhases) {
        await ProjectPhaseService.insertFromSync(_projectPhase);
      }

      log.add(' - Descarga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Tareas');
      log.add('------------------------------------------------------------');

      notifyListeners();
      List<ProjectTask> _projectTasks =
          await ProjectTaskService.getProjectTasks(
              dateStart: dateStart, dateEnd: dateEnd);
      log.add(' - Descargando (${_projectTasks.length}) registros');
      notifyListeners();
      for (var _projectTask in _projectTasks) {
        await ProjectTaskService.insertFromSync(_projectTask);
      }

      log.add(' - Descarga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Informes de actividad');
      log.add('------------------------------------------------------------');

      notifyListeners();
      List<ActivityReport> _activityReports =
          await ActivityReportService.getActivityReports(
              dateStart: dateStart, dateEnd: dateEnd);
      log.add(' - Descargando (${_activityReports.length}) registros');
      notifyListeners();
      for (var _activityReport in _activityReports) {
        await ActivityReportService.insertFromSync(_activityReport);
      }

      log.add(' - Descarga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Fotos de informes de actividad');
      log.add('------------------------------------------------------------');

      notifyListeners();
      List<Picture> _pictures = await PictureService.getPictures(
          dateStart: dateStart, dateEnd: dateEnd);
      log.add(' - Descargando (${_pictures.length}) registros');
      notifyListeners();
      for (var _picture in _pictures) {
        await PictureService.insertFromSync(_picture);
      }

      log.add(' - Descarga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Repuestos adicionates');
      log.add('------------------------------------------------------------');

      notifyListeners();
      List<SparePart> _spareParts = await SparePartService.getSpareParts(
          dateStart: dateStart, dateEnd: dateEnd);
      log.add(' - Descargando (${_spareParts.length}) registros');
      notifyListeners();
      for (var _sparePart in _spareParts) {
        await SparePartService.insertFromSync(_sparePart);
      }

      log.add(' - Descarga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Tipos de gastos');
      log.add('------------------------------------------------------------');

      notifyListeners();
      List<Product> _products = await ProductService.getProducts();
      log.add(' - Descargando (${_products.length}) registros');
      notifyListeners();
      for (var _product in _products) {
        await ProductService.insertFromSync(_product);
      }

      log.add(' - Descarga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Gastos');
      log.add('------------------------------------------------------------');

      notifyListeners();
      List<Expense> _expenses = await ExpenseService.getExpenses(
          dateStart: dateStart, dateEnd: dateEnd);
      log.add(' - Descargando (${_expenses.length}) registros');
      notifyListeners();
      for (var _expense in _expenses) {
        await ExpenseService.insertFromSync(_expense);
      }

      log.add(' - Descarga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Gastos (líneas)');
      log.add('------------------------------------------------------------');

      notifyListeners();
      List<ExpenseLine> _expenseLines =
          await ExpenseLineService.getExpenseLines(
              dateStart: dateStart, dateEnd: dateEnd);
      log.add(' - Descargando (${_expenseLines.length}) registros');
      notifyListeners();
      for (var _expenseLine in _expenseLines) {
        await ExpenseLineService.insertFromSync(_expenseLine);
      }

      log.add(' - Descarga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Marcas');
      log.add('------------------------------------------------------------');

      notifyListeners();
      List<Brand> _brands = await BrandService.getBrands();
      log.add(' - Descargando (${_brands.length}) registros');
      notifyListeners();
      for (var _brand in _brands) {
        await BrandService.insertFromSync(_brand);
      }

      log.add(' - Descarga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Modelos');
      log.add('------------------------------------------------------------');

      notifyListeners();
      List<Model> _models = await ModelService.getModels();
      log.add(' - Descargando (${_models.length}) registros');
      notifyListeners();
      for (var _model in _models) {
        await ModelService.insertFromSync(_model);
      }

      log.add(' - Descarga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Sincronización desde el servidor finalizada');
      log.add('------------------------------------------------------------');
      log.add('');

      _sync.dateEnd = DateTime.now();
      _sync.status = 'OK';
      await DBHelper.update(_sync);
    } catch (e) {
      log.add(e.toString());
      _sync?.dateEnd = DateTime.now();
      _sync?.status = 'ERROR';
      _sync?.error = e.toString();
      await DBHelper.update(_sync);
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> synchronizationUp() async {
    isProcessing = true;
    notifyListeners();
    Synchronization? _sync;
    try {
      _sync = await SynchronizationService.insert(type: 'UP');
      log.add('Iniciando sincronización hacia el servidor');
      notifyListeners();
      List<Project> _projects = await ProjectService.selectToSync();
      log.add('------------------------------------------------------------');
      log.add('Ordenes');
      log.add('------------------------------------------------------------');
      log.add(' - Cargando (${_projects.length}) registros');
      notifyListeners();
      for (var _project in _projects) {
        try {
          _project = await ProjectService.postProject(_project);
        } catch (e) {
          log.add(e.toString());
        }
      }

      log.add(' - Carga finalizada');

      List<ProjectTask> _projectTasks = await ProjectTaskService.selectToSync();

      log.add('------------------------------------------------------------');
      log.add('Tareas');
      log.add('------------------------------------------------------------');
      log.add(' - Cargando (${_projectTasks.length}) registros');

      notifyListeners();
      for (var _projectTask in _projectTasks) {
        try {
          _projectTask = await ProjectTaskService.postProjectTask(_projectTask);
        } catch (e) {
          log.add(e.toString());
        }
      }

      log.add(' - Carga finalizada');

      List<ActivityReport> _activityReports =
          await ActivityReportService.selectToSync();

      log.add('------------------------------------------------------------');
      log.add('Informes de actividad');
      log.add('------------------------------------------------------------');
      log.add(' - Cargando (${_activityReports.length}) registros');

      notifyListeners();
      for (var _activityReport in _activityReports) {
        try {
          _activityReport =
              await ActivityReportService.postActivityReport(_activityReport);
          await PictureService.updateRelationships(
              projectTaskPhoneId: _activityReport.phoneId,
              projectTaskId: _activityReport.id!);
        } catch (e) {
          log.add(e.toString());
        }
      }

      log.add(' - Carga finalizada');

      List<Picture> _pictures = await PictureService.selectToSync();

      log.add('------------------------------------------------------------');
      log.add('Fotos de informes de actividad');
      log.add('------------------------------------------------------------');
      log.add(' - Cargando (${_pictures.length}) registros');

      notifyListeners();
      for (var _picture in _pictures) {
        try {
          _picture = await PictureService.postPicture(_picture);
        } catch (e) {
          log.add(e.toString());
        }
      }

      log.add(' - Carga finalizada');

      List<SparePart> _spareParts = await SparePartService.selectToSync();

      log.add('------------------------------------------------------------');
      log.add('Repuestos adicionates');
      log.add('------------------------------------------------------------');
      log.add(' - Cargando (${_spareParts.length}) registros');

      notifyListeners();
      for (var _sparePart in _spareParts) {
        try {
          _sparePart = await SparePartService.postSparePart(_sparePart);
        } catch (e) {
          log.add(e.toString());
        }
      }

      log.add(' - Carga finalizada');

      List<Expense> _expenses = await ExpenseService.selectToSync();

      log.add('------------------------------------------------------------');
      log.add('Gastos');
      log.add('------------------------------------------------------------');
      log.add(' - Cargando (${_expenses.length}) registros');

      notifyListeners();
      for (var _expense in _expenses) {
        try {
          _expense = await ExpenseService.postExpense(_expense);
          await ExpenseLineService.updateRelationships(
              expensePhoneId: _expense.phoneId, expenseId: _expense.id!);
        } catch (e) {
          log.add(' - Gasto (${_expense.documentNo}). ${e.toString()}');
        }
      }

      log.add(' - Carga finalizada');

      List<ExpenseLine> _expenseLines = await ExpenseLineService.selectToSync();

      log.add('------------------------------------------------------------');
      log.add('Gastos (líneas)');
      log.add('------------------------------------------------------------');
      log.add(' - Cargando (${_expenseLines.length}) registros');

      notifyListeners();
      for (var _expenseLine in _expenseLines) {
        try {
          _expenseLine = await ExpenseLineService.postExpenseLine(_expenseLine);
        } catch (e) {
          log.add(' - Factura (${_expenseLine.invoiceNo}). ${e.toString()}');
        }
      }

      log.add(' - Carga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Sincronización hacia el servidor finalizada');
      log.add('------------------------------------------------------------');
      log.add('');

      _sync.dateEnd = DateTime.now();
      _sync.status = 'OK';
      await DBHelper.update(_sync);
    } catch (e) {
      log.add(e.toString());
      _sync?.dateEnd = DateTime.now();
      _sync?.status = 'ERROR';
      _sync?.error = e.toString();
      await DBHelper.update(_sync);
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> uploadLocations() async {
    isProcessing = true;
    notifyListeners();
    try {
      log.add('Iniciando sincronización de localizaciones hacia el servidor');

      List<Location> _locations = await LocationService.selectToSync();

      log.add('------------------------------------------------------------');
      log.add('Localizaciones');
      log.add('------------------------------------------------------------');
      log.add(' - Cargando (${_locations.length}) registros');
      log.add(' - 0 registros cargados');

      notifyListeners();
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
            _errors += await LocationService.postLocations(_subList);
            log[log.length - 1] = ' - $to registros cargados';
            notifyListeners();
          } catch (e) {
            log.add(e.toString());
          }
          from = to;
        } while (to < _locations.length);
        if (_errors > 0) {
          log.add(' - Con errores: $_errors');
        }
      }

      log.add(' - Carga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Sincronización de localizaciones hacia el servidor finalizada');
      log.add('------------------------------------------------------------');
      log.add('');
    } catch (e) {
      log.add(e.toString());
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> downloadLocations({Project? project}) async {
    isProcessing = true;
    notifyListeners();
    try {
      if (project != null) {
        log.add(
            'Iniciando sincronización desde el servidor (Orden ${project.documentNo})');
      } else {
        log.add(
            'Iniciando sincronización desde el servidor (>= $dateStart & <= $dateEnd)');
      }

      log.add('------------------------------------------------------------');
      log.add('Localizaciones');
      log.add('------------------------------------------------------------');

      notifyListeners();
      int _totalRows = await LocationService.getTotalRows(
          dateStart: dateStart, dateEnd: dateEnd, projectId: project?.id);
      log.add(' - Descargando (${_totalRows}) registros');
      log.add(' - 0 registros insertados');
      notifyListeners();
      int skip = 0;
      int count = 0;
      if (_totalRows > 0) {
        do {
          if (count > 0) {
            skip = skip + LOCATION_ARRAY_MAX_LENGTH > _totalRows
                ? _totalRows
                : skip + LOCATION_ARRAY_MAX_LENGTH;
          }

          int take = _totalRows - skip > LOCATION_ARRAY_MAX_LENGTH
              ? LOCATION_ARRAY_MAX_LENGTH
              : _totalRows - skip;

          List<Location> _locations = await LocationService.getLocations(
              dateStart: dateStart,
              dateEnd: dateEnd,
              projectId: project?.id,
              skip: skip,
              take: take);
          for (var _location in _locations) {
            await LocationService.insertFromSync(_location);
            log[log.length - 1] = ' - ${++count} registros insertados';
            notifyListeners();
          }
        } while (count < _totalRows);
      }

      log.add(' - Descarga finalizada');
      log.add('------------------------------------------------------------');
      log.add('Sincronización desde el servidor finalizada');
      log.add('------------------------------------------------------------');
      log.add('');
    } catch (e) {
      log.add(e.toString());
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> setFilters({String? dateStart, String? dateEnd}) async {
    isProcessing = true;
    notifyListeners();
    try {
      this.dateStart = dateStart;
      this.dateEnd = dateEnd;
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
