import 'package:flutter/material.dart';

import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/providers/db_provider.dart';
import 'package:timer_f1/app/data/providers/storage_provider.dart';
import 'package:timer_f1/objectbox.g.dart';

import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  var database = await openStore();

  runApp(ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(database),
        storageProvider.overrideWithValue(GetStorage()),
      ],
      child: MaterialApp.router(
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        title: "Timer F1",
      )));
}
