import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothConnectionControl extends StatefulWidget {
  final void Function(List<ScanResult> bluetoothPeriperals)
      setBluetoothPeripherals;
  final List<ScanResult> bluetoothPeripherals;
  final void Function(BluetoothDevice? connectedDevice) setConnectedDevice;
  final BluetoothDevice? Function() getConnectedDevice;

  const BluetoothConnectionControl(
      {super.key,
      required this.setBluetoothPeripherals,
      required this.bluetoothPeripherals,
      required this.setConnectedDevice,
      required this.getConnectedDevice});

  @override
  State<BluetoothConnectionControl> createState() =>
      _BluetoothConnectionControlState();
}

class _BluetoothConnectionControlState
    extends State<BluetoothConnectionControl> {
  bool _isScanning = false;
  BluetoothDevice? _connectingDevice;
  late StreamSubscription<BluetoothConnectionState>? _disconnectionSubscription;

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
    BluetoothDevice? connectedDevice = widget.getConnectedDevice();

    if (connectedDevice != null) {
      _cancelConnection(connectedDevice);
    }

    try {
      await FlutterBluePlus.startScan(
          timeout: const Duration(
              seconds:
                  15)); // TODO: Handle timeout by subscribing to isScanning event
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
        _connectingDevice = null;
      });

      log("Stopped scanning");
    } catch (e) {
      log("Failed to stop scanning: $e");
    }
  }

  Future<void> _cancelConnection(BluetoothDevice device) async {
    await _disconnectionSubscription?.cancel();
    _disconnectionSubscription = null;

    await device.disconnect(queue: false);

    setState(() {
      _connectingDevice = null;
      widget.setConnectedDevice(null);
    });
  }

  void _toggleConnect(BluetoothDevice device) async {
    if (_connectingDevice == device) {
      await _cancelConnection(device);
    } else {
      setState(() {
        _connectingDevice = device;
      });
      try {
        await device.connect(mtu: null);
      } catch (e) {
        log(e.toString());

        await _cancelConnection(device);

        return;
      }

      _disconnectionSubscription =
          device.connectionState.listen((BluetoothConnectionState state) async {
        if (state == BluetoothConnectionState.disconnected) {
          log("Device with ID ${device.remoteId} disconnected");
          await _cancelConnection(device);
        }
      });

      setState(() {
        _connectingDevice = null;
        widget.setConnectedDevice(device);
      });

      _stopScanning();
    }
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
                final device = widget.bluetoothPeripherals[index].device;
                final deviceName =
                    widget.bluetoothPeripherals[index].device.advName.isEmpty
                        ? "No name"
                        : widget.bluetoothPeripherals[index].device.advName;

                final isConnecting =
                    device.remoteId == _connectingDevice?.remoteId;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(deviceName),
                      ElevatedButton(
                        onPressed: () => _toggleConnect(device),
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
