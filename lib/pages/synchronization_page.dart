import 'package:flutter/material.dart';
import 'package:workorders/controllers/synchronization_controller.dart';
import 'package:provider/provider.dart';

class SynchronizationPage extends StatefulWidget {
  const SynchronizationPage({Key? key}) : super(key: key);

  @override
  State<SynchronizationPage> createState() => _SynchronizationPageState();
}

class _SynchronizationPageState extends State<SynchronizationPage> {
  late SynchronizationController _c;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      try {
        await _c.synchronizationUp();
        await _c.synchronizationDown();
        await _c.uploadLocations();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _c.log = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = context.read<SynchronizationController>();

    return Scaffold(
      body: Consumer<SynchronizationController>(
        builder: (context, ctl, child) {
          return WillPopScope(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 150.0,
                  padding: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                  ),
                  child: Image.asset('assets/images/logo.png', width: 250.0),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(5),
                    color: const Color.fromRGBO(0, 0, 0, 0.4),
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Consumer<SynchronizationController>(
                        builder: (context, ctl, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(ctl.log.length,
                                (index) => Text(ctl.log[index])),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                ctl.isProcessing
                    ? const LinearProgressIndicator()
                    : Container(),
              ],
            ),
            onWillPop: () async => !ctl.isProcessing,
          );
        },
      ),
    );
  }
}
