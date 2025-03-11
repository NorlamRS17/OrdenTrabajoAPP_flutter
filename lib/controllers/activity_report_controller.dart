import 'package:flutter/material.dart';
import 'package:workorders/models/activity_report.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/services/activity_report_service.dart';

class ActivityReportController extends ChangeNotifier {
  late bool isProcessing;
  late List<ActivityReport> activityReports;

  ActivityReportController() {
    isProcessing = false;
    activityReports = [];
  }

  Future<void> getActivityReports(String _projectTaskId) async {
    isProcessing = true;
    notifyListeners();
    try {
      activityReports = await ActivityReportService.selectByProjectTask(
          projectTaskId: _projectTaskId);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<ActivityReport?> insert(
      Project project, String _projectTaskId, String _report) async {
    ActivityReport? _activityReport;
    isProcessing = true;
    notifyListeners();
    try {
      _activityReport = ActivityReport(
          clientId: project.clientId,
          client: project.client,
          organizationId: project.organizationId,
          organization: project.organization,
          projectTaskId: _projectTaskId,
          report: _report,
          syncUp: SyncUp(isRequired: true));

      _activityReport = await ActivityReportService.insert(_activityReport);
      activityReports = await ActivityReportService.selectByProjectTask(
          projectTaskId: _projectTaskId);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
    return _activityReport;
  }

  Future<ActivityReport?> update(
      ActivityReport _activityReport, String _report) async {
    isProcessing = true;
    notifyListeners();
    try {
      _activityReport.report = _report;
      _activityReport.syncUp.isRequired = true;
      await ActivityReportService.update(_activityReport);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
    return _activityReport;
  }
}
