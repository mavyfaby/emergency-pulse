import 'dart:async';

import 'package:emergency_pulse/controllers/info.controller.dart';
import 'package:emergency_pulse/controllers/network.controller.dart';
import 'package:emergency_pulse/controllers/responder.controller.dart';
import 'package:emergency_pulse/controllers/settings.controller.dart';
import 'package:emergency_pulse/pages/home.dart' show PageHome;
import 'package:emergency_pulse/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vibration/vibration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('info');
  await Hive.openBox('pings');

  final infoCtrl = Get.put(InfoController());
  final settingsCtrl = Get.put(SettingsController());
  final networkCtrl = Get.put(NetworkController());

  Get.put(ResponderController());

  settingsCtrl.packageInfo = await PackageInfo.fromPlatform();
  settingsCtrl.hasVibrator.value = await Vibration.hasVibrator();

  await infoCtrl.load(willInitLocation: false);

  final isEnabled = await Geolocator.isLocationServiceEnabled();
  infoCtrl.isLocationServiceEnabled.value = isEnabled;

  infoCtrl.listenToLocationService();
  networkCtrl.listenConnectivity();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings("ic_launcher"),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    final networkCtrl = Get.find<NetworkController>();
    final infoCtrl = Get.find<InfoController>();

    // Set up periodic task
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      networkCtrl.connect();
    });

    // Listen to location updates
    infoCtrl.checkLocationService();
    infoCtrl.checkLocationPermission();
    infoCtrl.listenLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
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
