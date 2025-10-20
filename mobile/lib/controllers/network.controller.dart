import 'dart:convert';
import 'dart:typed_data';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emergency_pulse/controllers/info.controller.dart';
import 'package:emergency_pulse/enums/status.dart';
import 'package:emergency_pulse/utils/dialog.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:io';
import 'dart:async';

import 'package:http/http.dart';

class NetworkController extends GetxController {
  Socket? socket;
  Client? client;
  StreamSubscription<List<ConnectivityResult>>? subscription;
  Battery? battery;

  final status = NetworkStatus.disconnected.obs;
  final alertAddress = "192.168.254.100";
  final alertPort = 62001;
  final apiBaseUrl = "https://pulse.mavyfaby.com";
  final hasNetworkConnectivity = false.obs;

  @override
  void onInit() {
    super.onInit();
    client = Client();
    battery = Battery();
  }

  @override
  void onClose() {
    super.onClose();
    client?.close();
    socket?.close();
    client = null;
    socket = null;
    status.value = NetworkStatus.disconnected;
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  Future<void> listenConnectivity() async {
    if (subscription != null) {
      subscription!.cancel();
    }

    final connectivityResult = await Connectivity().checkConnectivity();

    hasNetworkConnectivity.value =
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile);

    subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      hasNetworkConnectivity.value =
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);

      debugPrint(
        "Network connectivity changed: ${hasNetworkConnectivity.value}",
      );
    });
  }

  Future<void> connect() async {
    if (status.value == NetworkStatus.connected || socket != null) {
      debugPrint('Already connected to server!');
      return;
    }

    try {
      status.value = NetworkStatus.connecting;

      debugPrint('Connecting to server...');

      // 1. Connect to the server
      socket = await Socket.connect(alertAddress, alertPort);

      if (socket == null) {
        status.value = NetworkStatus.disconnected;
        debugPrint('Connection failed');
        return;
      }

      status.value = NetworkStatus.connected;
      debugPrint('Connected to server!');

      // final infoCtrl = Get.find<InfoController>();

      // 2. Listen for incoming data
      socket!.listen(
        (List<int> event) {
          final message = utf8.decode(event);
          debugPrint('Server: $message');

          // if (message == "ACK") {
          //   infoCtrl.isSendingAlert.value = false;

          //   showAlertDialog(
          //     "Help is on the way!",
          //     "We’ve received your emergency alert. Stay calm and keep your phone close. Someone will reach you soon.",
          //   );

          //   return;
          // }
        },
        onError: (error) {
          status.value = NetworkStatus.disconnected;
          debugPrint('Connection failed: $error');
          socket?.close();
          socket = null;
        },
        onDone: () {
          status.value = NetworkStatus.disconnected;
          debugPrint('Connection closed');
          socket?.close();
          socket = null;
        },
      );
    } catch (e) {
      status.value = NetworkStatus.disconnected;
      debugPrint("Connection failed: $e");

      if (socket != null) {
        socket!.close();
        socket = null;
      }
    }
  }

  Future<void> sendAlert() async {
    if (socket == null) {
      // TODO: Reconnect
      debugPrint('Not connected to server!');
      return;
    }

    final infoCtrl = Get.find<InfoController>();

    try {
      infoCtrl.batteryLevel.value = (await battery!.batteryLevel).toString();

      debugPrint('Sending alert...');
      infoCtrl.isSendingAlert.value = true;

      final data = infoCtrl.getAlertData();
      final lengthBytes = ByteData(4)..setUint32(0, data.length, Endian.big);
      final header = lengthBytes.buffer.asUint8List(0, 4); // only 4 bytes

      debugPrint(
        "Sending ${header.length} bytes of header and ${data.length} bytes of data.",
      );

      socket?.add(header);
      socket?.add(data);

      await socket?.flush();

      debugPrint('Alert sent successfully!');

      infoCtrl.isSendingAlert.value = false;
      socket!.close();
      socket = null;
      status.value = NetworkStatus.disconnected;

      // Reconnect
      connect();
      showAlertDialog(
        "Alert sent",
        "We’ve shared your location and details with nearby responders — stay calm and safe.",
      );
    } catch (e) {
      debugPrint('Failed to send alert: $e');
      infoCtrl.isSendingAlert.value = false;

      showAlertDialog(
        "Failed to send alert",
        "An error occurred while sending your emergency alert.",
      );

      // TODO: ADD RETRIES
    }
  }
}
