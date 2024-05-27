import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

class DeviceControlController extends GetxController {
  late BluetoothDiscoveryResult discoveryResult;
  late BluetoothConnection connection;

  RxList<String> messages = RxList<String>([]);

  RxDouble leftSliderValue = RxDouble(1.0);
  RxDouble rightSliderValue = RxDouble(1.0);

  @override
  void onInit() {
    super.onInit();
    _initArguments();

    _listenDevice();
  }

  @override
  void onClose() {
    connection.close();

    super.onClose();
  }

  void _listenDevice() {
    connection.input!.listen((event) {
      print(event);
    });
  }

  void _initArguments() {
    Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    discoveryResult = args['discoveryResult'];
    connection = args['connection'];
  }

  void onLeftSliderChanged(double value) async {
    leftSliderValue.value = value;

    connection.output.add(Uint8List.fromList('l${value.toInt()}e'.codeUnits));
    await connection.output.allSent;
  }

  void onRightSliderChanged(double value) async {
    rightSliderValue.value = value;

    connection.output.add(Uint8List.fromList('r${value.toInt()}e'.codeUnits));
    await connection.output.allSent;
  }
}
