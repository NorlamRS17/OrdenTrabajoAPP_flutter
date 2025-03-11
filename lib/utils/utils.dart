import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:workorders/exceptions/custom_exception.dart';
import 'package:workorders/models/location.dart';
import 'package:workorders/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:workorders/widgets/location_dialog_widget.dart';

abstract class Utils {
  static String getBasicAuth() {
    return 'Basic ' + base64Encode(utf8.encode('$USERNAME:$PASSWORD'));
  }

  static DateTime? getDate(String? _date) {
    DateTime? date;
    if (_date != null) {
      date = DateTime.parse(_date);
      date = date.isUtc ? date.toLocal() : date;
    }
    return date;
  }

  static String? getDateOBFormat(DateTime? _date) {
    String? date;
    if (_date != null) {
      date = DateFormat("yyyy-MM-dd'T'HH:mm:ss-05:00").format(_date);
    }
    return date;
  }

  static double? getDouble(final _value) {
    double? value;
    if (_value != null) {
      value = double.tryParse(_value.toString());
    }
    return value;
  }

  static Future<void> setSPString(String _key, String _value) async {
    final _sP = await SharedPreferences.getInstance();
    _sP.setString(_key, _value);
  }

  static Future<String?> getSPString(String _key) async {
    final _sP = await SharedPreferences.getInstance();
    return _sP.getString(_key);
  }

  static Future<bool?> removeSPString(String _key) async {
    final _sP = await SharedPreferences.getInstance();
    return _sP.remove(_key);
  }

  static Future<Directory> createPictureDirectory(String _subPath) async {
    Directory _dir = await getApplicationDocumentsDirectory();
    String _path = join(_dir.parent.path, 'files', _subPath);
    final _storage = Directory(_path);
    if (!(await _storage.exists())) {
      await _storage.create(recursive: true);
    }

    if (!(await _storage.exists())) {
      throw CustomException('Error al intentar crear el directorio');
    }

    return _storage;
  }

  static Future<void> checkStoragePermission() async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    final storageStatus = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    if (storageStatus == PermissionStatus.granted) {
      print("granted");
    }
    if (storageStatus == PermissionStatus.denied) {
      throw CustomException(
          'Debe aceptar el permiso de acceso al almacenamiento');
        }

    if (storageStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
   /* await Permission.storage.request();
    if (!(await Permission.storage.isGranted)) {*/

  }

  static Future<void> checkLocationPermission(BuildContext context) async {
    String message =
        'El permiso de localización (Nivel de permiso: Permitir todo el tiempo) es requerido para el funcionamiento de Órdenes de trabajo';
    bool consent = false;
    bool isLocationGranted = await Permission.location.isGranted;
    if (!isLocationGranted) {
      consent = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const LocationDialogWidget();
        },
      );
    } else {
      consent = true;
    }

    if (consent) {
      PermissionStatus result = await Permission.location.request();
      if (result.isPermanentlyDenied) {
        throw CustomException(
            '$message pero fue denegado permanentemente, por favor gestiónelo desde los ajustes del sistema');
      } else if (result.isDenied) {
        throw CustomException(message);
      }

      await Permission.locationAlways.request();
    } else {
      throw CustomException(message);
    }
  }

  static Future<bool> confirmDialog(
      BuildContext _context, String _title, String? _message) async {
    Widget cancelButton = TextButton(
      child: const Text("Cancelar"),
      onPressed: () => Navigator.pop(_context, false),
    );
    Widget continueButton = TextButton(
      child: const Text("Aceptar"),
      onPressed: () => Navigator.pop(_context, true),
    );

    AlertDialog alert = AlertDialog(
      title: Text(_title),
      content: _message != null ? Text(_message) : null,
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    return await showDialog(
      context: _context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static double getKmSummary({required List<Location> locations}) {
    double kmSummary = 0;
    late double lastLatitude;
    late double lastLongitude;
    if (locations.length > 0) {
      lastLatitude = locations[0].latitude;
      lastLongitude = locations[0].longitude;
    }
    if (locations.length > 1) {
      for (var i = 1; i < locations.length; i++) {
        // kmSummary += sqrt(
        //     pow(locations[i].latitude - locations[i - 1].latitude, 2) +
        //         pow(locations[i].longitude - locations[i - 1].longitude, 2));

        kmSummary += Geolocator.distanceBetween(lastLatitude, lastLongitude,
            locations[i].latitude, locations[i].longitude);
        lastLatitude = locations[i].latitude;
        lastLongitude = locations[i].longitude;
      }
    }
    // return kmSummary * 100;
    return kmSummary / 1000;
  }

  static Future<bool> hasConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }
}
