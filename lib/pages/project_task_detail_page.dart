import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workorders/controllers/activity_report_controller.dart';
import 'package:workorders/controllers/home_controller.dart';
import 'package:workorders/controllers/location_controller.dart';
import 'package:workorders/controllers/project_controller.dart';
import 'package:workorders/controllers/project_task_controller.dart';
import 'package:workorders/enums/location_type.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/project_task.dart';
import 'package:workorders/pages/activity_report_page.dart';
import 'package:workorders/pages/spare_part_page.dart';
import 'package:workorders/widgets/no_data_widget.dart';
import 'package:workorders/widgets/project_task_widget.dart';

// ignore: must_be_immutable
class ProjectTaskDetailPage extends StatefulWidget {
  ProjectTaskDetailPage(
      {Key? key, required this.project, required this.projectTask})
      : super(key: key);

  Project project;
  ProjectTask projectTask;

  @override
  State<ProjectTaskDetailPage> createState() => _ProjectTaskDetailPageState();
}

class _ProjectTaskDetailPageState extends State<ProjectTaskDetailPage> {
  late ActivityReportController _c;
  late ProjectTaskController _cProjectTask;
  late ProjectController _cProject;
  late HomeController _cHome;
  late LocationController _cLocation;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _c.getActivityReports(widget.projectTask.id);
    });
    super.initState();
  }

  @override
  void dispose() {
    _c.activityReports = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<ActivityReportController>();
    _cProjectTask = context.read<ProjectTaskController>();
    _cProject = context.read<ProjectController>();
    _cHome = context.read<HomeController>();
    _cLocation = context.read<LocationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarea'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(widget.project.documentNo),
          ),
          Consumer<ProjectTaskController>(builder: (context, ctl, child) {
            return ProjectTaskWidget(
              project: widget.project,
              projectTask: widget.projectTask,
              callBack: (LocationType? locationType) async {
                try {
                  widget.projectTask = await ctl.updateProjectTask(
                    widget.project.id,
                    widget.projectTask,
                  );
                  await _cLocation.registerActionLocation(
                    locationType: locationType!,
                    project: widget.project,
                    projectPhaseId: widget.projectTask.projectPhaseId,
                    projectTask: widget.projectTask,
                  );
                  setState(() {});
                  await _cProject.updateShowConditions(widget.project);
                  if (widget.projectTask.status == 'Tarea Finalizada' &&
                      widget.projectTask.isReturn) {
                    await _cProject.updateKmSummary(project: widget.project);
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
              isTappable: false,
              cProjectTask: _cProjectTask,
            );
          }),
          Expanded(
            child: Consumer<ActivityReportController>(
                builder: (context, ctl, child) {
              return ctl.activityReports.length > 0
                  ? ListView.builder(
                      itemCount: ctl.activityReports.length,
                      itemBuilder: (context, index) {
                        final _activityReport = ctl.activityReports[index];
                        return Card(
                            child: ListTile(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ActivityReportPage(
                                              project: widget.project,
                                              projectTask: widget.projectTask,
                                              activityReport: _activityReport,
                                            ))),
                                title: Text('Informe de actividad'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Creado: ${_activityReport.created}'),
                                    Text(
                                      _activityReport.report,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_right)));
                      },
                    )
                  : NoDataWidget();
            }),
          ),
          widget.projectTask.status == 'En proceso' ||
                  widget.projectTask.status == 'En pausa'
              ? Card(
                  child: ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityReportPage(
                          project: widget.project,
                          projectTask: widget.projectTask,
                          activityReport: null,
                        ),
                      ),
                    ),
                    leading: const Icon(Icons.description, size: 35),
                    title: const Text('Agregar informe de actividad'),
                    trailing: const Icon(Icons.arrow_right),
                  ),
                )
              : Container(),
          Card(
            child: ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SparePartPage(
                    project: widget.project,
                    projectTask: widget.projectTask,
                  ),
                ),
              ),
              leading: const Icon(Icons.settings, size: 35),
              title: const Text('Repuestos adicionales'),
              trailing: const Icon(Icons.arrow_right),
            ),
          ),
        ],
      ),
    );
  }
}
