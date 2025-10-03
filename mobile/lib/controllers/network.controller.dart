import 'dart:typed_data';

import 'package:emergency_pulse/controllers/info.controller.dart';
import 'package:emergency_pulse/enums/status.dart';
import 'package:emergency_pulse/utils/dialog.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart';

class NetworkController extends GetxController {
  Socket? socket;
  Client? client;

  final status = NetworkStatus.disconnected.obs;
  final ipAddress = "192.168.254.100";
  final apiPort = 62000;
  final tcpPort = 62001;

  @override
  void onInit() {
    super.onInit();
    client = Client();
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

  Future<void> connect() async {
    if (status.value == NetworkStatus.connected || socket != null) {
      debugPrint('Already connected to server!');
      return;
    }

    try {
      status.value = NetworkStatus.connecting;

      debugPrint('Connecting to server...');

      // 1. Connect to the server
      socket = await Socket.connect(ipAddress, tcpPort);

      if (socket == null) {
        status.value = NetworkStatus.disconnected;
        showSnackbar("Connection failed");
        debugPrint('Connection failed');
        return;
      }

      status.value = NetworkStatus.connected;
      debugPrint('Connected to server!');

      final infoCtrl = Get.find<InfoController>();

      // 2. Listen for incoming data
      socket!.listen(
        (List<int> event) {
          final message = utf8.decode(event);
          debugPrint('Server: $message');

          if (message == "ACK") {
            infoCtrl.isSendingAlert.value = false;
          }
        },
        onError: (error) {
          status.value = NetworkStatus.disconnected;
          debugPrint('Connection failed: $error');
          showSnackbar("Connection failed");
          socket!.close();
          socket = null;
        },
        onDone: () {
          status.value = NetworkStatus.disconnected;
          debugPrint('Connection closed');
          socket!.close();
          socket = null;
        },
      );
    } catch (e) {
      status.value = NetworkStatus.disconnected;
      debugPrint("Connection failed: $e");
      showSnackbar("Connection failed");

      if (socket != null) {
        socket!.close();
        socket = null;
      }
    }
  }

  Future<void> sendAlert() async {
    if (socket == null) {
      debugPrint('Not connected to server!');
      return;
    }

    try {
      debugPrint('Sending alert...');

      final infoCtrl = Get.find<InfoController>();
      final data = infoCtrl.getAlertData();

      // Prefix with 4-byte length header (big en dian)
      final lengthBytes = ByteData(4)..setUint32(0, data.length, Endian.big);
      final message = Uint8List.fromList(
        lengthBytes.buffer.asUint8List() + data,
      );

      socket!.add(message);
    } catch (e) {
      debugPrint('Failed to send alert: $e');
    }
  }
}
