import 'dart:async';
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
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _readWriteCharacteristic;
  String _message = "";

  void _setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  void _setReadWriteCharacteristic(
      BluetoothCharacteristic? readWriteCharacteristic) {
    _readWriteCharacteristic = readWriteCharacteristic;
  }

  BluetoothCharacteristic? _getReadWriteCharacteristic() {
    return _readWriteCharacteristic;
  }

  void _setBluetoothPeripherals(List<ScanResult> bluetoothPeriperals) {
    setState(() {
      _bluetoothPeripherals = bluetoothPeriperals;
    });
  }

  void _setConnectedDevice(BluetoothDevice? connectedDevice) {
    setState(() {
      _connectedDevice = connectedDevice;
    });
  }

  BluetoothDevice? _getConnectedDevice() {
    return _connectedDevice;
  }

  void _handlePress() async {
    String message = _controller.text;
    if (message.isEmpty) return;

    try {
      List<int> bytes = utf8.encode(message);
      await _readWriteCharacteristic
          ?.write(bytes, withoutResponse: true)
          .then((_) {
        _controller.clear();
        log('Message sent: $message');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not send message ${e.toString()}.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            if (_connectedDevice != null) ...[
              Text(
                  "Connected to device ${_connectedDevice?.advName ?? _connectedDevice?.remoteId}"),
              ReceivedMessageDisplay(message: _message),
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
              )
            ],
            BluetoothConnectionControl(
                setBluetoothPeripherals: _setBluetoothPeripherals,
                bluetoothPeripherals: _bluetoothPeripherals,
                setConnectedDevice: _setConnectedDevice,
                getConnectedDevice: _getConnectedDevice,
                setReadWriteCharacteristic: _setReadWriteCharacteristic,
                getReadWriteCharacteristic: _getReadWriteCharacteristic,
                setMessage: _setMessage)
          ],
        ),
      ),
    );
  }
}
