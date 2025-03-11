import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:workorders/controllers/location_controller.dart';
import 'package:workorders/controllers/spare_part_controller.dart';
import 'package:workorders/enums/location_type.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/project_task.dart';
import 'package:workorders/models/spare_part.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/widgets/loader_widget.dart';

// ignore: must_be_immutable
class SparePartDetailPage extends StatefulWidget {
  SparePartDetailPage(
      {Key? key,
      required this.project,
      required this.projectTask,
      required this.sparePart})
      : super(key: key);

  Project project;
  ProjectTask projectTask;
  SparePart? sparePart;

  @override
  State<SparePartDetailPage> createState() => _SparePartDetailPageState();
}

class _SparePartDetailPageState extends State<SparePartDetailPage> {
  late SparePartController _c;
  late LocationController _cLocation;

  late TextEditingController _code;
  late TextEditingController _description;
  late TextEditingController _quantity;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {});

    _code = TextEditingController();
    _code.text = widget.sparePart?.code ?? '';
    _description = TextEditingController();
    _description.text = widget.sparePart?.description ?? '';
    _quantity = TextEditingController();
    _quantity.text = widget.sparePart?.quantity.toString() ?? '';

    super.initState();
  }

  @override
  void dispose() {
    _code.dispose();
    _description.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<SparePartController>();
    _cLocation = context.read<LocationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar repuesto'),
        actions: [
          Builder(builder: (context) {
            return IconButton(
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

                    SparePart? _sparePart;
                    if (widget.sparePart == null) {
                      _sparePart = await _c.insert(
                        widget.project,
                        widget.projectTask.id,
                        _code.text,
                        _description.text,
                        _quantity.text,
                      );
                      await _cLocation.registerActionLocation(
                        locationType: LocationType.AddSparePartRequest,
                        project: widget.project,
                        projectPhaseId: widget.projectTask.projectPhaseId,
                        projectTask: widget.projectTask,
                      );
                    } else {
                      _sparePart = await _c.update(
                        widget.sparePart!,
                        _code.text,
                        _description.text,
                        _quantity.text,
                      );
                      await _cLocation.registerActionLocation(
                        locationType: LocationType.UpdateSparePartRequest,
                        project: widget.project,
                        projectPhaseId: widget.projectTask.projectPhaseId,
                        projectTask: widget.projectTask,
                      );
                    }

                    Navigator.pop(context);
                    setState(() {
                      widget.sparePart = _sparePart;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Guardado con éxito'),
                      ),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    print(e);
                    print(e);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.save_as),
            );
          })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(widget.project.documentNo),
            ),
            ListTile(
              title: const Text('Estado'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fase: ${widget.projectTask.projectPhase}'),
                  Text('Tarea: ${widget.projectTask.name}'),
                ],
              ),
            ),
            const Divider(),
            const ListTile(
              title: Text('* Repuesto solicitado'),
            ),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _code,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Código',
                            hintText: 'Ingrese un código'),
                        maxLength: 100,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Este campo es obligatorio';
                        //   }
                        //   if (value.length > 100) {
                        //     return 'Longitud del campo excedida';
                        //   }
                        //   return null;
                        // },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _description,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Descripción',
                            hintText: 'Ingrese una descripción'),
                        maxLength: 1000,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.length > 1000) {
                            return 'Longitud del campo excedida';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _quantity,
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
                            labelText: 'Cantidad',
                            hintText: 'Ingrese una cantidad'),
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
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
