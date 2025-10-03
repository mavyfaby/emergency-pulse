import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsController extends GetxController {
  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    final box = Hive.box('settings');
    isDarkMode.value = box.get('isDarkMode', defaultValue: false);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    final box = Hive.box('settings');

    box.put('isDarkMode', isDarkMode.value);
  }
}
