import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_communication/bluetooth_connection_control.dart';

import 'received_message_display.dart';

class BluetoothTransceiverHomePage extends StatefulWidget {
  BluetoothTransceiverHomePage({super.key});

  @override
  State<BluetoothTransceiverHomePage> createState() =>
      _BluetoothTransceiverHomePageState();
}

class _BluetoothTransceiverHomePageState
    extends State<BluetoothTransceiverHomePage> {
  final TextEditingController _controller = TextEditingController();

  List<ScanResult> _bluetoothPeripherals = [];

  void _setBluetoothPeripherals(List<ScanResult> bluetoothPeriperals) {
    _bluetoothPeripherals = bluetoothPeriperals;
    setState(() {});
  }

  void _handlePress() {
    String message = _controller.text;
    String base64message = base64.encode(message.codeUnits);
    log('Text entered: $message base64 encoding: $base64message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Bluetooth Transceiver Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const ReceivedMessageDisplay(
                message: "TODO: display received Bluetooth data"),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter text to send over Bluetooth',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handlePress,
              child: const Text('Send'),
            ),
            BluetoothConnectionControl(
                setBluetoothPeripherals: _setBluetoothPeripherals,
                bluetoothPeripherals: _bluetoothPeripherals),
          ],
        ),
      ),
    );
  }
}
