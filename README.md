# flutter_bluetooth_communication
Simple example of a Flutter app which sends and receives data over Bluetooth.

The purpose of this project is to experiment with Bluetooth Low Energy (BLE) communication in Flutter, which may serve as a foundation for future mobile applications that will interface with some embedded hardware projects I am working on.

# Building and Running

Run ```flutter run``` from the root directory of this repository to launch the app.

I ran this on an Android device, which required the usual steps of turning on developer options, setting up USB debugging, and choosing the Android device as the target.

This program was run in conjunction with the bluetooth byte shifting server running on my STM32F3DISCOVERY which can be found here: https://github.com/danielvallance/bluetooth_byte_shifter

# Demo

This demo shows the running of this Flutter app and demonstrates:
* Scanning for devices
* Connecting to a device (in this case, a HM-10 bluetooth module connected to an STM32F3DISCOVERY running this server: https://github.com/danielvallance/bluetooth_byte_shifter)
* Sending characters, and getting them back byte shifted, over Bluetooth Low Energy

https://github.com/user-attachments/assets/4cae03ae-62c3-49c0-b7a8-57e8f1eb3377

Here are the accompanying logs from the bluetooth byte shifting server running on the STM32F3DISCOVERY

![demo](https://github.com/user-attachments/assets/90b08c17-1a44-4515-a055-0e7a51cab6a2)
