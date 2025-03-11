import 'package:flutter/material.dart';

class LoaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Container(
        height: 100,
        child: Column(
          children: const [
            Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Guardando',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
