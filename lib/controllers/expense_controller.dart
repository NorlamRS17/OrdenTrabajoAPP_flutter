import 'package:flutter/material.dart';
import 'package:workorders/models/expense.dart';
import 'package:workorders/services/expense_service.dart';

class ExpenseController extends ChangeNotifier {
  late bool isProcessing;
  late List<Expense> expenses;

  ExpenseController() {
    isProcessing = false;
    expenses = [];
  }

  Future<void> getExpenses(String _projectId) async {
    isProcessing = true;
    notifyListeners();
    try {
      expenses = await ExpenseService.selectByProject(projectId: _projectId);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
