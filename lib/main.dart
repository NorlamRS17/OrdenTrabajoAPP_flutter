import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workorders/controllers/brand_controller.dart';
import 'package:workorders/controllers/model_controller.dart';
import 'package:workorders/controllers/user_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:workorders/controllers/expense_controller.dart';
import 'package:workorders/controllers/expense_line_controller.dart';
import 'package:workorders/controllers/home_controller.dart';
import 'package:workorders/controllers/location_controller.dart';
import 'package:workorders/controllers/product_controller.dart';
import 'package:workorders/controllers/project_phase_controller.dart';
import 'package:workorders/controllers/spare_part_controller.dart';
import 'package:workorders/controllers/activity_report_controller.dart';
import 'package:workorders/controllers/session_controller.dart';
import 'package:workorders/controllers/picture_controller.dart';
import 'package:workorders/controllers/project_controller.dart';
import 'package:workorders/controllers/project_task_controller.dart';
import 'package:workorders/controllers/synchronization_controller.dart';

import 'package:workorders/pages/splash_page.dart';
import 'package:workorders/utils/db_helper.dart';

import 'background_location.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SessionController()),
        ChangeNotifierProvider(create: (context) => UserController()),
        ChangeNotifierProvider(
            create: (context) => SynchronizationController()),
        ChangeNotifierProvider(create: (context) => HomeController(index: 0)),
        ChangeNotifierProvider(create: (context) => ProjectController()),
        ChangeNotifierProvider(create: (context) => ProjectPhaseController()),
        ChangeNotifierProvider(create: (context) => ProjectTaskController()),
        ChangeNotifierProvider(create: (context) => ActivityReportController()),
        ChangeNotifierProvider(create: (context) => PictureController()),
        ChangeNotifierProvider(create: (context) => LocationController()),
        ChangeNotifierProvider(create: (context) => ExpenseController()),
        ChangeNotifierProvider(create: (context) => ExpenseLineController()),
        ChangeNotifierProvider(create: (context) => ProductController()),
        ChangeNotifierProvider(create: (context) => SparePartController()),
        ChangeNotifierProvider(create: (context) => BrandController()),
        ChangeNotifierProvider(create: (context) => ModelController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        DBHelper.close();
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    List array=[];
    array.add("1");
    array.add('value');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('es', 'ES'),
      ],
      title: 'Ordenes de trabajo',
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      home: const SplashPage(),
    );
  }
}
