import 'package:flutter/material.dart';
import 'package:workorders/models/expense.dart';
import 'package:workorders/models/expense_line.dart';
import 'package:workorders/models/product.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/project_phase.dart';
import 'package:workorders/models/sync_up.dart';
import 'package:workorders/services/expense_line_service.dart';
import 'package:workorders/services/expense_service.dart';
import 'package:workorders/utils/utils.dart';

class ExpenseLineController extends ChangeNotifier {
  late bool isProcessing;
  late List<ExpenseLine> expenseLines;

  ExpenseLineController() {
    isProcessing = false;
    expenseLines = [];
  }

  Future<void> getExpenseLines(String _projectId) async {
    isProcessing = true;
    notifyListeners();
    try {
      expenseLines =
          await ExpenseLineService.selectByProject(projectId: _projectId);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<ExpenseLine?> insert(
      Project _project,
      String _invoiceNo,
      String _ruc,
      String _name,
      String _date,
      String _expenseAmount,
      Product _product,
      String _city,
      String _description,
      ProjectPhase _projectPhase) async {
    ExpenseLine? _expenseLine;
    isProcessing = true;
    notifyListeners();
    try {
      List<Expense> _expenses =
          await ExpenseService.selectByProject(projectId: _project.id);
      Expense _expense;
      if (_expenses.isEmpty) {
        _expense = Expense(
            clientId: _project.clientId,
            client: _project.client,
            organizationId: _project.organizationId,
            organization: _project.organization,
            projectId: _project.id,
            documentNo: _project.documentNo,
            syncUp: SyncUp(isRequired: true));

        _expense = await ExpenseService.insert(_expense);
      } else {
        _expense = _expenses[0];
      }

      _expenseLine = ExpenseLine(
          expenseId: (_expense.id ?? _expense.phoneId)!,
          clientId: _project.clientId,
          client: _project.client,
          organizationId: _project.organizationId,
          organization: _project.organization,
          projectId: _project.id,
          projectPhaseId: _projectPhase.id,
          projectPhase: _projectPhase.name,
          invoiceNo: _invoiceNo,
          ruc: _ruc,
          name: _name,
          date: Utils.getDate(_date),
          expenseDate: Utils.getDate(_date),
          expenseAmount: Utils.getDouble(_expenseAmount),
          convertedAmount: Utils.getDouble(_expenseAmount),
          invoicePrice: Utils.getDouble(_expenseAmount),
          productId: _product.id,
          product: _product.name,
          city: _city,
          description: _description,
          uOMId: _product.uOMId,
          currencyId: _project.currencyId,
          syncUp: SyncUp(isRequired: true));

      _expenseLine = await ExpenseLineService.insert(_expenseLine);

      expenseLines = await ExpenseLineService.selectByProject(
        projectId: _project.id,
      );
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
    return _expenseLine;
  }

  Future<ExpenseLine?> update(
      ExpenseLine _expenseLine,
      String _invoiceNo,
      String _ruc,
      String _name,
      String _date,
      String _expenseAmount,
      Product _product,
      String _city,
      String _description,
      ProjectPhase _projectPhase) async {
    isProcessing = true;
    notifyListeners();
    try {
      _expenseLine.invoiceNo = _invoiceNo;
      _expenseLine.ruc = _ruc;
      _expenseLine.name = _name;
      _expenseLine.date = Utils.getDate(_date);
      _expenseLine.expenseDate = Utils.getDate(_date);
      _expenseLine.expenseAmount = Utils.getDouble(_expenseAmount);
      _expenseLine.convertedAmount = Utils.getDouble(_expenseAmount);
      _expenseLine.invoicePrice = Utils.getDouble(_expenseAmount);
      _expenseLine.productId = _product.id;
      _expenseLine.product = _product.name;
      _expenseLine.city = _city;
      _expenseLine.description = _description;
      _expenseLine.projectPhaseId = _projectPhase.id;
      _expenseLine.projectPhase = _projectPhase.name;
      _expenseLine.uOMId = _product.uOMId;
      _expenseLine.syncUp.isRequired = true;

      await ExpenseLineService.update(_expenseLine);
      expenseLines = await ExpenseLineService.selectByProject(
        projectId: _expenseLine.projectId,
      );
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
    return _expenseLine;
  }
}
