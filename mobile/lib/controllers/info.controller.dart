import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:emergency_pulse/utils/dialog.dart';

import 'package:cbor/cbor.dart';
import 'package:emergency_pulse/utils/security.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InfoController extends GetxController {
  final deviceModel = "".obs;
  final deviceBrand = "".obs;
  final deviceVersion = "".obs;
  final deviceName = "".obs;
  final imei = "".obs;
  final name = "".obs;
  final contactNo = "".obs;
  final address = "".obs;
  final lat = "".obs;
  final lng = "".obs;
  final notes = "".obs;
  final isLocationListening = false.obs;
  final isLocationServiceEnabled = false.obs;
  final isLocationPermissionGranted = false.obs;
  final isSendingAlert = false.obs;

  StreamSubscription<ServiceStatus>? serviceStatusStream;

  void listenToLocationService() {
    serviceStatusStream = Geolocator.getServiceStatusStream().listen((status) {
      isLocationServiceEnabled.value = status == ServiceStatus.enabled;
    });
  }

  Future<bool> checkLocationService() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    isLocationServiceEnabled.value = isEnabled;

    if (!isEnabled) {
      await showAlertDialog(
        "Location Services Off",
        "Enable your location to help responders locate you accurately when you send an alert.",
        confirmLabel: "Go to settings",
        confirmAction: () {},
      );

      Geolocator.openLocationSettings();
    }

    return isEnabled;
  }

  Future<void> requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();

      if (result == LocationPermission.denied) {
        await showAlertDialog(
          "Location Permission Required",
          "We use your location only to help responders find you faster in case of an emergency.",
          confirmLabel: "Request Permission",
          confirmAction: () {},
        );

        await Geolocator.requestPermission();
      } else if (result == LocationPermission.deniedForever) {
        await showAlertDialog(
          "Location Permission Required",
          "We use your location only to help responders find you faster in case of an emergency.",
          confirmLabel: "Go to settings",
          confirmAction: () {},
        );

        await Geolocator.openAppSettings();
      }

      return;
    }

    isLocationPermissionGranted.value = true;
    listenLocationUpdates();
  }

  Future<void> listenLocationUpdates() async {
    if (isLocationListening.value) {
      return;
    }

    final info = Hive.box("info");

    await Geolocator.getCurrentPosition().then((position) {
      lat.value = position.latitude.toString();
      lng.value = position.longitude.toString();

      info.put("lat", lat.value);
      info.put("lng", lng.value);

      isLocationListening.value = true;
    });

    Geolocator.getPositionStream().listen((position) {
      lat.value = position.latitude.toString();
      lng.value = position.longitude.toString();

      info.put("lat", lat.value);
      info.put("lng", lng.value);

      isLocationListening.value = true;
    });
  }

  Future<void> checkLocationPermission() async {
    final isEnabled = await checkLocationService();

    if (isEnabled) {
      await requestLocationPermission();
    }
  }

  Future<void> save(
    String name,
    String address,
    String contactNo,
    String notes,
  ) async {
    final info = Hive.box("info");

    info.put("name", sanitize(name));
    info.put("address", sanitize(address));
    info.put("contactNo", sanitize(contactNo));
    info.put("notes", sanitize(notes));

    load();
  }

  Future<void> load() async {
    final infoCtrl = Get.find<InfoController>();
    final info = Hive.box("info");

    await infoCtrl.checkLocationPermission();
    await infoCtrl.listenLocationUpdates();

    if (imei.value.isEmpty) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;

      info.put("imei", await FlutterDeviceImei.instance.getIMEI());
      info.put("device_model", deviceInfo.model);
      info.put("device_brand", deviceInfo.brand);
      info.put("device_version", deviceInfo.version.release);
      info.put("device_name", deviceInfo.name);
    }

    name.value = info.get("name") ?? "";
    address.value = info.get("address") ?? "";
    contactNo.value = info.get("contactNo") ?? "";
    lat.value = info.get("lat") ?? "";
    lng.value = info.get("lng") ?? "";
    notes.value = info.get("notes") ?? "";

    imei.value = info.get("imei") ?? "";
    deviceModel.value = info.get("device_model") ?? "";
    deviceBrand.value = info.get("device_brand") ?? "";
    deviceVersion.value = info.get("device_version") ?? "";
    deviceName.value = info.get("device_name") ?? "";
  }

  List<int> getAlertData() {
    return cbor.encode(
      CborMap({
        CborString("imei"): CborString(imei.value),
        CborString("name"): CborString(name.value),
        CborString("address"): CborString(address.value),
        CborString("contactNo"): CborString(contactNo.value),
        CborString("lat"): CborString(lat.value),
        CborString("lng"): CborString(lng.value),
        CborString("device_model"): CborString(deviceModel.value),
        CborString("device_brand"): CborString(deviceBrand.value),
        CborString("device_version"): CborString(deviceVersion.value),
        CborString("device_name"): CborString(deviceName.value),
        CborString("notes"): CborString(notes.value),
      }),
    );
  }
}
