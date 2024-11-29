import 'dart:developer';

import 'package:flutter/material.dart';

class BluetoothConnectionControl extends StatefulWidget {
  const BluetoothConnectionControl({super.key});

  @override
  State<BluetoothConnectionControl> createState() =>
      _BluetoothConnectionControlState();
}

class _BluetoothConnectionControlState
    extends State<BluetoothConnectionControl> {
  bool _isScanning = false;
  List<String> _bluetoothPeripherals = [];
  String? connectingDevice;

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _bluetoothPeripherals = ["Device 1", "Device 2"];
    });
    log("Started scanning (TODO: plug in bluetooth scanning)");
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
      _bluetoothPeripherals.clear();
      connectingDevice = null;
    });
    log("Stopped scanning");
  }

  void _toggleConnect(String deviceName) {
    setState(() {
      if (connectingDevice == deviceName) {
        connectingDevice = null;
      } else {
        connectingDevice = deviceName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      children: [
        ElevatedButton(
          onPressed: _isScanning ? _stopScanning : _startScanning,
          child: Text(_isScanning ? 'Stop Scanning' : 'Start Scanning'),
        ),
        const SizedBox(height: 16),
        if (_isScanning)
          Expanded(
            child: ListView.builder(
              itemCount: _bluetoothPeripherals.length,
              itemBuilder: (context, index) {
                final deviceName = _bluetoothPeripherals[index];
                final isConnecting = deviceName == connectingDevice;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(deviceName),
                      ElevatedButton(
                        onPressed: () => _toggleConnect(deviceName),
                        child: Text(isConnecting ? 'Connecting...' : 'Connect'),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          const Text('Not scanning'),
      ],
    ));
  }
}
