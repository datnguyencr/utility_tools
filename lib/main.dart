import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'storage/pref_storage.dart';
import 'util/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await PrefStorage.init();
  await AppSettings.init(storage);
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  await loadPackageInfo();
  if (AppSettings.isDesktopApp) {
    await setupDesktopApp();
  }
  runApp(
    const MyApp(),
  );
}

Future<void> setupDesktopApp() async {
  await windowManager.ensureInitialized();
  final WindowOptions windowOptions = WindowOptions(
    size: const Size(Constants.desktopAppWidth, Constants.desktopAppHeight),
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: AppSettings.appName,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAlignment(Alignment.center);
    await windowManager.show();
    await windowManager.focus();
  });
  await windowManager
      .setMinimumSize(const Size(Constants.desktopAppWidth, Constants.desktopAppHeight));
  await windowManager
      .setMaximumSize(const Size(Constants.desktopAppWidth, Constants.desktopAppHeight));
  await windowManager.setPreventClose(true);
}

Future<void> loadPackageInfo() async {
  final info = await PackageInfo.fromPlatform();
  AppSettings.appVersion = 'v${info.version}';
  AppSettings.appName = info.appName;
  AppSettings.buildNumber = info.buildNumber;
  AppSettings.packageName = info.packageName;
  AppSettings.isDesktopApp = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}
