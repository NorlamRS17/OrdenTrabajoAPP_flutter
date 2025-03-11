import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:workorders/enums/location_type.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/models/project_task.dart';
import 'package:workorders/services/location_service.dart';
import 'package:workorders/services/project_phase_service.dart';
import 'package:workorders/services/project_task_service.dart';

import '../background_location.dart';
import '../utils/constants.dart';

class LocationController extends ChangeNotifier {
  static bool isActiveService = false;

  static DateTime? lastCheck;
  static bool isProcessing = false;
  static bool isGranted = false;
  static String? result;
  static Position? currentPosition;

  static Position? lastPosition;
  static double? distance;

  static startBackgroundLocation() async {
    await BackgroundLocation.setAndroidNotification(
      title: 'Ordenes de trabajo',
      message: 'Localización en segundo plano',
      icon: '@mipmap/ic_launcher',
    );

     await BackgroundLocation.setAndroidConfiguration(INTERVAL_DURATION);

    await BackgroundLocation.startLocationService(
        distanceFilter: DISTANCE_FILTER.toDouble(),
        forceAndroidLocationManager: false);

    await BackgroundLocation.getLocationUpdates((location) async {
      lastCheck = DateTime.now();
      if (isProcessing) {
        return;
      }

      isGranted = await Permission.location.isGranted;
      if (!isGranted) {
        return;
      }

      try {
        isProcessing = true;
        result = 'OK';
        currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 20));

        await registerLocation(currentPosition!);
      } catch (e) {
        result = e.toString();
      } finally {
        isProcessing = false;
      }
    });

    isActiveService = true;
  }

  static stopBackgroundLocation() async {
    await BackgroundLocation.stopLocationService();
    isActiveService = false;
  }

  static Future<void> registerLocation(Position position) async {
    distance = 0;
    if (lastPosition != null) {
      distance = Geolocator.distanceBetween((lastPosition?.latitude)!,
          (lastPosition?.longitude)!, position.latitude, position.longitude);
    }

    if (lastPosition == null ||
        (distance! >= DISTANCE_FILTER && position.accuracy <= 100)) {
      List<ProjectTask> projectTasks =
          await ProjectTaskService.selectByStatus(status: 'En proceso');
      if (projectTasks.isNotEmpty) {
        print({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'speed': position.speed,
        });

        for (var projectTask in projectTasks) {
          final projectPhases =
              await ProjectPhaseService.select(id: projectTask.projectPhaseId);

          await LocationService.insert(
              projectId: projectPhases[0].projectId,
              projectPhaseId: projectTask.projectPhaseId,
              projectTaskId: projectTask.id,
              latitude: position.latitude,
              longitude: position.longitude,
              type: 'Pulso',
              description: 'Pulso de localización tarea: ${projectTask.name}');
        }

        lastPosition = position;
      }
    }
  }

  Future<void> registerActionLocation(
      {required LocationType locationType,
      required Project project,
      String? projectPhaseId,
      ProjectTask? projectTask}) async {
    bool isGranted = await Permission.location.isGranted;
    if (!isGranted) {
      return;
    }

    if (!isActiveService) {
      await startBackgroundLocation();
    }

    bool _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    String _gpsStatus = '';
    if (!_serviceEnabled) {
      _gpsStatus = ' (GPS deshabilitado)';
    }

    Position _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 20));
    print({
      'latitude': _position.latitude,
      'longitude': _position.longitude,
      'accuracy': _position.accuracy,
      'speed': _position.speed,
    });

    String _type = '';
    String _description = '';
    switch (locationType) {
      case LocationType.Pulse:
        _type = 'Pulso';
        _description =
            'Pulso de localización tarea: ${projectTask?.name}$_gpsStatus';
        break;
      case LocationType.TaskStarted:
        _type = 'Iniciada: Tarea';
        _description = 'Tarea: ${projectTask?.name}$_gpsStatus';
        break;
      case LocationType.TaskPaused:
        _type = 'Pausada: Tarea';
        _description = 'Tarea: ${projectTask?.name}$_gpsStatus';
        break;
      case LocationType.TaskResumed:
        _type = 'Reanudada: Tarea';
        _description = 'Tarea: ${projectTask?.name}$_gpsStatus';
        break;
      case LocationType.TaskFinished:
        _type = 'Completada: Tarea';
        _description = 'Tarea: ${projectTask?.name}$_gpsStatus';
        break;
      case LocationType.AddActivityReport:
        _type = 'Agregado: Informe actividad';
        _description = 'Agregando Actividad$_gpsStatus';
        break;
      case LocationType.UpdateActivityReport:
        _type = 'Actualizado: Informe actividad';
        _description = 'Actualizando Actividad$_gpsStatus';
        break;
      case LocationType.AddPhoto:
        _type = 'Agregado: Imagen en informe actividad';
        _description = 'Agregando Imagen a Actividad$_gpsStatus';
        break;
      case LocationType.AddPhotoCamera:
        _type = 'Agregado: Foto de cámara en informe actividad';
        _description = 'Agregando Toma de foto a Actividad$_gpsStatus';
        break;
      case LocationType.AddSparePartRequest:
        _type = 'Agregado: Solicitud repuestos adicionales';
        _description =
            'Agregando solicitud de repuestos adicionales$_gpsStatus';
        break;
      case LocationType.UpdateSparePartRequest:
        _type = 'Actualizado: Solicitud repuestos adicionales';
        _description =
            'Actualizando Solicitud repuestos adicionales$_gpsStatus';
        break;
      case LocationType.AddExpense:
        _type = 'Agregado: Gastos';
        _description = 'Agregando Gastos$_gpsStatus';
        break;
      case LocationType.UpdateExpense:
        _type = 'Actualizado: Gasto';
        _description = 'Actualizando Gasto$_gpsStatus';
        break;
      case LocationType.AddRemark:
        _type = 'Agregado: Observaciones generales';
        _description = 'Actualizando Observaciones generales$_gpsStatus';
        break;
      case LocationType.FinalizeWorkOrder:
        _type = 'Finalizar: Orden de Trabajo';
        _description = 'Firmando y Finalizando Orden$_gpsStatus';
        break;
    }

    await LocationService.insert(
        projectId: project.id,
        projectPhaseId: projectPhaseId,
        projectTaskId: projectTask?.id,
        latitude: _position.latitude,
        longitude: _position.longitude,
        type: _type,
        description: _description);
  }

  Future<Project> getRoute({required Project project}) async {
    isProcessing = true;
    notifyListeners();
    try {
      project.locationEvents =
          await LocationService.selectEventsByProject(projectId: project.id);
      project.projectTasks =
          await ProjectTaskService.select(projectId: project.id);
      for (var i = 0; i < project.projectTasks!.length; i++) {
        final projectTask = project.projectTasks![i];
        projectTask.locationEvents =
            await LocationService.selectEventsByProjectTask(
                projectId: project.id, projectTaskId: projectTask.id);

        projectTask.locationPulses =
            await LocationService.selectPulsesByProjectTask(
                projectTaskId: projectTask.id);

        try {
          final idleTime = await LocationService.getProjectTaskIdleTime(
              projectTaskId: projectTask.id);
          if (projectTask.idleTime != idleTime) {
            projectTask.idleTime = idleTime;
            projectTask.syncUp.isRequired = true;
            await ProjectTaskService.update(projectTask);
          }
        } catch (e) {}
      }
    } catch (e) {
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }

    return project;
  }
}
