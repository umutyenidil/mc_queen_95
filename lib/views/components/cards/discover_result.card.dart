import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:mc_queen_95/enums/states/discover_result.card.states.dart';
import 'package:mc_queen_95/views/pages/device_control/device_control.page.dart';

class DiscoverResultCard extends StatefulWidget {
  const DiscoverResultCard({
    super.key,
    required this.item,
  });

  final BluetoothDiscoveryResult item;

  @override
  State<DiscoverResultCard> createState() => _DiscoverResultCardState();
}

class _DiscoverResultCardState extends State<DiscoverResultCard> {
  DiscoverResultCardStates? state;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.all(2.0),
      ),
      onPressed: () async {
        try {
          // await FlutterBluetoothSerial.instance.disconnect();
          setState(() {
            state = DiscoverResultCardStates.CONNECTING;
          });
          BluetoothConnection connection = await BluetoothConnection.toAddress(widget.item.device.address);

          Get.to(DeviceControlPage(), arguments: {
            'connection': connection,
            'discoveryResult': widget.item,
          });
        } catch (e) {
          setState(() {
            state = DiscoverResultCardStates.ERROR;
          });
        }
        // for (int i = 0; i < 5; i++) {
        //   connection.output.add(Uint8List.fromList(utf8.encode('text')));
        //   await connection.output.allSent;
        //   await Future.delayed(const Duration(milliseconds: 500));
        // }
      },
      child: ListTile(
        title: Text(
          widget.item.device.name ?? 'unknown',
        ),
        subtitle: Text(
          widget.item.device.address,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 10.0,
            fontWeight: FontWeight.w300,
          ),
        ),
        trailing: _trailing,
      ),
    );
  }

  Widget? get _trailing {
    if (state == DiscoverResultCardStates.CONNECTING) {
      return const SizedBox.square(
        dimension: 24.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          strokeCap: StrokeCap.round,
        ),
      );
    }

    if (state == DiscoverResultCardStates.ERROR) {
      return const Icon(Icons.error);
    }

    return null;
  }
}
