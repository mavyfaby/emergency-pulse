import 'dart:convert';

import 'package:emergency_pulse/controllers/info.controller.dart';
import 'package:emergency_pulse/controllers/network.controller.dart';
import 'package:emergency_pulse/controllers/settings.controller.dart';
import 'package:emergency_pulse/model/alert.dart';
import 'package:emergency_pulse/model/requests/alert_request.dart';
import 'package:emergency_pulse/utils/dialog.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ResponderController extends GetxController {
  final networkCtrl = Get.find<NetworkController>();
  final bounds = "".obs;
  final alerts = <AlertModel>[].obs;

  final isFetchingAlerts = false.obs;
  final isRespondingLoading = false.obs;

  final infoCtrl = Get.find<InfoController>();
  final settingsCtrl = Get.find<SettingsController>();

  void setBoundsFromMapCamera(MapCamera camera) {
    final bounds = camera.visibleBounds;
    final tl = bounds.northWest;
    final tr = bounds.northEast;
    final br = bounds.southEast;
    final bl = bounds.southWest;

    this.bounds.value =
        "${tl.latitude},${tl.longitude},${tr.latitude},${tr.longitude},${br.latitude},${br.longitude},${bl.latitude},${bl.longitude}";
  }

  Future<void> fetchAlerts() async {
    final request = AlertRequest(
      center: "${infoCtrl.lat.value},${infoCtrl.lng.value}",
      radius: settingsCtrl.selectedRadius.value.toString(),
      bounds: bounds.value,
      excludeResolved: settingsCtrl.excludeResolved.value,
    );

    debugPrint("Fetching alerts...");

    final response = await http
        .get(
          Uri.parse(
            "${networkCtrl.apiBaseUrl}/api/alerts?${request.toQuery()}",
          ),
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () async {
            debugPrint("[1] Failed to fetch alerts!");
            return http.Response("", 408);
          },
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final alerts = data['data'] as List;

      this.alerts.value = alerts
          .map((alert) => AlertModel.fromJson(alert))
          .toList();

      showSnackbar("Alerts fetched successfully!");
      debugPrint("Alerts fetched successfully! ${alerts.length}");
      return;
    }

    debugPrint(
      "[2] Failed to fetch alerts with status code ${response.statusCode}",
    );

    showAlertDialog(
      "Failed to fetch alerts",
      "Can't acquire alerts. Please tap refresh alerts again.",
    );

    return;
  }

  Future<void> respond(AlertModel alert) async {
    isRespondingLoading.value = true;

    isRespondingLoading.value = false;
  }
}
