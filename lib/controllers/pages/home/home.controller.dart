import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:mc_queen_95/enums/states/home.states.dart';

class HomeController extends GetxController {
  Rx<HomeStates> pageState = Rx<HomeStates>(HomeStates.INIT);

  RxBool paired = RxBool(false);
  RxDouble leftSliderValue = RxDouble(0.0);
  RxDouble rightSliderValue = RxDouble(0.0);

  BluetoothConnection? deviceConnection;

  @override
  void onInit() {
    super.onInit();

    _listenSliderValues();
  }

  void _listenSliderValues() {
    ever(leftSliderValue, (value) {});
    ever(rightSliderValue, (value) {});
  }

  void onPairButtonPressed() {
    paired.value = !paired.value;
  }

  void onLeftSliderChanged(double value) async {
    leftSliderValue.value = value;
    deviceConnection?.output.add(Uint8List.fromList('l${value.toInt()}e'.codeUnits));
    await deviceConnection?.output.allSent;
    if (paired.value) {
      rightSliderValue.value = value;
      deviceConnection?.output.add(Uint8List.fromList('r${value.toInt()}e'.codeUnits));
      await deviceConnection?.output.allSent;
    }
  }

  void onRightSliderChanged(double value) async {
    rightSliderValue.value = value;
    deviceConnection?.output.add(Uint8List.fromList('r${value.toInt()}e'.codeUnits));
    await deviceConnection?.output.allSent;
    if (paired.value) {
      leftSliderValue.value = value;
      deviceConnection?.output.add(Uint8List.fromList('l${value.toInt()}e'.codeUnits));
      await deviceConnection?.output.allSent;
    }
  }

  Future<void> onDisconnectButtonPressed() async {
    await deviceConnection?.close();
    deviceConnection?.dispose();
    pageState.value = HomeStates.DISCONNECTED;
  }

  Future<void> onConnectButtonPressed() async {
    try {
      pageState.value = HomeStates.CONNECTING;

      BluetoothConnection connection = await BluetoothConnection.toAddress('00:23:00:00:05:FA');

      if (connection.isConnected) {
        deviceConnection = connection;
        pageState.value = HomeStates.CONNECTED;
      } else {
        pageState.value = HomeStates.DISCONNECTED;
      }
    } catch (e) {
      pageState.value = HomeStates.ERROR;
    }
  }
}
