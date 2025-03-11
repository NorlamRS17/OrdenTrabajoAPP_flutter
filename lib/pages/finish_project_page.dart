import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import 'package:workorders/controllers/home_controller.dart';
import 'package:workorders/controllers/location_controller.dart';
import 'package:workorders/controllers/project_controller.dart';
import 'package:workorders/enums/location_type.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/utils.dart';
import 'package:workorders/widgets/loader_widget.dart';

// ignore: must_be_immutable
class FinishProjectPage extends StatefulWidget {
  FinishProjectPage({Key? key, required this.project}) : super(key: key);

  Project project;

  @override
  State<FinishProjectPage> createState() => _FinishProjectPageState();
}

class _FinishProjectPageState extends State<FinishProjectPage> {
  late ProjectController _c;
  late HomeController _cHome;
  late LocationController _cLocation;

  late TextEditingController _clientName;
  late TextEditingController _clientRUC;
  late TextEditingController _techName;
  late TextEditingController _techRUC;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {});
    _clientName = TextEditingController();
    _clientRUC = TextEditingController();
    _techName = TextEditingController();
    _techRUC = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _clientName.dispose();
    _clientRUC.dispose();
    _techName.dispose();
    _techRUC.dispose();
    super.dispose();
  }

  Future<String> saveSignature(
      BuildContext _context,
      GlobalKey<SfSignaturePadState> _signature,
      Directory _storage,
      String _type) async {
    String _path = '${_storage.path}/signature_$_type.png';
    List<Path> paths = _signature.currentState!.toPathList();
    if (paths.isEmpty) {
      throw CustomException('Las firmas son obligatorias');
    }

    ui.Image _image = await _signature.currentState!.toImage();
    final _pngBytes =
        (await _image.toByteData(format: ui.ImageByteFormat.png))!;
    final buffer = _pngBytes.buffer;
    File(_path).writeAsBytes(
        buffer.asUint8List(_pngBytes.offsetInBytes, _pngBytes.lengthInBytes));

    return _path;
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<ProjectController>();
    _cHome = context.read<HomeController>();
    _cLocation = context.read<LocationController>();

    GlobalKey<SfSignaturePadState> _signatureClient = GlobalKey();
    GlobalKey<SfSignaturePadState> _signatureTech = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Firma'),
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

                    final _storage = await Utils.createPictureDirectory(
                        'signatures/${widget.project.id}');

                    String _pathClient = await saveSignature(
                        context, _signatureClient, _storage, 'client');
                    String _pathTech = await saveSignature(
                        context, _signatureTech, _storage, 'tech');

                    Project _project = await _c.finishProject(
                        project: widget.project,
                        signatureClientImgDir: _pathClient,
                        signatureClientName: _clientName.text,
                        signatureClientCifNif: _clientRUC.text,
                        signatureTechImgDir: _pathTech,
                        signatureTechName: _techName.text,
                        signatureTechCifNif: _techRUC.text,
                        bottomNavigationBarIndex: _cHome.index);
                    await _cLocation.registerActionLocation(
                        locationType: LocationType.FinalizeWorkOrder,
                        project: widget.project);

                    Navigator.pop(context);
                    setState(() {
                      widget.project = _project;
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
        child: Form(
          key: _formKey,
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          flex: 4,
                          child: ListTile(
                            title: Text('Cliente'),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextButton(
                            onPressed: () {
                              _signatureClient.currentState!.clear();
                            },
                            child: const Text('Borrar'),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: SfSignaturePad(
                        key: _signatureClient,
                        minimumStrokeWidth: 3,
                        maximumStrokeWidth: 5,
                        strokeColor: Colors.black,
                        // backgroundColor: Colors.white,
                      ),
                      height: 250,
                      color: Colors.white,
                      width: double.infinity,
                    ),
                    const Divider(),
                    const Text('Firmar sobre la línea'),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _clientName,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nombre del cliente',
                            hintText: 'Ingrese el nombre del cliente'),
                        maxLength: 500,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.length > 500) {
                            return 'Longitud del campo excedida';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _clientRUC,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(REGEX_INTEGER)),
                        ],
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Cédula del cliente',
                            hintText: 'Ingrese la cédula del cliente'),
                        maxLength: 25,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.length > 25) {
                            return 'Longitud del campo excedida';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          flex: 4,
                          child: ListTile(
                            title: Text('Técnico'),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextButton(
                            onPressed: () {
                              _signatureTech.currentState!.clear();
                            },
                            child: const Text('Borrar'),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: SfSignaturePad(
                        key: _signatureTech,
                        minimumStrokeWidth: 3,
                        maximumStrokeWidth: 5,
                        strokeColor: Colors.black,
                        // backgroundColor: Colors.white,
                      ),
                      height: 250,
                      color: Colors.white,
                      width: double.infinity,
                    ),
                    const Divider(),
                    const Text('Firmar sobre la línea'),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _techName,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nombre del técnico',
                            hintText: 'Ingrese el nombre del técnico'),
                        maxLength: 500,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.length > 500) {
                            return 'Longitud del campo excedida';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _techRUC,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(REGEX_INTEGER)),
                        ],
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Cédula del técnico',
                            hintText: 'Ingrese la cédula del técnico'),
                        maxLength: 25,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
