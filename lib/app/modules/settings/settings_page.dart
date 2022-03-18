import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timer_f1/app/data/providers/app_settings_provider.dart';
import 'package:timer_f1/app/modules/settings/language_page.dart';
import 'package:timer_f1/app/modules/settings/widgets/timer_ble_filter.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<PackageInfo?> packageInfo = useState(null);
    useEffect(() {
      PackageInfo.fromPlatform()
          .then((value) => packageInfo.value = value)
          .catchError((_) {});
      return null;
    }, []);

    return Scaffold(
        appBar: AppBar(title: Text('Settings UI')),
        body: SettingsList(
          contentPadding: EdgeInsets.only(top: 30),
          sections: [
            SettingsSection(
              title: 'Common',
              tiles: [
                SettingsTile(
                  title: 'Language',
                  trailing: Text('English'),
                  leading: Icon(Icons.language),
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => LanguagesScreen(),
                    ));
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'Bluetooth',
              tiles: [
                SettingsTile(
                  title: 'Timer device name filter',
                  trailing: Text(ref.watch(appSettingsProvider
                      .select((value) => value.timerBleFilter.val))),
                  onPressed: (context) {
                    AwesomeDialog(
                            context: context,
                            headerAnimationLoop: false,
                            animType: AnimType.SCALE,
                            dialogType: DialogType.NO_HEADER,
                            keyboardAware: true,
                            body: TimerBLEFilter())
                        .show();
                  },
                )
              ],
            ),
            SettingsSection(
              title: 'Misc',
              tiles: [
                SettingsTile(
                    title: 'Open source licenses',
                    leading: Icon(Icons.collections_bookmark)),
              ],
            ),
            CustomSection(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 22, bottom: 8),
                    child: Image.asset(
                      'assets/images/settings.png',
                      height: 50,
                      width: 50,
                      color: const Color(0xFF777777),
                    ),
                  ),
                  Text(
                    'Version: ${packageInfo.value?.version}',
                    style: TextStyle(color: Color(0xFF777777)),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
