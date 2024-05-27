import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mc_queen_95/controllers/pages/home/home.controller.dart';
import 'package:mc_queen_95/enums/states/home.states.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController pageController = Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'McQueen95 Controller',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const _Header(),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Obx(
                                      () => Text((pageController.paired.value) ? 'left and right paired' : 'left and right not paired'),
                                    ),
                                  ),
                                  Obx(
                                    () => ElevatedButton(
                                      onPressed: pageController.onPairButtonPressed,
                                      child: Text((pageController.paired.value) ? 'seperate' : 'pair'),
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
                        ],
                      ),
                    ),
                    Obx(
                      () => Visibility(
                        visible: pageController.pageState.value != HomeStates.CONNECTED,
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // body: Obx(
      //   () => RefreshIndicator(
      //     onRefresh: pageController.discover,
      //     child: ListView.separated(
      //       padding: const EdgeInsets.symmetric(horizontal: 12.0),
      //       itemBuilder: (context, index) {
      //         BluetoothDiscoveryResult item = pageController.discoverResults[index];
      //         return DiscoverResultCard(item: item);
      //       },
      //       separatorBuilder: (_, __) => const SizedBox(height: 12.0),
      //       itemCount: pageController.discoverResults.length,
      //     ),
      //   ),
      // ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    HomeController pageController = Get.find<HomeController>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Wrap(
            spacing: 12.0,
            children: [
              Obx(
                () => Icon(
                  _getIcon(pageController.pageState.value),
                ),
              ),
              Obx(
                () => Text(
                  _getText(pageController.pageState.value),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => ElevatedButton(
            onPressed: (pageController.pageState.value == HomeStates.CONNECTING)
                ? null
                : (pageController.pageState.value == HomeStates.CONNECTED)
                    ? pageController.onDisconnectButtonPressed
                    : pageController.onConnectButtonPressed,
            child: Text((pageController.pageState.value == HomeStates.CONNECTED) ? 'disconnect' : 'connect'),
          ),
        ),
      ],
    );
  }

  IconData _getIcon(HomeStates pageState) {
    if (pageState == HomeStates.CONNECTING) {
      return Icons.bluetooth_searching;
    } else if (pageState == HomeStates.CONNECTED) {
      return Icons.bluetooth_connected;
    }
    return Icons.bluetooth_disabled;
  }

  String _getText(HomeStates pageState) {
    if (pageState == HomeStates.CONNECTING) {
      return 'connecting...';
    } else if (pageState == HomeStates.CONNECTED) {
      return 'connected';
    }
    return 'disconnected';
  }
}
