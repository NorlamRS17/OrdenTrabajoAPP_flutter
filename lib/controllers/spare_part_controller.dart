import 'package:flutter/material.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/spare_part.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/services/spare_part_service.dart';
import 'package:workorders/utils/utils.dart';

class SparePartController extends ChangeNotifier {
  late bool isProcessing;
  late List<SparePart> spareParts;

  SparePartController() {
    isProcessing = false;
    spareParts = [];
  }

  Future<void> getSpareParts(String _projectTaskId) async {
    isProcessing = true;
    notifyListeners();
    try {
      spareParts = await SparePartService.selectByProjectTask(
          projectTaskId: _projectTaskId);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<SparePart?> insert(Project project, String _projectTaskId,
      String _code, String _description, String _quantity) async {
    SparePart? _sparePart;
    isProcessing = true;
    notifyListeners();
    try {
      _sparePart = SparePart(
          clientId: project.clientId,
          client: project.client,
          organizationId: project.organizationId,
          organization: project.organization,
          projectTaskId: _projectTaskId,
          code: _code,
          description: _description,
          quantity: Utils.getDouble(_quantity),
          syncUp: SyncUp(isRequired: true));

      _sparePart = await SparePartService.insert(_sparePart);
      spareParts = await SparePartService.selectByProjectTask(
          projectTaskId: _projectTaskId);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
    return _sparePart;
  }

  Future<SparePart?> update(SparePart _sparePart, String _code,
      String _description, String _quantity) async {
    isProcessing = true;
    notifyListeners();
    try {
      _sparePart.code = _code;
      _sparePart.description = _description;
      _sparePart.quantity = Utils.getDouble(_quantity);
      _sparePart.syncUp.isRequired = true;
      await SparePartService.update(_sparePart);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
    return _sparePart;
  }
}
