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
  final ipAddress = "13.250.43.190";
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

    final infoCtrl = Get.find<InfoController>();

    try {
      debugPrint('Sending alert...');
      infoCtrl.isSendingAlert.value = true;

      final data = infoCtrl.getAlertData();

      // final lengthBytes = ByteData(4)..setUint32(0, data.length, Endian.big);
      // final message = Uint8List.fromList(
      //   lengthBytes.buffer.asUint8List() + data,
      // );

      // const chunkSize = 4096; // 4KB per chunk
      // final totalChunks = (data.length / chunkSize).ceil();

      final lengthBytes = ByteData(4)..setUint32(0, data.length, Endian.big);
      final header = lengthBytes.buffer.asUint8List(0, 4); // only 4 bytes

      // debugPrint('Total data: ${data.length} bytes, $totalChunks chunks');

      debugPrint(
        "Sending ${header.length} bytes of header and ${data.length} bytes of data.",
      );

      socket!.add(header);
      socket!.add(data);

      await socket!.flush();

      debugPrint('Alert sent successfully!');

      infoCtrl.isSendingAlert.value = false;
      socket!.close();
      socket = null;
      status.value = NetworkStatus.disconnected;

      // Reconnect
      connect();
      showAlertDialog(
        "Help is on the way!",
        "We’ve received your emergency alert. Stay calm and keep your phone close. Someone will reach you soon.",
      );

      // // Add a timeout of 10 seconds
      // await Future.delayed(const Duration(seconds: 10));

      // // If alert is still sending, show alert
      // if (infoCtrl.isSendingAlert.value) {
      //   infoCtrl.isSendingAlert.value = false;

      //   showAlertDialog(
      //     "Failed to send alert",
      //     "We were unable to send your emergency alert. Please try again later.",
      //   );
      // }
    } catch (e) {
      debugPrint('Failed to send alert: $e');
      infoCtrl.isSendingAlert.value = false;

      showAlertDialog(
        "Failed to send alert",
        "An error occurred while sending your emergency alert. Please try again later.",
      );
    }
  }

  Future<void> testTcpLimit() async {
    final socket = await Socket.connect(
      ipAddress,
      tcpPort,
      timeout: Duration(seconds: 5),
    );
    debugPrint(
      'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}',
    );

    int chunkSize = 1024; // start with 1 KB
    final rand = List<int>.filled(chunkSize, 65); // just 'A's

    while (chunkSize <= 1024 * 1024) {
      // up to 1MB test
      try {
        socket.add(rand);
        await socket.flush();

        socket.write('\n'); // signal end of chunk
        await socket.flush();

        socket.timeout(Duration(seconds: 3)); // wait for response

        debugPrint('Sent $chunkSize bytes successfully');
        chunkSize *= 2;
      } catch (e) {
        debugPrint('❌ Failed at ~${chunkSize ~/ 2} bytes');
        break;
      }
    }

    socket.destroy();
  }
}
