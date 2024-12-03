import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothConnectionControl extends StatefulWidget {
  final void Function(List<ScanResult> bluetoothPeriperals)
      setBluetoothPeripherals;
  final List<ScanResult> bluetoothPeripherals;

  const BluetoothConnectionControl(
      {super.key,
      required this.setBluetoothPeripherals,
      required this.bluetoothPeripherals});

  @override
  State<BluetoothConnectionControl> createState() =>
      _BluetoothConnectionControlState();
}

class _BluetoothConnectionControlState
    extends State<BluetoothConnectionControl> {
  bool _isScanning = false;
  String? connectingId;

  late StreamSubscription<List<ScanResult>> _bluetoothPeripheralSubscription;

  @override
  void initState() {
    super.initState();

    _bluetoothPeripheralSubscription =
        FlutterBluePlus.scanResults.listen((results) {
      widget.setBluetoothPeripherals(results);
    }, onError: (e) => log(e));
  }

  @override
  void dispose() {
    FlutterBluePlus.cancelWhenScanComplete(_bluetoothPeripheralSubscription);
    super.dispose();
  }

  void _startScanning() async {
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      setState(() {
        _isScanning = true;
      });
      log("Started scanning");
    } catch (e) {
      log("Failed to start scanning: $e");
    }
  }

  void _stopScanning() {
    try {
      FlutterBluePlus.stopScan();
      setState(() {
        _isScanning = false;
        widget.setBluetoothPeripherals(List.empty());
        connectingId = null;
      });

      log("Stopped scanning");
    } catch (e) {
      log("Failed to stop scanning: $e");
    }
  }

  void _toggleConnect(String deviceId) {
    setState(() {
      if (connectingId == deviceId) {
        connectingId = null;
      } else {
        connectingId = deviceId;
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
              itemCount: widget.bluetoothPeripherals.length,
              itemBuilder: (context, index) {
                final deviceId =
                    widget.bluetoothPeripherals[index].device.remoteId.str;
                final deviceName =
                    widget.bluetoothPeripherals[index].device.advName.isEmpty
                        ? "No name"
                        : widget.bluetoothPeripherals[index].device.advName;

                final isConnecting = deviceId == connectingId;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(deviceName),
                      ElevatedButton(
                        onPressed: () => _toggleConnect(deviceId),
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
