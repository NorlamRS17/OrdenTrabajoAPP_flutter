import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workorders/controllers/user_controller.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/pages/synchronization_page.dart';
import 'package:workorders/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:workorders/widgets/logout_dialog_widget.dart';
import 'package:workorders/widgets/synchronization_dialog_widget.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({Key? key}) : super(key: key);

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  late UserController _cUser;
  String _version = '';

  User? _currentUser;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      PackageInfo _packageInfo = await PackageInfo.fromPlatform();
      _version = _packageInfo.version;
      _currentUser = await _cUser.getCurrentUser();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _cUser = context.read<UserController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _currentUser != null
                      ? Stack(
                          alignment: AlignmentDirectional.topEnd,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Card(
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 50,
                                        backgroundImage: AssetImage(
                                            'assets/images/avatar.png'),
                                      ),
                                    ),
                                    Text(
                                      '${_currentUser?.username}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                          '${_currentUser?.businessPartner}'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const LogoutDialogWidget();
                                  },
                                );
                              },
                              icon: const Icon(Icons.exit_to_app),
                            ),
                          ],
                        )
                      : Container(),
                  Card(
                    child: ListTile(
                      onTap: () async {
                        bool _result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const SynchronizationDialogWidget();
                          },
                        );
                        if (_result) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SynchronizationPage(),
                            ),
                          );
                        }
                      },
                      leading: const Icon(Icons.sync, size: 35),
                      title: const Text('Sincronización General'),
                      trailing: const Icon(Icons.arrow_right),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      onTap: () async {
                        final Uri _url = Uri.parse(PRIVACY_POLICIES_LINK);
                        await launchUrl(_url);
                      },
                      leading: const Icon(Icons.document_scanner, size: 35),
                      title: const Text('Políticas de privacidad'),
                      trailing: const Icon(Icons.arrow_right),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      onTap: () async {
                        await Geolocator.openAppSettings();
                      },
                      leading: const Icon(Icons.settings, size: 35),
                      title: const Text('Configuración de aplicación'),
                      trailing: const Icon(Icons.arrow_right),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      onTap: () async {
                        await Geolocator.openLocationSettings();
                      },
                      leading: const Icon(Icons.settings, size: 35),
                      title: const Text('Configuración de localización'),
                      trailing: const Icon(Icons.arrow_right),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text('Versión: $_version'),
        ],
      ),
    );
  }
}
