import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:mc_queen_95/controllers/pages/device_control/device_control.controller.dart';

class DeviceControlPage extends StatelessWidget {
  const DeviceControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    DeviceControlController pageController = Get.put(DeviceControlController());
    return Scaffold(
      appBar: AppBar(
        title: Text(pageController.discoveryResult.device.name ?? 'unknown'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                minimumSize: const Size(double.infinity, 0),
              ),
              onPressed: () async {
                pageController.connection.output.add(Uint8List.fromList('1'.codeUnits));
                await pageController.connection.output.allSent;
              },
              child: const Text('on'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                minimumSize: const Size(double.infinity, 0),
              ),
              onPressed: () async {
                pageController.connection.output.add(Uint8List.fromList('0'.codeUnits));
                await pageController.connection.output.allSent;
              },
              child: const Text('off'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Obx(
                      () => Text(
                        pageController.leftSliderValue.value.toString(),
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: Obx(
                          () => Slider(
                            min: 0.0,
                            max: 255.0,
                            divisions: 5,
                            value: pageController.leftSliderValue.value,
                            onChanged: pageController.onLeftSliderChanged,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Obx(
                      () => Text(
                        pageController.rightSliderValue.value.toString(),
                      ),
                    ),
                    Obx(
                      () => SizedBox(
                        height: 250,
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: Slider(
                            min: 0.0,
                            max: 255.0,
                            divisions: 5,
                            value: pageController.rightSliderValue.value,
                            onChanged: pageController.onRightSliderChanged,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        pageController.messages[index],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                  itemCount: pageController.messages.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
