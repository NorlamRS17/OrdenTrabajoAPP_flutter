import 'package:flutter/material.dart';
import 'package:workorders/models/picture.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/services/picture_service.dart';

class PictureController extends ChangeNotifier {
  late bool isProcessing;
  late List<Picture> pictures;

  PictureController() {
    isProcessing = false;
    pictures = [];
  }

  Future<void> getPictures(String _activityReportId) async {
    isProcessing = true;
    notifyListeners();
    try {
      pictures = await PictureService.selectByActivityReport(
          activityReportId: _activityReportId);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<Picture?> insert(
      Project project, String _activityReportId, String _imgDir) async {
    Picture? _picture;
    isProcessing = true;
    notifyListeners();
    try {
      _picture = Picture(
          clientId: project.clientId,
          client: project.client,
          organizationId: project.organizationId,
          organization: project.organization,
          activityReportId: _activityReportId,
          imgDir: _imgDir,
          syncUp: SyncUp(isRequired: true));
      _picture = await PictureService.insert(_picture);
      getPictures(_activityReportId);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
    return _picture;
  }
}
