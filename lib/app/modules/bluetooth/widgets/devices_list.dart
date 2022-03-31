import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/global_widgets/header/app_header_title.dart';

class DeviceList extends HookConsumerWidget {
  final bool isScanning;
  final Future<void> Function(Device device) onPair;
  final Function onRetry;

  DeviceList({
    Key? key,
    required this.isScanning,
    required this.onPair,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var nameFilter = useState(true);
    final deviceList = ref
        .watch(bleControllerProvider.select((value) => value.scannedDevices));
    var filteredDeviceList = useState(deviceList.toList());
    useEffect(() {
      if (nameFilter.value == true) {
        filteredDeviceList.value =
            deviceList.takeWhile((value) => value.name == timerName).toList();
      } else {
        filteredDeviceList.value = deviceList;
      }
      return null;
    }, [deviceList, nameFilter]);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.indigo),
          title: AppHeaderTitle(
            logo: SizedBox(width: 0),
            title: 'CONNECTING...',
          ),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Container(
                    decoration: BoxDecoration(color: Colors.blue[50]),
                    child: ListTile(
                      leading: IconButton(
                        iconSize: 30.0,
                        padding: EdgeInsets.all(5),
                        icon: Padding(
                            padding: EdgeInsets.zero,
                            child: nameFilter.value == true
                                ? Icon(Icons.filter_list)
                                : Icon(Icons.filter_list_off)),
                        onPressed: () {
                          nameFilter.value = !nameFilter.value;
                        },
                      ),
                      title: Text(
                        '${filteredDeviceList.value.length} DEVICES FOUND.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500]),
                      ),
                      subtitle: Text(
                        'Tap on one of the devices to pair.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      trailing: isScanning
                          ? filteredDeviceList.value.isNotEmpty
                              ? CircularProgressIndicator()
                              : SizedBox(
                                  width: 10,
                                )
                          : TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blue),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.all(8.0)),
                              ),
                              onPressed: () => onRetry(),
                              child: Text(
                                "Scan",
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.white),
                              )),
                    )),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 200,
                    padding: const EdgeInsets.all(20),
                    child: filteredDeviceList.value.isEmpty && isScanning
                        ? Center(
                            child: SizedBox(
                            width: MediaQuery.of(context).size.width - 60,
                            height: MediaQuery.of(context).size.height,
                            child: Lottie.asset(
                                "assets/animations/start-scanning.json",
                                repeat: true),
                          ))
                        : ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: filteredDeviceList.value.length,
                            itemBuilder: (BuildContext ctx, int index) {
                              Device device = filteredDeviceList.value[index];

                              return ListTile(
                                onTap: () async {
                                  await onPair(device);
                                },
                                leading: Icon(Icons.bluetooth),
                                isThreeLine: true,
                                subtitle: Text(
                                    'Signal: ${device.rssi} mDb \n Id: ${device.id}'),
                                title: Text(device.name),
                              );
                            })),
              ],
            )));
  }
}
