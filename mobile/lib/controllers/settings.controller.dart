import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsController extends GetxController {
  final isDarkMode = false.obs;
  final mainScaffoldKey = GlobalKey<ScaffoldState>();
  final isTabOpen = false.obs;
  final hasVibrator = false.obs;
  final selectedRadius = 5.obs;

  PackageInfo? packageInfo;
  TabController? tabController;
  PersistentBottomSheetController? bottomSheetCtrl;

  @override
  void onInit() {
    super.onInit();
    final box = Hive.box('settings');
    isDarkMode.value = box.get('isDarkMode', defaultValue: false);
    selectedRadius.value = box.get('selectedRadius', defaultValue: 5);
  }

  void setDarkMode(ThemeMode theme) {
    isDarkMode.value = theme == ThemeMode.dark;
    Get.changeThemeMode(theme);

    final box = Hive.box('settings');

    box.put('isDarkMode', isDarkMode.value);
  }

  void setSelectedRadius(int radius) {
    selectedRadius.value = radius;
    final box = Hive.box('settings');
    box.put('selectedRadius', selectedRadius.value);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    final box = Hive.box('settings');

    box.put('isDarkMode', isDarkMode.value);
  }
}
