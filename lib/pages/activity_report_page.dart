import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:workorders/controllers/activity_report_controller.dart';
import 'package:workorders/controllers/location_controller.dart';
import 'package:workorders/controllers/picture_controller.dart';
import 'package:workorders/enums/location_type.dart';
import 'package:workorders/models/activity_report.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/project_task.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/utils.dart';
import 'package:workorders/widgets/full_screen_picture_widget.dart';
import 'package:workorders/widgets/loader_widget.dart';

// ignore: must_be_immutable
class ActivityReportPage extends StatefulWidget {
  ActivityReportPage(
      {Key? key,
      required this.project,
      required this.projectTask,
      required this.activityReport})
      : super(key: key);

  Project project;
  ProjectTask projectTask;
  ActivityReport? activityReport;

  @override
  State<ActivityReportPage> createState() => _ActivityReportPageState();
}

class _ActivityReportPageState extends State<ActivityReportPage> {
  late ActivityReportController _c;
  late PictureController _cPicture;
  late LocationController _cLocation;

  late String _id;
  late String _subPath;

  late TextEditingController _report = TextEditingController();
  final  _reportFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      if (widget.activityReport != null) {
        update();
        _cPicture.getPictures(_id);
      }
    });

    _report = TextEditingController();
    _report.text = widget.activityReport?.report ?? '';

    super.initState();
  }

  @override
  void dispose() {
    _report.dispose();
    _cPicture.pictures = [];
    super.dispose();
  }

  void update() {
    _id = (widget.activityReport?.id ?? widget.activityReport?.phoneId)!;
    _subPath =
        'pictures/${widget.project.id}/${widget.projectTask.projectPhaseId}/${widget.projectTask.id}/$_id';
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<ActivityReportController>();
    _cPicture = context.read<PictureController>();
    _cLocation = context.read<LocationController>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: ()async{
            _reportFocus.unfocus();
          try {
            showModalBottomSheet<void>(
              context: context,
              builder: (context) {
                return LoaderWidget();
              },
              isDismissible: false,
            );

            ActivityReport? _activityReport;
            if (widget.activityReport == null) {
              _activityReport = await _c.insert(
                  widget.project, widget.projectTask.id, _report.text);
              await _cLocation.registerActionLocation(
                  locationType: LocationType.AddActivityReport,
                  project: widget.project,
                  projectPhaseId: widget.projectTask.projectPhaseId,
                  projectTask: widget.projectTask);
            } else {
              _activityReport =
                  await _c.update(widget.activityReport!, _report.text);
              await _cLocation.registerActionLocation(
                  locationType: LocationType.UpdateActivityReport,
                  project: widget.project,
                  projectPhaseId: widget.projectTask.projectPhaseId,
                  projectTask: widget.projectTask);
            }
            setState(() {
              widget.activityReport = _activityReport;
              update();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Guardado con éxito'),
              ),
            );
            Navigator.pop(context);
            Navigator.pop(context);

          } catch (e) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );

        }
        }, icon: Icon(Icons.arrow_back)),
        title: const Text('Agregar informe de actividad'),
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

                    ActivityReport? _activityReport;
                    if (widget.activityReport == null) {
                      _activityReport = await _c.insert(
                          widget.project, widget.projectTask.id, _report.text);
                      await _cLocation.registerActionLocation(
                          locationType: LocationType.AddActivityReport,
                          project: widget.project,
                          projectPhaseId: widget.projectTask.projectPhaseId,
                          projectTask: widget.projectTask);
                    } else {
                      _activityReport =
                          await _c.update(widget.activityReport!, _report.text);
                      await _cLocation.registerActionLocation(
                          locationType: LocationType.UpdateActivityReport,
                          project: widget.project,
                          projectPhaseId: widget.projectTask.projectPhaseId,
                          projectTask: widget.projectTask);
                    }

                    Navigator.pop(context);

                    setState(() {
                      widget.activityReport = _activityReport;
                      update();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Guardado con éxito'),
                      ),
                    );
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
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: Column(
                      children: [
                        const ListTile(
                          title: Text('* Informe de actividad'),
                        ),
                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                              controller: _report,
                              focusNode: _reportFocus,
                              minLines: 6,
                              maxLines: 6,
                              autofocus: false,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Ingrese su informe'),
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
                        ),
                        widget.activityReport != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      try {
                                        await Utils.checkStoragePermission();
                                        Directory _storage =
                                            await Utils.createPictureDirectory(
                                                _subPath);

                                        final XFile? _image =
                                            await _picker.pickImage(
                                          source: ImageSource.gallery,
                                          maxWidth: IMAGE_MAX_WIDTH,
                                          maxHeight: IMAGE_MAX_HEIGHT,
                                        );
                                        if (_image != null) {
                                          String _imgDir =
                                              '${_storage.path}/${_image.name}';
                                          await _image.saveTo(_imgDir);
                                          await _cPicture.insert(
                                              widget.project, _id, _imgDir);
                                          await _cLocation
                                              .registerActionLocation(
                                                  locationType:
                                                      LocationType.AddPhoto,
                                                  project: widget.project,
                                                  projectPhaseId: widget
                                                      .projectTask
                                                      .projectPhaseId,
                                                  projectTask:
                                                      widget.projectTask);
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString()),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.wallpaper),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      try {
                                        await Utils.checkStoragePermission();
                                        Directory _storage =
                                            await Utils.createPictureDirectory(
                                                _subPath);

                                        final XFile? _image =
                                            await _picker.pickImage(
                                          source: ImageSource.camera,
                                          maxWidth: IMAGE_MAX_WIDTH,
                                          maxHeight: IMAGE_MAX_HEIGHT,
                                        );
                                        if (_image != null) {
                                          String _imgDir =
                                              '${_storage.path}/${_image.name}';
                                          await _image.saveTo(_imgDir);
                                          await _cPicture.insert(
                                              widget.project, _id, _imgDir);
                                          await _cLocation
                                              .registerActionLocation(
                                                  locationType: LocationType
                                                      .AddPhotoCamera,
                                                  project: widget.project,
                                                  projectPhaseId: widget
                                                      .projectTask
                                                      .projectPhaseId,
                                                  projectTask:
                                                      widget.projectTask);
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString()),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.camera),
                                  ),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  Consumer<PictureController>(
                    builder: (context, ctl, child) {
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                        ),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: ScrollPhysics(),
                        itemCount: ctl.pictures.length,
                        itemBuilder: (BuildContext context, int index) {
                          final _picture = ctl.pictures[index];
                          Widget _image;
                          if (_picture.id != null && _picture.id!.isNotEmpty) {
                            _image = Image.network(_picture.link ?? '');
                          } else {
                            _image = Image.file(File(_picture.imgDir!));
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenPictureWidget(
                                    picture: _picture,
                                  ),
                                ),
                              );
                            },
                            child: _image,
                          );
                        },
                      );
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
