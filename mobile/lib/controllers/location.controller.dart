import 'package:emergency_pulse/model/alert.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationController extends GetxController {
  // Refresh indicator key
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  final isRefreshing = false.obs;

  // List of alerts
  final alerts = <AlertModel>[].obs;
}
