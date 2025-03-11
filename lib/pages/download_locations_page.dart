import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workorders/controllers/project_controller.dart';
import 'package:workorders/controllers/synchronization_controller.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/pages/route_page.dart';

// ignore: must_be_immutable
class DownloadLocationsPage extends StatefulWidget {
  DownloadLocationsPage({Key? key, this.project}) : super(key: key);

  Project? project;

  @override
  State<DownloadLocationsPage> createState() => _DownloadLocationsPageState();
}

class _DownloadLocationsPageState extends State<DownloadLocationsPage> {
  late SynchronizationController _c;
  late ProjectController _cProject;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      try {
        await _c.downloadLocations(project: widget.project);
        if (widget.project != null) {
          widget.project?.downLocations = true;
          widget.project =
              await _cProject.updateKmSummary(project: widget.project!);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RoutePage(
                project: widget.project!,
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _c.log = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<SynchronizationController>();
    _cProject = context.read<ProjectController>();

    return Scaffold(
      body: Consumer<SynchronizationController>(
        builder: (context, ctl, child) {
          return WillPopScope(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 150.0,
                  padding: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                  ),
                  child: Image.asset('assets/images/logo.png', width: 250.0),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(5),
                    color: const Color.fromRGBO(0, 0, 0, 0.4),
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Consumer<SynchronizationController>(
                        builder: (context, ctl, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(ctl.log.length,
                                (index) => Text(ctl.log[index])),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                ctl.isProcessing
                    ? const LinearProgressIndicator()
                    : Container(),
              ],
            ),
            onWillPop: () async => !ctl.isProcessing,
          );
        },
      ),
    );
  }
}
