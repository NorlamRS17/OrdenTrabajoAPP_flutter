import 'package:flutter/material.dart';
import 'package:workorders/controllers/location_controller.dart';
import 'package:workorders/controllers/session_controller.dart';
import 'package:workorders/pages/login_page.dart';
import 'package:workorders/utils/db_helper.dart';

class LogoutDialogWidget extends StatefulWidget {
  const LogoutDialogWidget({Key? key}) : super(key: key);

  @override
  State<LogoutDialogWidget> createState() => _LogoutDialogWidgetState();
}

class _LogoutDialogWidgetState extends State<LogoutDialogWidget> {
  bool _deleteDatabase = false;

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text("Cancelar"),
      onPressed: () => Navigator.pop(context, false),
    );

    Widget continueButton = TextButton(
      child: const Text("Aceptar"),
      onPressed: () async {
        await SessionController.logout();
        await LocationController.stopBackgroundLocation();
        if (_deleteDatabase) {
          await DBHelper.deleteDb();
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      },
    );

    return AlertDialog(
      title: const Text('Confirmación'),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('¿Desea cerrar su sesión?')),
          SizedBox(height: 10),
          Row(
            children: [
              Switch(
                value: _deleteDatabase,
                onChanged: (value) {
                  setState(
                    () {
                      _deleteDatabase = !_deleteDatabase;
                    },
                  );
                },
              ),
              const Text('¿Eliminar base de datos?'),
            ],
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            cancelButton,
            continueButton,
          ],
        )
      ],
    );
  }
}
