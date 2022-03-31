import 'package:flutter/material.dart';

import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/app_settings.dart';
import 'package:timer_f1/app/data/providers/app_settings_provider.dart';
import 'package:timer_f1/app/data/providers/db_provider.dart';
import 'package:timer_f1/app/data/providers/theme_provider.dart';
import 'package:timer_f1/core/themes/app_theme.dart';
import 'package:timer_f1/objectbox.g.dart';

import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  var database = await openStore();
  await AppSettings.storage.initStorage;

  runApp(ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(database),
        appSettingsProvider.overrideWithValue(AppSettings()),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          final appThemeState = ref.watch(appThemeStateNotifier);
          return MaterialApp.router(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appThemeState.isDarkModeEnabled
                ? ThemeMode.dark
                : ThemeMode.light,
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
            title: "Timer F1",
          );
        },
      )));
}
