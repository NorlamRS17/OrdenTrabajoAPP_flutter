import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workorders/controllers/project_controller.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/pages/download_locations_page.dart';
import 'package:workorders/pages/expense_page.dart';
import 'package:workorders/pages/finish_project_page.dart';
import 'package:workorders/pages/project_edit_page.dart';
import 'package:workorders/pages/project_task_page.dart';
import 'package:workorders/pages/remark_page.dart';
import 'package:workorders/pages/route_page.dart';
import 'package:workorders/pages/signature_page.dart';
import 'package:workorders/utils/utils.dart';

// ignore: must_be_immutable
class ProjectDetailPage extends StatefulWidget {
  ProjectDetailPage({Key? key, required this.project}) : super(key: key);

  Project project;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late ProjectController _c;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _c.updateShowConditions(widget.project);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<ProjectController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orden de trabajo'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectEditPage(
                    project: widget.project,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
          Builder(
            builder: (context) {
              return Consumer<ProjectController>(
                builder: (context, ctl, child) {
                  return ctl.showFinishProjectButton
                      ? IconButton(
                          onPressed: () async {
                            try {
                              await Utils.checkStoragePermission();
                              bool _result = await Utils.confirmDialog(
                                  context,
                                  'Confirmación',
                                  '¿Desea finalizar la orden de trabajo ${widget.project.documentNo}?');
                              if (_result) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FinishProjectPage(
                                      project: widget.project,
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.draw),
                        )
                      : Container();
                },
              );
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(widget.project.documentNo),
            subtitle: Consumer<ProjectController>(
              builder: (context, ctl, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.project.name),
                  Text(widget.project.createdFormat),
                  const Divider(),
                  Text('Cliente: ${widget.project.businessPartner}'),
                  Text('Telefono: ${widget.project.bPPhone ?? ''}'),
                  Text('Email: ${widget.project.bPEmail ?? ''}'),
                  Text('Direccion: ${widget.project.bPAddress}'),
                  const Divider(),
                  Text('Agente: ${widget.project.salesRep ?? ''}'),
                  Text('Responsable: ${widget.project.personInCharge}'),
                  const Divider(),
                  Text('Maquina: ${widget.project.machine ?? ''}'),
                  Text('Marca: ${widget.project.brand ?? ''}'),
                  Text('Modelo: ${widget.project.model ?? ''}'),
                  Text('Hora/Km: ${widget.project.hourKm ?? ''}'),
                  Text('Serie: ${widget.project.serie ?? ''}'),
                  Text(
                      'Esta operativa: ${widget.project.isOperative ? 'SI' : 'NO'}'),
                  Text('Ubicacion: ${widget.project.location ?? ''}'),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectTaskPage(
                            project: widget.project,
                          ),
                        ),
                      ),
                      leading: const Icon(Icons.assignment, size: 35),
                      title: const Text('Tareas'),
                      trailing: const Icon(Icons.arrow_right),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RemarkPage(
                            project: widget.project,
                          ),
                        ),
                      ),
                      leading: const Icon(Icons.insert_comment, size: 35),
                      title: const Text('Recomendaciones'),
                      trailing: const Icon(Icons.arrow_right),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpensePage(
                            project: widget.project,
                          ),
                        ),
                      ),
                      leading: const Icon(Icons.request_quote, size: 35),
                      title: const Text('Gastos'),
                      trailing: const Icon(Icons.arrow_right),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      onTap: () async {
                        try {
                          await Utils.checkLocationPermission(context);
                          if (widget.project.downLocations) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RoutePage(
                                  project: widget.project,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DownloadLocationsPage(
                                  project: widget.project,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                        }
                      },
                      leading: const Icon(Icons.map, size: 35),
                      title: const Text('Ruta'),
                      trailing: const Icon(Icons.arrow_right),
                    ),
                  ),
                  Consumer<ProjectController>(
                    builder: (context, ctl, child) {
                      return ctl.showSignatures
                          ? Card(
                              child: ListTile(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignaturePage(
                                      project: widget.project,
                                    ),
                                  ),
                                ),
                                leading: const Icon(Icons.edit, size: 35),
                                title: const Text('Firmas'),
                                trailing: const Icon(Icons.arrow_right),
                              ),
                            )
                          : Container();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
