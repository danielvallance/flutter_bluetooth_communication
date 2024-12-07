import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Future<BluetoothCharacteristic?> getReadWriteCharacteristic(
    BluetoothDevice device) async {
  for (BluetoothService service in await device.discoverServices()) {
    for (BluetoothCharacteristic c in service.characteristics) {
      if (c.properties.writeWithoutResponse && c.properties.notify) {
        return c;
      }
    }
  }

  return null;
}
