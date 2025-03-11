import 'package:flutter/material.dart';

class NoDataWidget extends StatefulWidget {
  NoDataWidget({Key? key}) : super(key: key);

  @override
  State<NoDataWidget> createState() => _NoDataWidgetState();
}

class _NoDataWidgetState extends State<NoDataWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.report_problem,
            size: 35,
          ),
          Text(
            'Sin datos para mostrar',
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}
