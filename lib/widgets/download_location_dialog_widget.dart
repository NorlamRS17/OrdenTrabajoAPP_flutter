import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workorders/controllers/synchronization_controller.dart';

class DownloadLocationDialogWidget extends StatefulWidget {
  const DownloadLocationDialogWidget({Key? key}) : super(key: key);

  @override
  State<DownloadLocationDialogWidget> createState() =>
      _DownloadLocationDialogWidgetState();
}

class _DownloadLocationDialogWidgetState
    extends State<DownloadLocationDialogWidget> {
  late SynchronizationController _c;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateStart;
  late TextEditingController _dateEnd;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _c.dateStart = null;
      _c.dateEnd = null;
      setState(() {});
    });

    _dateStart = TextEditingController();
    _dateStart.text = DateTime.now().toString().substring(0, 10);
    _dateEnd = TextEditingController();
    _dateEnd.text = DateTime.now().toString().substring(0, 10);

    super.initState();
  }

  @override
  void dispose() {
    _dateStart.dispose();
    _dateEnd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<SynchronizationController>();

    Widget cancelButton = TextButton(
      child: const Text("Cancelar"),
      onPressed: () => Navigator.pop(context, false),
    );

    Widget continueButton = TextButton(
      child: const Text("Aceptar"),
      onPressed: () async {
        _c.setFilters(
          dateStart: _dateStart.text,
          dateEnd: _dateEnd.text,
        );
        Navigator.pop(context, true);
      },
    );

    return AlertDialog(
      title: const Text('Confirmación'),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(children: [
          Padding(
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
          ),
          Padding(
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
          ),
          const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                  '¿Desea sincronizar su la información en este momento?')),
        ]),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            cancelButton,
            continueButton,
          ],
        )
      ],
    );
  }
}
