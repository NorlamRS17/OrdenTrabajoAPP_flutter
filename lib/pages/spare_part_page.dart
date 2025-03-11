import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workorders/controllers/spare_part_controller.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/project_task.dart';
import 'package:workorders/pages/spare_part_detail_page.dart';
import 'package:workorders/widgets/no_data_widget.dart';

// ignore: must_be_immutable
class SparePartPage extends StatefulWidget {
  SparePartPage({Key? key, required this.project, required this.projectTask})
      : super(key: key);

  Project project;
  ProjectTask projectTask;

  @override
  State<SparePartPage> createState() => _SparePartPageState();
}

class _SparePartPageState extends State<SparePartPage> {
  late SparePartController _c;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _c.getSpareParts(widget.projectTask.id);
    });
    super.initState();
  }

  @override
  void dispose() {
    _c.spareParts = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<SparePartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repuestos Adicionales'),
      ),
      body: Column(
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
          Consumer<SparePartController>(
            builder: (context, ctl, child) {
              return Expanded(
                flex: 1,
                child: ctl.spareParts.length > 0
                    ? SingleChildScrollView(
                        child: Column(
                          children:
                              List.generate(ctl.spareParts.length, (index) {
                            final _sparePart = ctl.spareParts[index];
                            return Card(
                              child: ListTile(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SparePartDetailPage(
                                              project: widget.project,
                                              projectTask: widget.projectTask,
                                              sparePart: _sparePart,
                                            ))),
                                title: Text('Repuesto solicitado'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Código: ${_sparePart.code ?? ''}'),
                                    Text('Cantidad: ${_sparePart.quantity}'),
                                    Text(_sparePart.description ?? ''),
                                    Text('Creado: ${_sparePart.createdFormat}'),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_right),
                              ),
                            );
                          }),
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
                      builder: (context) => SparePartDetailPage(
                            project: widget.project,
                            projectTask: widget.projectTask,
                            sparePart: null,
                          ))),
              leading: const Icon(Icons.settings, size: 35),
              title: const Text('Agregar repuesto'),
              trailing: const Icon(Icons.arrow_right),
            ),
          ),
        ],
      ),
    );
  }
}
