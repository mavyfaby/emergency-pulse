import 'dart:convert';

import 'package:emergency_pulse/controllers/location.controller.dart';
import 'package:emergency_pulse/controllers/network.controller.dart';
import 'package:emergency_pulse/model/alert.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

Future<void> fetchAlerts() async {
  final networkCtrl = Get.find<NetworkController>();
  final locationCtrl = Get.find<LocationController>();

  debugPrint("Fetching alerts...");

  final response = await http
      .get(
        Uri.parse(
          "http://${networkCtrl.ipAddress}:${networkCtrl.apiPort}/api/alerts",
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

    locationCtrl.alerts.value = alerts
        .map((alert) => AlertModel.fromJson(alert))
        .toList();

    debugPrint("Alerts fetched successfully! ${locationCtrl.alerts.length}");
    return;
  }

  debugPrint(
    "[2] Failed to fetch alerts with status code ${response.statusCode}",
  );
  return;
}
