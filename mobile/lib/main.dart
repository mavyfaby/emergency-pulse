import 'dart:async';

import 'package:emergency_pulse/controllers/info.controller.dart';
import 'package:emergency_pulse/controllers/location.controller.dart';
import 'package:emergency_pulse/controllers/network.controller.dart';
import 'package:emergency_pulse/controllers/settings.controller.dart';
import 'package:emergency_pulse/pages/home.dart' show PageHome;
import 'package:emergency_pulse/theme.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('info');
  await Hive.openBox('pings');

  final infoCtrl = Get.put(InfoController());
  Get.put(NetworkController());
  Get.put(SettingsController());
  Get.put(LocationController());

  infoCtrl.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set up periodic task
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      Get.find<NetworkController>().connect();
    });

    // Listen to location updates
    Get.find<InfoController>().listenLocationUpdates();

    final settingsCtrl = Get.find<SettingsController>();

    return GetMaterialApp(
      title: 'Pulse',
      theme: ThemeData(colorScheme: MaterialTheme.lightScheme()),
      themeMode: settingsCtrl.isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,
      darkTheme: ThemeData(colorScheme: MaterialTheme.darkScheme()),
      home: const PageHome(),
    );
  }
}
