import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workorders/controllers/home_controller.dart';
import 'package:workorders/controllers/project_controller.dart';

// ignore: must_be_immutable
class ProjectFilterWidget extends StatefulWidget {
  ProjectFilterWidget({Key? key, required this.index}) : super(key: key);

  int index;

  @override
  State<ProjectFilterWidget> createState() => _ProjectFilterWidgetState();
}

class _ProjectFilterWidgetState extends State<ProjectFilterWidget> {
  late ProjectController _c;
  late HomeController _cHome;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateStart;
  late TextEditingController _dateEnd;
  late TextEditingController _documentNo;

  bool _showDateStart = false;
  bool _showDateEnd = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (_c.dateStart != null) {
        _showDateStart = true;
        _dateStart.text = _c.dateStart!;
      }
      if (_c.dateEnd != null) {
        _showDateEnd = true;
        _dateEnd.text = _c.dateEnd!;
      }
      _documentNo.text = _c.documentNo ?? '';
      setState(() {});
    });

    _dateStart = TextEditingController();
    _dateStart.text = DateTime.now().toString().substring(0, 10);
    _dateEnd = TextEditingController();
    _dateEnd.text = DateTime.now().toString().substring(0, 10);
    _documentNo = TextEditingController();
    _documentNo.text = '';

    super.initState();
  }

  @override
  void dispose() {
    _dateStart.dispose();
    _dateEnd.dispose();
    _documentNo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<ProjectController>();
    _cHome = context.read<HomeController>();

    Widget cleanButton = TextButton(
      child: const Text("Limpiar"),
      onPressed: () async {
        _c.setFilters(
            bottomNavigationBarIndex: _cHome.index,
            dateStart: null,
            dateEnd: null,
            documentNo: null);
        Navigator.pop(context, true);
      },
    );

    Widget cancelButton = TextButton(
      child: const Text("Cancelar"),
      onPressed: () => Navigator.pop(context, false),
    );

    Widget continueButton = TextButton(
      child: const Text("Aceptar"),
      onPressed: () async {
        _c.setFilters(
            bottomNavigationBarIndex: _cHome.index,
            dateStart: _showDateStart ? _dateStart.text : null,
            dateEnd: _showDateEnd ? _dateEnd.text : null,
            documentNo: _documentNo.text.replaceAll(' ', ''));
        Navigator.pop(context, true);
      },
    );

    return AlertDialog(
      title: const Text('Filtrar Ordenes de Trabajo'),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(children: [
          Row(
            children: [
              Switch(
                value: _showDateStart,
                onChanged: (value) {
                  setState(
                    () {
                      _showDateStart = !_showDateStart;
                    },
                  );
                },
              ),
              const Text('Fecha desde'),
            ],
          ),
          _showDateStart
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _dateStart,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
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
                        initialDate: DateTime.parse(_dateStart.text),
                        firstDate: DateTime(_now.year - 5),
                        lastDate: _now,
                        initialEntryMode: DatePickerEntryMode.calendar,
                      );
                      if (_datePick != null) {
                        _dateStart.text = _datePick.toString().substring(0, 10);
                      }
                    },
                  ),
                )
              : Container(),
          Row(
            children: [
              Switch(
                value: _showDateEnd,
                onChanged: (value) {
                  setState(
                    () {
                      _showDateEnd = !_showDateEnd;
                    },
                  );
                },
              ),
              const Text('Fecha hasta'),
            ],
          ),
          _showDateEnd
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _dateEnd,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
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
                        initialDate: DateTime.parse(_dateEnd.text),
                        firstDate: DateTime(_now.year - 5),
                        lastDate: _now,
                        initialEntryMode: DatePickerEntryMode.calendar,
                      );
                      if (_datePick != null) {
                        _dateEnd.text = _datePick.toString().substring(0, 10);
                      }
                    },
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: _documentNo,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Número de orden de trabajo',
                  hintText: 'Ingrese el número de orden de trabajo'),
              validator: (value) {
                // if (value == null || value.isEmpty) {
                //   return 'Este campo es obligatorio';
                // }
                return null;
              },
            ),
          ),
        ]),
      ),
      actions: [
        Row(
          children: [
            Expanded(child: cleanButton),
            cancelButton,
            continueButton,
          ],
        )
      ],
    );
  }
}
