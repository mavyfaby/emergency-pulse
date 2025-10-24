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
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class ResponderController extends GetxController {
  final bounds = "".obs;
  final alerts = <AlertModel>[].obs;
  final cachedAlerts = <String, AlertModel>{}.obs;
  final cachedResolved = <String, AlertModel>{}.obs;

  final isLoadedFromCache = false.obs;
  final isFetchingAlerts = false.obs;
  final isResolvingLoading = false.obs;

  void setBoundsFromMapCamera(MapCamera camera) {
    final bounds = camera.visibleBounds;
    final tl = bounds.northWest;
    final tr = bounds.northEast;
    final br = bounds.southEast;
    final bl = bounds.southWest;

    this.bounds.value =
        "${tl.latitude},${tl.longitude},${tr.latitude},${tr.longitude},${br.latitude},${br.longitude},${bl.latitude},${bl.longitude}";
  }

  void addResolveCache(AlertModel alert) {
    final box = Hive.box('cacheResolves');
    box.put(alert.alertHashId, alert);
    cachedResolved[alert.alertHashId] = alert;
  }

  Future<void> fetchAlerts() async {
    final networkCtrl = Get.find<NetworkController>();
    final infoCtrl = Get.find<InfoController>();
    final settingsCtrl = Get.find<SettingsController>();

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

    final cachedAlertsBox = Hive.box('cacheAlerts');
    final cachedResolvedBox = Hive.box('cacheResolves');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final alerts = data['data'] as List;

      // Save to cache
      cachedAlertsBox.clear();

      for (final alert in alerts) {
        cachedAlertsBox.put(alert['alertHashId'], alert);
      }

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
      "Can't acquire alerts. Loading alerts from cache...",
    );

    final alerts = cachedAlertsBox.values
        .toList()
        .map((alert) => AlertModel.fromJson(alert))
        .toList();

    this.alerts.value = alerts;
    isLoadedFromCache.value = true;

    final resolvedBox = cachedResolvedBox.values.toList().map(
      (alert) => AlertModel.fromJson(alert),
    );

    for (final alert in resolvedBox) {
      cachedResolved[alert.alertHashId] = alert;
    }

    return;
  }
}
