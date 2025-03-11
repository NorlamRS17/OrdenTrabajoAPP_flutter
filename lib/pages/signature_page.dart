import 'package:flutter/material.dart';
import 'dart:io';

import 'package:workorders/models/project.dart';

// ignore: must_be_immutable
class SignaturePage extends StatefulWidget {
  SignaturePage({Key? key, required this.project}) : super(key: key);

  Project project;

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firma'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(widget.project.documentNo),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.project.name),
                  Text(widget.project.createdFormat),
                  const Divider(),
                  Text('Cliente: ${widget.project.businessPartner}'),
                ],
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    title: Text('Cliente'),
                  ),
                  Container(
                    child: widget.project.signatureClientLink != null &&
                            (widget.project.signatureClientLink?.isNotEmpty)!
                        ? Image.network(
                            widget.project.signatureClientLink ?? '')
                        : Image.file(
                            File(widget.project.signatureClientImgDir!)),
                    height: 250,
                    color: Colors.white,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child:
                        Text('Nombre: ${widget.project.signatureClientName}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child:
                        Text('Cédula: ${widget.project.signatureClientCifNif}'),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    title: Text('Técnico'),
                  ),
                  Container(
                    child: widget.project.signatureTechLink != null &&
                            (widget.project.signatureTechLink?.isNotEmpty)!
                        ? Image.network(widget.project.signatureTechLink ?? '')
                        : Image.file(File(widget.project.signatureTechImgDir!)),
                    height: 250,
                    color: Colors.white,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text('Nombre: ${widget.project.signatureTechName}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child:
                        Text('Cédula: ${widget.project.signatureTechCifNif}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
