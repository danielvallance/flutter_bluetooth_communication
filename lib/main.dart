import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_communication/bluetooth_connection_control.dart';
import 'package:flutter_bluetooth_communication/received_message_display.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const BluetoothTransceiverApp());
}

class BluetoothTransceiverApp extends StatelessWidget {
  const BluetoothTransceiverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Transceiver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BluetoothTransceiverHomePage(),
    );
  }
}

class BluetoothTransceiverHomePage extends StatelessWidget {
  BluetoothTransceiverHomePage({super.key});

  final TextEditingController _controller = TextEditingController();

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
            const BluetoothConnectionControl(),
          ],
        ),
      ),
    );
  }
}
