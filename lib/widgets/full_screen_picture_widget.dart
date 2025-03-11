import 'package:flutter/material.dart';
import 'dart:io';

import 'package:workorders/models/picture.dart';

// ignore: must_be_immutable
class FullScreenPictureWidget extends StatefulWidget {
  FullScreenPictureWidget({Key? key, required this.picture}) : super(key: key);

  Picture picture;

  @override
  State<FullScreenPictureWidget> createState() =>
      _FullScreenPictureWidgetState();
}

class _FullScreenPictureWidgetState extends State<FullScreenPictureWidget> {
  @override
  Widget build(BuildContext context) {
    Widget _image;
    if (widget.picture.id != null && widget.picture.id!.isNotEmpty) {
      _image = Image.network(
        widget.picture.link ?? '',
        // fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      );
    } else {
      _image = Image.file(
        File(widget.picture.imgDir!),
        // fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      );
    }

    return Scaffold(body: _image);
  }
}
