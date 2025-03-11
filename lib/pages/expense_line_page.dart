import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:workorders/controllers/expense_line_controller.dart';
import 'package:workorders/controllers/location_controller.dart';
import 'package:workorders/controllers/product_controller.dart';
import 'package:workorders/controllers/project_phase_controller.dart';
import 'package:workorders/enums/location_type.dart';
import 'package:workorders/models/expense_line.dart';
import 'package:workorders/models/product.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/project_phase.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/widgets/loader_widget.dart';

// ignore: must_be_immutable
class ExpenseLinePage extends StatefulWidget {
  ExpenseLinePage({Key? key, required this.project, required this.expenseLine})
      : super(key: key);

  Project project;
  ExpenseLine? expenseLine;

  @override
  State<ExpenseLinePage> createState() => _ExpenseLinePageState();
}

class _ExpenseLinePageState extends State<ExpenseLinePage> {
  late ExpenseLineController _c;
  late ProductController _cProduct;
  late ProjectPhaseController _cProjectPhase;
  late LocationController _cLocation;

  late TextEditingController _invoiceNo;
  late TextEditingController _ruc;
  late TextEditingController _name;
  late TextEditingController _date;
  late TextEditingController _expenseAmount;
  late String _productId;
  late TextEditingController _city;
  late TextEditingController _description;
  late String _projectPhaseId;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _cProduct.getProducts();
      _cProjectPhase.getProjectPhases(widget.project.id);
    });
    _invoiceNo = TextEditingController();
    _ruc = TextEditingController();
    _name = TextEditingController();
    _date = TextEditingController();
    _date.text = DateTime.now().toString().substring(0, 10);
    _expenseAmount = TextEditingController();
    _city = TextEditingController();
    _description = TextEditingController();

    _invoiceNo.text = widget.expenseLine?.invoiceNo ?? '';
    _ruc.text = widget.expenseLine?.ruc ?? '';
    _name.text = widget.expenseLine?.name ?? '';
    _expenseAmount.text = widget.expenseLine?.expenseAmount.toString() ?? '';
    _productId = widget.expenseLine?.productId ?? '';
    _city.text = widget.expenseLine?.city ?? '';
    _description.text = widget.expenseLine?.description ?? '';
    _projectPhaseId = widget.expenseLine?.projectPhaseId ?? '';

    super.initState();
  }

  @override
  void dispose() {
    _invoiceNo.dispose();
    _ruc.dispose();
    _name.dispose();
    _date.dispose();
    _expenseAmount.dispose();
    _city.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<ExpenseLineController>();
    _cProduct = context.read<ProductController>();
    _cProjectPhase = context.read<ProjectPhaseController>();
    _cLocation = context.read<LocationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
        actions: [
          IconButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (context) {
                        return LoaderWidget();
                      },
                      isDismissible: false,
                    );

                    ExpenseLine? _expenseLine;
                    final _product = _cProduct.products
                        .where((element) => element.id == _productId)
                        .toList()[0];
                    final _projectPhase = _cProjectPhase.projectPhases
                        .where((element) => element.id == _projectPhaseId)
                        .toList()[0];
                    if (widget.expenseLine == null) {
                      _expenseLine = await _c.insert(
                          widget.project,
                          _invoiceNo.text,
                          _ruc.text,
                          _name.text,
                          _date.text,
                          _expenseAmount.text,
                          _product,
                          _city.text,
                          _description.text,
                          _projectPhase);
                      await _cLocation.registerActionLocation(
                          locationType: LocationType.AddExpense,
                          project: widget.project);
                    } else {
                      _expenseLine = await _c.update(
                          widget.expenseLine!,
                          _invoiceNo.text,
                          _ruc.text,
                          _name.text,
                          _date.text,
                          _expenseAmount.text,
                          _product,
                          _city.text,
                          _description.text,
                          _projectPhase);
                      await _cLocation.registerActionLocation(
                          locationType: LocationType.UpdateExpense,
                          project: widget.project);
                    }

                    Navigator.pop(context);

                    setState(() {
                      widget.expenseLine = _expenseLine;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Guardado con éxito'),
                      ),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.save_as)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
            Card(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const ListTile(
                      title: Text('Datos de la Factura'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _invoiceNo,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Número de factura',
                            hintText: 'Ingrese el número de factura'),
                        maxLength: 100,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.length > 100) {
                            return 'Longitud del campo excedida';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _ruc,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(REGEX_INTEGER)),
                        ],
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'RUC',
                            hintText: 'Ingrese el RUC'),
                        maxLength: 20,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.length > 20) {
                            return 'Longitud del campo excedida';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nombre',
                            hintText: 'Ingrese la razón social de la factura'),
                        maxLength: 100,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.length > 100) {
                            return 'Longitud del campo excedida';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _date,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Fecha',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        },
                        onTap: () async {
                          DateTime _now = DateTime.now();
                          DateTime? _datePick = await showDatePicker(
                            context: context,
                            initialDate: DateTime.parse(_date.text),
                            firstDate: DateTime(_now.year - 1),
                            lastDate: _now,
                            initialEntryMode: DatePickerEntryMode.calendar,
                          );
                          if (_datePick != null) {
                            _date.text = _datePick.toString().substring(0, 10);
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _expenseAmount,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(REGEX_DECIMAL),
                          ),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            try {
                              final text = newValue.text;
                              if (text.isNotEmpty) double.parse(text);
                              return newValue;
                            } catch (e) {}
                            return oldValue;
                          }),
                        ],
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Monto',
                            hintText: 'Ingrese el monto total de la factura'),
                        maxLength: 12,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.length > 12) {
                            return 'Longitud del campo excedida';
                          }
                          return null;
                        },
                      ),
                    ),
                    Consumer<ProductController>(
                      builder: (context, ctl, child) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownButtonFormField<String>(
                            items: List.generate(ctl.products.length, (index) {
                              Product _product = ctl.products[index];
                              return DropdownMenuItem<String>(
                                value: _product.id,
                                child: Text(_product.name),
                              );
                            }),
                            value: _productId.isEmpty ? null : _productId,
                            onChanged: (value) {
                              _productId = value!;
                            },
                            decoration: InputDecoration(
                              labelText: 'Tipo de gasto',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            hint: const Text('Seleccione un tipo de gasto'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Este campo es obligatorio';
                              }
                              return null;
                            },
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _city,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Ciudad',
                            hintText: 'Ingrese la ciudad'),
                        maxLength: 150,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.length > 150) {
                            return 'Longitud del campo excedida';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _description,
                        minLines: 4,
                        maxLines: 4,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                            labelText: 'Descripción',
                            hintText: 'Ingrese la descripción'),
                        maxLength: 255,
                      ),
                    ),
                    Consumer<ProjectPhaseController>(
                      builder: (context, ctl, child) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownButtonFormField<String>(
                            items: List.generate(ctl.projectPhases.length,
                                (index) {
                              ProjectPhase _projectPhase =
                                  ctl.projectPhases[index];
                              return DropdownMenuItem<String>(
                                value: _projectPhase.id,
                                child: Text(_projectPhase.name),
                              );
                            }),
                            value: _projectPhaseId.isEmpty
                                ? null
                                : _projectPhaseId,
                            onChanged: (value) {
                              _projectPhaseId = value!;
                            },
                            decoration: InputDecoration(
                              labelText: 'Fase',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            hint: const Text('Seleccione la fase'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Este campo es obligatorio';
                              }
                              return null;
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
