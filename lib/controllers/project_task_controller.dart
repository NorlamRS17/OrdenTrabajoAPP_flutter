import 'package:flutter/material.dart';
import 'package:workorders/models/project_task.dart';
import 'package:workorders/services/project_task_service.dart';

class ProjectTaskController extends ChangeNotifier {
  late bool isProcessing;
  late List<ProjectTask> projectTasks;

  ProjectTaskController() {
    isProcessing = false;
    projectTasks = [];
  }

  Future<void> getProjectTasks(String _projectId) async {
    isProcessing = true;
    notifyListeners();
    try {
      projectTasks = await ProjectTaskService.select(projectId: _projectId);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<ProjectTask> updateProjectTask(
      String _projectId, ProjectTask _projectTask) async {
    isProcessing = true;
    notifyListeners();
    try {
      final _current = (await ProjectTaskService.select(
          id: _projectTask.id, projectId: _projectId))[0];
      if (_current.status != _projectTask.status) {
        if (_current.status == 'Sin iniciar' && _projectTask.status == 'En proceso') {
          _projectTask.starting = DateTime.now();
        } else if (_projectTask.status == 'Tarea Finalizada') {
          _projectTask.ending = DateTime.now();
          _projectTask.isComplete = true;
        }
      }
      _projectTask.syncUp.isRequired = true;
      await ProjectTaskService.update(_projectTask);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
    return _projectTask;
  }

  Future<List<ProjectTask>> getProjectTasksInProcess(String _projectId) async {
    try {
      List<ProjectTask> _projectTasks = await ProjectTaskService.selectByStatus(
          status: 'En proceso', projectId: _projectId);
      return _projectTasks;
    } catch (e) {
      rethrow;
    }
  }
}
