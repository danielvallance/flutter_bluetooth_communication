import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_communication/utilities.dart';

class BluetoothConnectionControl extends StatefulWidget {
  final void Function(List<ScanResult> bluetoothPeriperals)
      setBluetoothPeripherals;
  final List<ScanResult> bluetoothPeripherals;
  final void Function(BluetoothDevice? connectedDevice) setConnectedDevice;
  final BluetoothDevice? Function() getConnectedDevice;
  final void Function(BluetoothCharacteristic? readWriteCharacteristic)
      setReadWriteCharacteristic;
  final void Function(String message) setMessage;
  final BluetoothCharacteristic? Function() getReadWriteCharacteristic;

  const BluetoothConnectionControl(
      {super.key,
      required this.setBluetoothPeripherals,
      required this.bluetoothPeripherals,
      required this.setConnectedDevice,
      required this.getConnectedDevice,
      required this.setReadWriteCharacteristic,
      required this.getReadWriteCharacteristic,
      required this.setMessage});

  @override
  State<BluetoothConnectionControl> createState() =>
      _BluetoothConnectionControlState();
}

class _BluetoothConnectionControlState
    extends State<BluetoothConnectionControl> {
  bool _isScanning = false;
  BluetoothDevice? _connectingDevice;
  StreamSubscription<BluetoothConnectionState>? _disconnectionSubscription;
  StreamSubscription<List<int>>? _notifySubscription;

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
    BluetoothDevice? connectedDevice = widget.getConnectedDevice();
    if (connectedDevice != null) {
      _cancelConnection(connectedDevice);
    }
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
    await _disconnectionSubscription?.cancel().catchError((e) {
      log(e);
    });
    _disconnectionSubscription = null;

    await _notifySubscription?.cancel().catchError((e) {
      log(e);
    });
    _notifySubscription = null;

    await device.disconnect(queue: false).catchError((e) {
      log(e);
    });
    widget.setReadWriteCharacteristic(null);
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
      BluetoothCharacteristic? readWriteCharacteristic;

      try {
        await device.connect(mtu: null);
        readWriteCharacteristic = await getReadWriteCharacteristic(device);

        if (readWriteCharacteristic == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Could not find service offered by the chosen device with the required characteristics.'),
              backgroundColor: Colors.red,
            ),
          );
          await _cancelConnection(device);
          return;
        }

        await readWriteCharacteristic.setNotifyValue(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to connect to device: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );

        await _cancelConnection(device);

        return;
      }

      _notifySubscription =
          readWriteCharacteristic.onValueReceived.listen((utf8Bytes) {
        try {
          widget.setMessage(utf8.decode(utf8Bytes));
        } catch (e) {
          widget.setMessage("Could not decode received bytes: ${e.toString()}");
        }
      });

      final notifySubscriptionCopy = _notifySubscription;
      if (notifySubscriptionCopy != null) {
        device.cancelWhenDisconnected(notifySubscriptionCopy);
      }

      _disconnectionSubscription =
          device.connectionState.listen((BluetoothConnectionState state) async {
        if (state == BluetoothConnectionState.disconnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Device with ID ${device.remoteId} disconnected"),
              backgroundColor: Colors.red,
            ),
          );
          await _cancelConnection(device);
        }
      });

      widget.setReadWriteCharacteristic(readWriteCharacteristic);
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
