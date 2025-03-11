import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workorders/controllers/brand_controller.dart';

import 'package:workorders/controllers/model_controller.dart';
import 'package:workorders/controllers/project_controller.dart';
import 'package:workorders/models/brand.dart';
import 'package:workorders/models/model.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/widgets/loader_widget.dart';

// ignore: must_be_immutable
class ProjectEditPage extends StatefulWidget {
  ProjectEditPage({Key? key, required this.project}) : super(key: key);

  Project project;

  @override
  State<ProjectEditPage> createState() => _ProjectEditPageState();
}

class _ProjectEditPageState extends State<ProjectEditPage> {
  late ProjectController _c;
  late BrandController _cBrand;
  late ModelController _cModel;

  late String _brandId = '';
  late String _modelId = '';
  late TextEditingController _hourKm;
  late TextEditingController _serie;
  late TextEditingController _location;
  late bool _isOperative;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _cBrand.getBrands();
      _cModel
          .getModels(widget.project.brandId)
          .then((value) => _modelId = widget.project.modelId ?? '');
    });
    _hourKm = TextEditingController();
    _hourKm.text = widget.project.hourKm ?? '';
    _serie = TextEditingController();
    _serie.text = widget.project.serie ?? '';
    _location = TextEditingController();
    _location.text = widget.project.location ?? '';
    _brandId = widget.project.brandId ?? '';

    _isOperative = widget.project.isOperative;
    super.initState();
  }

  @override
  void dispose() {
    _serie.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<ProjectController>();
    _cBrand = context.read<BrandController>();
    _cModel = context.read<ModelController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orden de trabajo'),
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

                    final _brand = _cBrand.brands
                        .where((element) => element.id == _brandId)
                        .toList()[0];
                    final _model = _cModel.models
                        .where((element) => element.id == _modelId)
                        .toList()[0];

                    Project _project =
                        Project.fromJsonSQLite(widget.project.toMapSQLite());
                    _project.brandId = _brand.id;
                    _project.brand = _brand.name;
                    _project.modelId = _model.id;
                    _project.model = _model.name;
                    _project.hourKm = _hourKm.text;
                    _project.serie = _serie.text;
                    _project.location = _location.text;
                    _project.isOperative = _isOperative;
                    _project = await _c.update(_project);

                    setState(() {
                      widget.project.brandId = _project.brandId;
                      widget.project.brand = _project.brand;
                      widget.project.modelId = _project.modelId;
                      widget.project.model = _project.model;
                      widget.project.hourKm = _project.hourKm;
                      widget.project.serie = _project.serie;
                      widget.project.location = _project.location;
                      widget.project.isOperative = _project.isOperative;
                    });

                    Navigator.pop(context);

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
                      title: Text('Maquinaria'),
                    ),
                    Consumer<BrandController>(
                      builder: (context, ctl, child) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownButtonFormField<String>(
                            items: List.generate(ctl.brands.length, (index) {
                              Brand _brand = ctl.brands[index];
                              return DropdownMenuItem<String>(
                                value: _brand.id,
                                child: Text(_brand.name),
                              );
                            }),
                            value: _brandId.isEmpty ? null : _brandId,
                            onChanged: (value) {
                              setState(() {
                                _modelId = '';
                                _brandId = value!;
                              });
                              _cModel.getModels(_brandId);
                            },
                            decoration: InputDecoration(
                              labelText: 'Marca',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            hint: const Text('Seleccione una marca'),
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
                    Consumer<ModelController>(
                      builder: (context, ctl, child) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownButtonFormField<String>(
                            items: List.generate(ctl.models.length, (index) {
                              Model _model = ctl.models[index];
                              return DropdownMenuItem<String>(
                                value: _model.id,
                                child: Text(_model.name),
                              );
                            }),
                            value: _modelId.isEmpty ? null : _modelId,
                            onChanged: (value) {
                              setState(() {
                                _modelId = value!;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Modelo',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            hint: const Text('Seleccione un model'),
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
                        controller: _hourKm,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Hora/Km',
                            hintText: 'Ingrese la Hora/Km'),
                        maxLength: 32,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.length > 32) {
                            return 'Longitud del campo excedida';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _serie,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Número de serie',
                            hintText: 'Ingrese el número de serie'),
                        maxLength: 100,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.length > 80) {
                            return 'Longitud del campo excedida';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                      child: TextFormField(
                        controller: _location,
                        minLines: 4,
                        maxLines: 4,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                            labelText: 'Localización',
                            hintText: 'Ingrese la localización'),
                        maxLength: 500,
                        validator: (value) {
                          if (value != null && value.length > 500) {
                            return 'Longitud del campo excedida';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Switch(
                            value: _isOperative,
                            onChanged: (value) {
                              setState(
                                () {
                                  _isOperative = !_isOperative;
                                },
                              );
                            },
                          ),
                          const Text('Esta operativa'),
                        ],
                      ),
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
