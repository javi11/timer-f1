import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

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
      appBar: AppBar(title: const Text('Languages')),
      body: SettingsList(
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
    );
  }
}
