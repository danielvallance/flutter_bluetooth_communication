import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffFallback extends StatelessWidget {
  const BluetoothOffFallback({super.key});

  _turnOnBluetoothAdapter() async {
    try {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Bluetooth Transceiver - Adapter Off Fallback Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
                'Bluetooth Adapter is off. Must be turned on for this app to function.'),
            if (Platform.isAndroid)
              ElevatedButton(
                onPressed: _turnOnBluetoothAdapter,
                child: const Text('Turn on Bluetooth'),
              )
          ],
        ),
      ),
    );
  }
}
