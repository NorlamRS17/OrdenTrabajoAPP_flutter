import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workorders/controllers/expense_line_controller.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/pages/expense_line_page.dart';
import 'package:workorders/widgets/no_data_widget.dart';

// ignore: must_be_immutable
class ExpensePage extends StatefulWidget {
  ExpensePage({Key? key, required this.project}) : super(key: key);

  Project project;

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late ExpenseLineController _c;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _c.getExpenseLines(widget.project.id);
    });
    super.initState();
  }

  @override
  void dispose() {
    _c.expenseLines = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<ExpenseLineController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(widget.project.documentNo),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.project.name),
                Text(widget.project.createdFormat),
                const Divider(),
                Text('Cliente: ${widget.project.businessPartner}'),
              ],
            ),
          ),
          Consumer<ExpenseLineController>(
            builder: (context, ctl, child) {
              return Expanded(
                flex: 1,
                child: ctl.expenseLines.length > 0
                    ? SingleChildScrollView(
                        child: Column(
                          children: List.generate(
                            ctl.expenseLines.length,
                            (index) {
                              final _expenseLine = ctl.expenseLines[index];
                              return Card(
                                child: ListTile(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ExpenseLinePage(
                                                project: widget.project,
                                                expenseLine: _expenseLine,
                                              ))),
                                  title: Text('Datos de la Factura'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Núm: ${_expenseLine.invoiceNo}'),
                                      Text('RUC: ${_expenseLine.ruc}'),
                                      Text('Nombre: ${_expenseLine.name}'),
                                      Text(
                                          'Fecha: ${_expenseLine.date.toString().substring(0, 10)}'),
                                      Text(
                                          'Monto: ${_expenseLine.expenseAmount}'),
                                      Text(_expenseLine.product),
                                      Text('Ciudad: ${_expenseLine.city}'),
                                      Text(
                                        'Descripción: ${_expenseLine.description ?? ''}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                          'Fase: ${_expenseLine.projectPhase}'),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_right),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : NoDataWidget(),
              );
            },
          ),
          Card(
            child: ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExpenseLinePage(
                            project: widget.project,
                            expenseLine: null,
                          ))),
              leading: const Icon(Icons.request_quote, size: 35),
              title: const Text('Agregar factura'),
              trailing: const Icon(Icons.arrow_right),
            ),
          ),
        ],
      ),
    );
  }
}
