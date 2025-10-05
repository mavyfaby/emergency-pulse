import 'dart:convert';
import 'dart:typed_data';

import 'package:emergency_pulse/controllers/location.controller.dart';
import 'package:emergency_pulse/controllers/network.controller.dart';
import 'package:emergency_pulse/model/alert.dart';
import 'package:emergency_pulse/utils/file.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

String getBaseURL() {
  final networkCtrl = Get.find<NetworkController>();
  return "http://${networkCtrl.ipAddress}:${networkCtrl.apiPort}";
}

Future<void> fetchAlerts() async {
  final locationCtrl = Get.find<LocationController>();

  debugPrint("Fetching alerts...");

  final response = await http
      .get(Uri.parse("${getBaseURL()}/api/alerts"))
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

Future<bool> markAsDone(String hashId, String remarks, Uint8List image) async {
  debugPrint("Marking alert as done...");

  try {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("${getBaseURL()}/api/alerts/$hashId/done"),
    );

    final compressedImage = await FlutterImageCompress.compressWithList(
      image,
      quality: 50,
    );

    request.fields["remarks"] = remarks.trim();
    request.files.add(
      http.MultipartFile.fromBytes(
        "picture",
        compressedImage,
        filename: "image.${getImageExtension(compressedImage.sublist(0, 100))}",
      ),
    );

    final response = await request.send().timeout(
      const Duration(seconds: 10),
      onTimeout: () async {
        debugPrint("[1] Failed to mark alert as done!");
        return http.StreamedResponse(Stream.value([]), 408);
      },
    );

    if (response.statusCode == 200) {
      debugPrint("Alert marked as done successfully!");
      return true;
    }

    debugPrint(
      "[2] Failed to mark alert as done with status code ${response.statusCode}",
    );

    return false;
  } catch (e) {
    debugPrint("[3] Failed to mark alert as done! $e");
    return false;
  }
}
