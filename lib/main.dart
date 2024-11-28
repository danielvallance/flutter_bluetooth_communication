import 'package:flutter/material.dart';

void main() {
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
      home: const BluetoothTransceiverHomePage(),
    );
  }
}

class BluetoothTransceiverHomePage extends StatelessWidget {
  const BluetoothTransceiverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Bluetooth Transceiver Home Page"),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'TODO: Add bluetooth transceiver UI widgets',
            ),
          ],
        ),
      ),
    );
  }
}
