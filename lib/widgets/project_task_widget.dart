import 'package:flutter/material.dart';

import 'package:workorders/controllers/project_task_controller.dart';
import 'package:workorders/enums/location_type.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/project_task.dart';
import 'package:workorders/pages/project_task_detail_page.dart';
import 'package:workorders/utils/utils.dart';

// ignore: must_be_immutable
class ProjectTaskWidget extends StatefulWidget {
  ProjectTaskWidget(
      {Key? key,
      required this.project,
      required this.projectTask,
      required this.callBack,
      required this.isTappable,
      required this.cProjectTask})
      : super(key: key);

  Project project;
  ProjectTask projectTask;
  Function callBack;
  bool isTappable;
  ProjectTaskController cProjectTask;

  @override
  State<ProjectTaskWidget> createState() => _ProjectTaskWidgetState();
}

class _ProjectTaskWidgetState extends State<ProjectTaskWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: widget.isTappable
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectTaskDetailPage(
                    project: widget.project,
                    projectTask: widget.projectTask,
                  ),
                ),
              )
          : null,
      title: Text(widget.projectTask.status),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fase: ${widget.projectTask.projectPhase}'),
          Text('Tarea: ${widget.projectTask.name}'),
          Row(
            children: [
              Expanded(
                child: Text('Inicia: ${widget.projectTask.startingFormat}'),
              ),
              Expanded(
                child: Text('Finaliza: ${widget.projectTask.endingFormat}'),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              getButton('iniciar'),
              getButton('pausar'),
              getButton('finalizar'),
            ],
          ),
          !widget.isTappable
              ? Text('Descripción: ${widget.projectTask.description ?? ''}')
              : Container()
        ],
      ),
    );
  }

  Widget getButton(String _action) {
    String _status = '';
    Icon _icon = const Icon(Icons.not_started);
    double _iconSize = 45.0;
    Color? _color;
    double _iconPadding = 5;
    LocationType? _locationType;
    switch (_action) {
      case 'iniciar':
        _status = 'En proceso';
        _icon = const Icon(Icons.not_started);
        _color = Colors.greenAccent[400];
        _locationType = LocationType.TaskStarted;
        break;
      case 'pausar':
        if (widget.projectTask.status == 'En pausa') {
          _status = 'En proceso';
          _icon = const Icon(Icons.play_circle);
          _color = Colors.greenAccent[400];
          _locationType = LocationType.TaskResumed;
        } else {
          _status = 'En pausa';
          _icon = const Icon(Icons.pause_circle);
          _color = Colors.yellow[700];
          _locationType = LocationType.TaskPaused;
        }
        break;
      case 'finalizar':
        _status = 'Tarea Finalizada';
        _icon = const Icon(Icons.stop_circle);
        _color = Colors.red[700];
        _locationType = LocationType.TaskFinished;
        break;
    }

    Widget _widget = IconButton(
      onPressed: () async {
        try {
          await Utils.checkLocationPermission(context);
          if (_action == 'iniciar' ||
              (_action == 'pausar' && _status == 'En proceso')) {
            final projectTasks = await widget.cProjectTask
                .getProjectTasksInProcess(widget.project.id);
            if (projectTasks.length > 0) {
              throw CustomException(
                  "Tiene tareas en proceso, por favor gestiónelas antes de ${_action == 'pausar' && _status == 'En proceso' ? 'reanudar' : _action} esta");
            }
          }
          bool _result = await Utils.confirmDialog(context, 'Confirmación',
              '¿Desea ${_action == 'pausar' && _status == 'En proceso' ? 'reanudar' : _action} la tarea?');
          if (_result) {
            widget.projectTask.status = _status;
            widget.callBack(_locationType);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
        }
      },
      icon: _icon,
      iconSize: _iconSize,
      color: _color,
      padding: EdgeInsets.all(_iconPadding),
    );

    if ((_action == 'iniciar' &&
            !(widget.projectTask.status == '' ||
                widget.projectTask.status == 'Sin iniciar')) ||
        (_action == 'pausar' &&
            (widget.projectTask.status == '' ||
                widget.projectTask.status == 'Sin iniciar' ||
                widget.projectTask.status == 'Tarea Finalizada')) ||
        (_action == 'finalizar' && widget.projectTask.status != 'En proceso')) {
      _widget = IconButton(
        onPressed: () {},
        splashRadius: 0.1,
        icon: _icon,
        iconSize: _iconSize,
        padding: EdgeInsets.all(_iconPadding),
      );
    }

    return _widget;
  }
}
