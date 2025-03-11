import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workorders/controllers/home_controller.dart';
import 'package:workorders/controllers/location_controller.dart';
import 'package:workorders/controllers/project_controller.dart';
import 'package:workorders/controllers/project_task_controller.dart';
import 'package:workorders/enums/location_type.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/project_task.dart';
import 'package:workorders/widgets/project_task_widget.dart';

// ignore: must_be_immutable
class ProjectTaskPage extends StatefulWidget {
  ProjectTaskPage({Key? key, required this.project}) : super(key: key);

  Project project;

  @override
  State<ProjectTaskPage> createState() => _ProjectTaskPageState();
}

class _ProjectTaskPageState extends State<ProjectTaskPage> {
  late ProjectTaskController _c;
  late ProjectController _cProject;
  late HomeController _cHome;
  late LocationController _cLocation;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _c.getProjectTasks(widget.project.id);
    });
    super.initState();
  }

  @override
  void dispose() {
    _c.projectTasks = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<ProjectTaskController>();
    _cProject = context.read<ProjectController>();
    _cHome = context.read<HomeController>();
    _cLocation = context.read<LocationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
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
              child: Consumer<ProjectTaskController>(
                builder: (context, ctl, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      ctl.projectTasks.length,
                      (index) {
                        ProjectTask _projectTask = ctl.projectTasks[index];
                        return Card(
                          child: ProjectTaskWidget(
                            project: widget.project,
                            projectTask: _projectTask,
                            callBack: (LocationType? locationType) async {
                              try {
                                _projectTask = await _c.updateProjectTask(
                                  widget.project.id,
                                  _projectTask,
                                );
                                await _cLocation.registerActionLocation(
                                  locationType: locationType!,
                                  project: widget.project,
                                  projectPhaseId: _projectTask.projectPhaseId,
                                  projectTask: _projectTask,
                                );
                                await _cProject
                                    .updateShowConditions(widget.project);
                                if (_projectTask.status == 'Tarea Finalizada') {
                                  await _cProject.updateKmSummary(
                                      project: widget.project);
                                }
                                if (_cHome.index == 2) {
                                  _cProject.getProjects(_cHome.index);
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                  ),
                                );
                              }
                            },
                            isTappable: true,
                            cProjectTask: _c,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
