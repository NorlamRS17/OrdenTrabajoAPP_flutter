import 'package:flutter/material.dart';

class LocationDialogWidget extends StatefulWidget {
  const LocationDialogWidget({Key? key}) : super(key: key);

  @override
  State<LocationDialogWidget> createState() => _LocationDialogWidgetState();
}

class _LocationDialogWidgetState extends State<LocationDialogWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text("Cancelar"),
      onPressed: () => Navigator.pop(context, false),
    );

    Widget continueButton = TextButton(
      child: const Text("Aceptar"),
      onPressed: () async {
        Navigator.pop(context, true);
      },
    );

    return AlertDialog(
      title: const Text('Aviso importante'),
      scrollable: true,
      content: Text(
          'Órdenes de trabajo recopila datos de ubicación para dejar registro de los desplazamientos de cada tarea en proceso, incluso cuando la aplicación está en segundo plano ¿Está de acuerdo con esto?'),
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
