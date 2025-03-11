import 'package:flutter/material.dart';
import 'package:workorders/controllers/home_controller.dart';
import 'package:workorders/controllers/location_controller.dart';
import 'package:workorders/pages/control_page.dart';
import 'package:workorders/pages/project_page.dart';
import 'package:provider/provider.dart';
import 'package:workorders/utils/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController _c;

  static final List<Widget> _widgetOptions = <Widget>[
    const ProjectPage(),
    const ProjectPage(),
    const ProjectPage(),
    const ControlPage(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      try {
        await Utils.checkLocationPermission(context);
        await LocationController.startBackgroundLocation();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _c.index = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<HomeController>();

    return Scaffold(
      body: WillPopScope(
        child: Center(
          child: Consumer<HomeController>(
            builder: (context, ctl, child) {
              return _widgetOptions.elementAt(ctl.index);
            },
          ),
        ),
        onWillPop: () async => false,
      ),
      bottomNavigationBar: Consumer<HomeController>(
        builder: (context, ctl, child) {
          return BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.autorenew),
                label: 'En proceso',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline),
                label: 'Finalizadas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pending_outlined),
                label: 'Abiertas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Control',
              ),
            ],
            currentIndex: ctl.index,
            selectedItemColor: Colors.amber[800],
            onTap: _c.setBottomNavigationBarIndex,
          );
        },
      ),
    );
  }
}
