import 'package:flutter/material.dart';
import 'package:workorders/models/project_phase.dart';
import 'package:workorders/services/project_phase_service.dart';

class ProjectPhaseController extends ChangeNotifier {
  late bool isProcessing;
  late List<ProjectPhase> projectPhases;

  ProjectPhaseController() {
    isProcessing = false;
    projectPhases = [];
  }

  Future<void> getProjectPhases(String _projectId) async {
    isProcessing = true;
    notifyListeners();
    try {
      projectPhases =
          await ProjectPhaseService.selectByProject(projectId: _projectId);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
