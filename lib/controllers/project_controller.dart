import 'package:flutter/material.dart';
import 'package:workorders/models/location.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/services/location_service.dart';
import 'package:workorders/services/project_service.dart';
import 'package:workorders/services/project_task_service.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/utils.dart';

class ProjectController extends ChangeNotifier {
  late bool isProcessing;
  late List<Project> projects;
  bool showFinishProjectButton = false;
  bool showSignatures = false;
  String? dateStart;
  String? dateEnd;
  String? documentNo;

  ProjectController() {
    isProcessing = false;
    projects = [];
  }

  Future<void> getProjects(int _bottomNavigationBarIndex) async {
    isProcessing = true;
    notifyListeners();
    try {
      if (_bottomNavigationBarIndex == 0) {
        projects = await ProjectService.select(
            isCompleted: false,
            dateStart: dateStart,
            dateEnd: dateEnd,
            documentNo: documentNo);
      } else if (_bottomNavigationBarIndex == 1) {
        projects = await ProjectService.select(
            isCompleted: true,
            dateStart: dateStart,
            dateEnd: dateEnd,
            documentNo: documentNo);
      } else if (_bottomNavigationBarIndex == 2) {
        projects = await ProjectService.selectInProcess(
            dateStart: dateStart, dateEnd: dateEnd, documentNo: documentNo);
      }
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> updateShowConditions(Project _project) async {
    isProcessing = true;
    showFinishProjectButton = false;
    showSignatures = false;
    notifyListeners();
    try {
      final _projectTask = await ProjectTaskService.select(
          projectId: _project.id, isReturn: false);
      int total = _projectTask.length;
      int complete = _projectTask.where((element) => element.isComplete).length;
      if (_project.endDate == null && total == complete) {
        showFinishProjectButton = true;
      }

      if (_project.endDate != null && total == complete) {
        showSignatures = true;
      }
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<Project> finishProject(
      {required Project project,
      required String signatureClientImgDir,
      required String signatureClientName,
      required String signatureClientCifNif,
      required String signatureTechImgDir,
      required String signatureTechName,
      required String signatureTechCifNif,
      required int bottomNavigationBarIndex}) async {
    isProcessing = true;
    notifyListeners();
    try {
      project.signatureClientImgDir = signatureClientImgDir;
      project.signatureClientName = signatureClientName;
      project.signatureClientCifNif = signatureClientCifNif;
      project.signatureTechImgDir = signatureTechImgDir;
      project.signatureTechName = signatureTechName;
      project.signatureTechCifNif = signatureTechCifNif;
      project.endDate = DateTime.now();
      project.syncUp.isRequired = true;
      project.geolocation = '$LOCATION_API_URL/map/?order_id=${project.id}';
      await ProjectService.update(project);

      if (bottomNavigationBarIndex == 0) {
        projects = await ProjectService.select(
            isCompleted: false,
            dateStart: dateStart,
            dateEnd: dateEnd,
            documentNo: documentNo);
      } else if (bottomNavigationBarIndex == 1) {
        projects = await ProjectService.select(
            isCompleted: true,
            dateStart: dateStart,
            dateEnd: dateEnd,
            documentNo: documentNo);
      } else if (bottomNavigationBarIndex == 2) {
        projects = await ProjectService.selectInProcess(
            dateStart: dateStart, dateEnd: dateEnd, documentNo: documentNo);
      }

      await updateShowConditions(project);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
    return project;
  }

  Future<Project> update(Project project) async {
    isProcessing = true;
    notifyListeners();
    try {
      project.syncUp.isRequired = true;
      await ProjectService.update(project);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
    return project;
  }

  Future<void> setFilters(
      {required int bottomNavigationBarIndex,
      String? dateStart,
      String? dateEnd,
      String? documentNo}) async {
    isProcessing = true;
    notifyListeners();
    try {
      this.dateStart = dateStart;
      this.dateEnd = dateEnd;
      this.documentNo = documentNo;
      await getProjects(bottomNavigationBarIndex);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<Project> updateKmSummary({required Project project}) async {
    isProcessing = true;
    notifyListeners();
    try {
      List<Location> _locations =
          await LocationService.selectPulsesByProject(projectId: project.id);
      project.kmSummary = Utils.getKmSummary(locations: _locations);
      project.syncUp.isRequired = true;
      project.geolocation = '$LOCATION_API_URL/map/?order_id=${project.id}';
      await ProjectService.update(project);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
    return project;
  }
}
