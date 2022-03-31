import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/providers/app_settings_provider.dart';
import 'package:timer_f1/global_widgets/buttons/accept_button.dart';
import 'package:timer_f1/global_widgets/header/app_header_title.dart';
import 'package:timer_f1/global_widgets/buttons/cancel_button.dart';

class TimerBLEFilterUpdatePage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var timerBleFilter =
        ref.watch(appSettingsProvider.select((value) => value.timerBleFilter));
    var controller = useMemoized(() => TextEditingController());
    useEffect(() {
      controller.text = timerBleFilter.val;
      return null;
    }, [timerBleFilter, controller]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.indigo),
        title: AppHeaderTitle(
          logo: SizedBox(width: 0),
          title: 'BLE FILTER',
        ),
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          child: Column(children: <Widget>[
            Material(
              elevation: 0,
              color: Colors.blueGrey.withAlpha(40),
              child: TextFormField(
                controller: controller,
                autofocus: true,
                minLines: 1,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.filter_alt_sharp,
                    color: Colors.indigo,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'This filter will be used on the list of bluetooth devices, showing only the devices with this name. This filter can be disabled in the same list page.',
              style: TextStyle(
                  color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
            Spacer(),
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CancelButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      minimumSize: Size(
                        MediaQuery.of(context).size.width / 3,
                        40.0,
                      ),
                      text: 'Cancel'),
                  AcceptButton(
                      minimumSize: Size(
                        MediaQuery.of(context).size.width / 3,
                        40.0,
                      ),
                      onPressed: () {
                        timerBleFilter.val = controller.value.text;
                        Navigator.of(context).pop();
                      },
                      text: 'Save')
                ],
              ),
            )
          ])),
    );
  }
}
