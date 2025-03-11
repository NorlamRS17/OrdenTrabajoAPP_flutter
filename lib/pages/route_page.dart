import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:workorders/controllers/location_controller.dart';
import 'package:workorders/models/project.dart';
import 'package:workorders/utils/constants.dart';
import 'package:workorders/utils/utils.dart';

// ignore: must_be_immutable
class RoutePage extends StatefulWidget {
  RoutePage({Key? key, required this.project}) : super(key: key);

  Project project;

  @override
  State<RoutePage> createState() => RoutePageState();
}

class RoutePageState extends State<RoutePage> {
  late LocationController _c;
  final Completer<GoogleMapController> _cMap = Completer();

  int colorIndex = 0;
  List colors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.deepPurple,
    Colors.teal,
    Colors.indigo,
    Colors.deepOrange,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  final CameraPosition _home = const CameraPosition(
    target: LatLng(LATITUDE, LONGITUDE),
    zoom: 14,
  );

  CameraPosition? _firstPulse;
  double _kmSummary = 0;

  BitmapDescriptor getBitmapDescriptor(String type) {
    late BitmapDescriptor bitmapDescriptor;
    switch (type) {
      case 'Iniciada: Tarea':
        bitmapDescriptor = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        );
        break;
      case 'Pausada: Tarea':
        bitmapDescriptor = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
        break;
      case 'Reanudada: Tarea':
        bitmapDescriptor = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        );
        break;
      case 'Completada: Tarea':
        bitmapDescriptor = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        );
        break;
      case 'Finalizar: Orden de Trabajo':
        bitmapDescriptor = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        );
        break;
      default:
        bitmapDescriptor = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        );
    }
    return bitmapDescriptor;
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) async {
        final _project = await _c.getRoute(project: widget.project);

        _project.locationEvents?.forEach(
          (location) {
            _markers.add(
              Marker(
                markerId: MarkerId(
                  location.id != null
                      ? location.id.toString()
                      : location.phoneId!,
                ),
                position: LatLng(
                  location.latitude,
                  location.longitude,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange,
                ),
                infoWindow: InfoWindow(
                  title: location.type,
                  snippet: '${location.createdFormat} ${location.description}',
                ),
              ),
            );
          },
        );

        _project.projectTasks?.asMap().forEach(
          (index, projectTask) {
            List<LatLng> _points = [];
            projectTask.locationEvents?.asMap().forEach(
              (index, location) {
                _markers.add(
                  Marker(
                    markerId: MarkerId(
                      location.id != null
                          ? location.id.toString()
                          : location.phoneId!,
                    ),
                    position: LatLng(
                      location.latitude,
                      location.longitude,
                    ),
                    icon: getBitmapDescriptor(location.type),
                    infoWindow: InfoWindow(
                      title: location.type,
                      snippet:
                          '${location.createdFormat} ${location.description}',
                    ),
                  ),
                );
              },
            );

            projectTask.locationPulses?.forEach(
              (location) {
                _points.add(
                  LatLng(
                    location.latitude,
                    location.longitude,
                  ),
                );
                _firstPulse ??= CameraPosition(
                  target: LatLng(
                    location.latitude,
                    location.longitude,
                  ),
                  zoom: 14,
                );
              },
            );

            _polylines.add(
              Polyline(
                polylineId: PolylineId(
                  projectTask.id.toString(),
                ),
                points: _points,
                width: 3,
                color: colors[colorIndex],
              ),
            );

            if (colorIndex < colors.length - 1) {
              colorIndex++;
            } else {
              colorIndex = 0;
            }

            _kmSummary +=
                Utils.getKmSummary(locations: projectTask.locationPulses!);
          },
        );

        setState(() {});
        _goToFirstPulse();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _goToFirstPulse() async {
    final GoogleMapController controller = await _cMap.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(_firstPulse!),
    );
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<LocationController>();

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _home,
              myLocationEnabled: true,
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _cMap.complete(controller);
              },
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 10,
                top: 10,
              ),
              padding: const EdgeInsets.all(
                10,
              ),
              color: Colors.black87,
              child: Text(
                'Distancia: ${_kmSummary.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
