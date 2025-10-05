import 'package:emergency_pulse/model/alert.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController {
  // Google Map controller
  GoogleMapController? mapController;

  // Refresh indicator key
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  final isRefreshing = false.obs;

  // List of alerts
  final alerts = <AlertModel>[].obs;
}
