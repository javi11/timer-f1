import 'package:backdrop_modal_route/backdrop_modal_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timer_f1/app/data/providers/app_settings_provider.dart';
import 'package:timer_f1/app/modules/settings/language_page.dart';
import 'package:timer_f1/app/modules/settings/timer_ble_filter_update_page.dart';
import 'package:timer_f1/global_widgets/header/app_header_title.dart';

const double deviceFilterInputHeight = 200;

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
        appBar: AppBar(
          centerTitle: false,
          title: AppHeaderTitle(
            logo: SizedBox(width: 0),
            title: 'SETTINGS',
          ),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
            child: SettingsList(
              backgroundColor: Colors.white,
              sections: [
                SettingsSection(
                  title: 'Common',
                  titleTextStyle: const TextStyle(color: Colors.indigo),
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
                  titleTextStyle: const TextStyle(color: Colors.indigo),
                  tiles: [
                    SettingsTile(
                      title: 'Timer device name filter',
                      trailing: Text(ref.watch(appSettingsProvider
                          .select((value) => value.timerBleFilter.val))),
                      onPressed: (context) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => TimerBLEFilterUpdatePage(),
                        ));
                      },
                    )
                  ],
                ),
                SettingsSection(
                  title: 'Misc',
                  titleTextStyle: const TextStyle(color: Colors.indigo),
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
            )));
  }
}
