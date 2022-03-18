import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/providers/app_settings_provider.dart';

class TimerBLEFilter extends HookConsumerWidget {
  const TimerBLEFilter({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var timerBleFilter =
        ref.watch(appSettingsProvider.select((value) => value.timerBleFilter));
    var controller = useMemoized(() => TextEditingController());
    useEffect(() {
      controller.text = timerBleFilter.val;
      return null;
    }, [timerBleFilter, controller]);

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: <Widget>[
          Text(
            'Timer BLE filter',
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(
            height: 10,
          ),
          Material(
            elevation: 0,
            color: Colors.blueGrey.withAlpha(40),
            child: TextFormField(
              controller: controller,
              autofocus: true,
              minLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: 'Title',
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),
          ),
          TextButton(
              onPressed: () {
                timerBleFilter.val = controller.value.text;
                Navigator.of(context).pop();
              },
              child: Text('Save'))
        ]));
  }
}
