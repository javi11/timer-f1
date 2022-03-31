import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:timer_f1/global_widgets/header/app_header_title.dart';

class LanguagesScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var languageIndex = useState(0);
    var trailingWidget = useCallback((int index) {
      return (languageIndex.value == index)
          ? const Icon(Icons.check, color: Colors.blue)
          : const Icon(null);
    }, [languageIndex]);
    var changeLanguage = useCallback((int index) {
      languageIndex.value = index;
    }, [languageIndex]);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.indigo),
          title: AppHeaderTitle(
            logo: SizedBox(width: 0),
            title: 'LANGUAGES',
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          child: SettingsList(
            backgroundColor: Colors.white,
            sections: [
              SettingsSection(tiles: [
                SettingsTile(
                  title: "English",
                  trailing: trailingWidget(0),
                  onPressed: (BuildContext context) {
                    changeLanguage(0);
                  },
                ),
                SettingsTile(
                  title: "Spanish",
                  trailing: trailingWidget(1),
                  onPressed: (BuildContext context) {
                    changeLanguage(1);
                  },
                ),
              ]),
            ],
          ),
        ));
  }
}
