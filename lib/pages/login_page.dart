import 'package:flutter/material.dart';
import 'package:workorders/controllers/session_controller.dart';
import 'package:workorders/controllers/user_controller.dart';
import 'package:workorders/models/user.dart';
import 'package:workorders/pages/home_page.dart';
import 'package:workorders/pages/initial_sync_page.dart';
import 'package:workorders/utils/utils.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late SessionController _c;
  late UserController _cUser;

  late TextEditingController _user;
  late TextEditingController _pass;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _user = TextEditingController();
    _user.text = '';
    _pass = TextEditingController();
    _pass.text = '';
    super.initState();
  }

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<SessionController>();
    _cUser = context.read<UserController>();

    return WillPopScope(
        child: Scaffold(
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 150.0,
                  padding: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                  ),
                  child: Image.asset('assets/images/logo.png', width: 250.0),
                  // child: const FlutterLogo(size: 150.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _user,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Usuario',
                        hintText: 'Ingrese su usuario'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _pass,
                    obscureText: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Contraseña',
                        hintText: 'Ingrese su contraseña'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Consumer<SessionController>(
                      builder: (context, ctl, child) => !ctl.isProcessing
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 16),
                                minimumSize: const Size.fromHeight(50),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                   await Utils.checkStoragePermission();

                                    User? _localUser =
                                        await _cUser.getUser(_user.text);

                                    await _c.login(_user.text, _pass.text);

                                    if (_localUser == null) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const InitialSynchPage()));
                                    } else {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomePage()));
                                    }
                                  } catch (e) {
                                    print("Erroddr: $e");  // Log the error to see its format
                                    String errorMessage = e.toString();  // Convert it to a string
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMessage.isNotEmpty?errorMessage:"Usuario o contraseña incorrecta")),
                                    );
                                  }
                                }
                              },
                              child: const Text('Acceder'),
                            )
                          : const CircularProgressIndicator()),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async => false);
  }
}
