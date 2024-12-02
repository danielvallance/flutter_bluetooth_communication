import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_communication/bluetooth_off_fallback.dart';
import 'package:flutter_bluetooth_communication/home_page.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const BluetoothTransceiverApp());
}

class BluetoothTransceiverApp extends StatefulWidget {
  const BluetoothTransceiverApp({super.key});

  @override
  State<BluetoothTransceiverApp> createState() =>
      _BluetoothTransceiverAppState();
}

class _BluetoothTransceiverAppState extends State<BluetoothTransceiverApp> {
  BluetoothAdapterState _bluetoothAdapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> subscription;

  @override
  void initState() {
    super.initState();

    subscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      log("adapterState received state change to: $state");
      _bluetoothAdapterState = state;
      setState(() {});
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Transceiver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _bluetoothAdapterState == BluetoothAdapterState.on
          ? BluetoothTransceiverHomePage()
          : BluetoothOffFallback(),
    );
  }
}
