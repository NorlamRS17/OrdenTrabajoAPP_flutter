import 'package:flutter/material.dart';
import 'package:workorders/controllers/home_controller.dart';
import 'package:workorders/controllers/project_controller.dart';
import 'package:workorders/pages/project_detail_page.dart';
import 'package:workorders/widgets/no_data_widget.dart';
import 'package:workorders/widgets/loading_widget.dart';
import 'package:workorders/widgets/project_filter_widget.dart';
import 'package:provider/provider.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late ProjectController _c;
  late HomeController _cHome;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      loadProjects();
      _cHome.addListener(loadProjects);
    });
    super.initState();
  }

  @override
  void dispose() {
    _cHome.removeListener(loadProjects);
    _c.projects = [];
    super.dispose();
  }

  void loadProjects() {
    _c.getProjects(_cHome.index);
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<ProjectController>();
    _cHome = context.read<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordenes de trabajo'),
        actions: [
          Builder(builder: (context) {
            return IconButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ProjectFilterWidget(index: _cHome.index);
                  },
                );
              },
              icon: const Icon(Icons.filter_list),
            );
          })
        ],
      ),
      body: Consumer<ProjectController>(
        builder: (context, ctl, child) {
          return ctl.isProcessing
              ? const LoadingWidget()
              : ctl.projects.length > 0
                  ? ListView.builder(
                      itemCount: ctl.projects.length,
                      itemBuilder: (context, index) {
                        final _project = ctl.projects[index];
                        return Card(
                          child: ListTile(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProjectDetailPage(
                                          project: _project,
                                        ))),
                            title: Text(_project.documentNo),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_project.name),
                                Text(_project.createdFormat),
                                const Divider(),
                                Text('Cliente: ${_project.businessPartner}'),
                                Text('Direccion: ${_project.bPAddress}'),
                                Text('Ubicacion: ${_project.location ?? ''}'),
                                const Divider(),
                                Text('Responsable: ${_project.personInCharge}'),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_right),
                          ),
                        );
                      },
                    )
                  : NoDataWidget();
        },
      ),
    );
  }
}
