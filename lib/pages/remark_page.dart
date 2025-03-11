import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workorders/controllers/location_controller.dart';
import 'package:workorders/controllers/project_controller.dart';
import 'package:workorders/enums/location_type.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/widgets/loader_widget.dart';

// ignore: must_be_immutable
class RemarkPage extends StatefulWidget {
  RemarkPage({Key? key, required this.project}) : super(key: key);

  Project project;

  @override
  State<RemarkPage> createState() => _RemarkPageState();
}

class _RemarkPageState extends State<RemarkPage> {
  late ProjectController _c;
  late LocationController _cLocation;

  late TextEditingController _remark;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {});

    _remark = TextEditingController();
    _remark.text = widget.project.remark ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _remark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<ProjectController>();
    _cLocation = context.read<LocationController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()async{

            try {
              showModalBottomSheet<void>(
                context: context,
                builder: (context) {
                  return LoaderWidget();
                },
                isDismissible: false,
              );

              Project _project =
              Project.fromJsonSQLite(widget.project.toMapSQLite());
              _project.remark = _remark.text;
              _project = await _c.update(_project);
              if (widget.project.remark == null) {
                await _cLocation.registerActionLocation(
                    locationType: LocationType.AddRemark,
                    project: widget.project);
              }

              Navigator.pop(context);
              Navigator.pop(context);
              setState(() {
                widget.project.remark = _project.remark;
              });

              /*    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Guardado con éxito'),
                      ),
                    );*/
            } catch (e) {
              Navigator.pop(context);
              print(e);
              /*  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );*/
            }


        }, icon: Icon(Icons.arrow_back)),
        title: const Text('Recomendaciones'),
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

                    Project _project =
                        Project.fromJsonSQLite(widget.project.toMapSQLite());
                    _project.remark = _remark.text;
                    _project = await _c.update(_project);
                    if (widget.project.remark == null) {
                      await _cLocation.registerActionLocation(
                          locationType: LocationType.AddRemark,
                          project: widget.project);
                    }

                    Navigator.pop(context);
                    setState(() {
                      widget.project.remark = _project.remark;
                    });
print("object");
print("object");
                /*    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Guardado con éxito'),
                      ),
                    );*/
                  } catch (e) {
                    print("objectobject");
                    Navigator.pop(context);
                    print(e);
                  /*  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );*/
                  }
                }
              },
              icon: const Icon(Icons.save_as),
            );
          })
        ],
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
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      title: Text('* Recomendaciones'),
                    ),
                    widget.project.endDate == null
                        ? Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: TextFormField(
                                controller: _remark,
                                minLines: 6,
                                maxLines: 6,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Ingrese sus recomendaciones'),
                                maxLength: 4000,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Este campo es obligatorio';
                                  }
                                  if (value.length > 4000) {
                                    return 'Longitud del campo excedida';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              widget.project.remark ?? '',
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
