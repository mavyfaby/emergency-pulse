import 'package:emergency_pulse/utils/dialog.dart';

import 'package:cbor/cbor.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InfoController extends GetxController {
  final imei = "".obs;
  final name = "".obs;
  final contactNo = "".obs;
  final address = "".obs;
  final lat = "".obs;
  final lng = "".obs;
  final notes = "".obs;
  // final picture = Uint8List.fromList([]).obs;
  // final isPictureAlreadyCompressed = false.obs;
  final isLocationListening = false.obs;
  final isSendingAlert = false.obs;

  bool hasInfoFilled() {
    return name.value.isNotEmpty &&
        address.value.isNotEmpty &&
        contactNo.value.isNotEmpty;
    // picture.value.isNotEmpty;
  }

  Future<bool> isLocationServiceEnabled() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isEnabled) {
      showAlertDialog(
        "Location Service Disabled",
        "Please enable location service to use this feature.",
      );
    }

    return isEnabled;
  }

  Future<void> requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();

      if (result == LocationPermission.denied ||
          result == LocationPermission.deniedForever) {
        showAlertDialog(
          "Location Permission Denied",
          "Please grant location permission to use this feature.",
        );
      }

      if (result == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }
    }
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
    final isEnabled = await isLocationServiceEnabled();

    if (isEnabled) {
      await requestLocationPermission();
    }
  }

  Future<void> save(
    String name,
    String address,
    String contactNo,
    String notes,
    // File? picture,
  ) async {
    final info = Hive.box("info");

    if (imei.value.isEmpty) {
      info.put("imei", await FlutterDeviceImei.instance.getIMEI());
    }

    info.put("name", name.trim());
    info.put("address", address.trim());
    info.put("contactNo", contactNo.trim());
    info.put("notes", notes.trim());

    // if (picture != null) {
    //   if (!isPictureAlreadyCompressed.value) {
    //     debugPrint("Compressing picture...");

    //     final bytes = await FlutterImageCompress.compressWithList(
    //       await picture.readAsBytes(),
    //       quality: 5,
    //     );

    //     debugPrint("Picture compressed!");

    //     isPictureAlreadyCompressed.value = true;
    //     info.put("isPictureAlreadyCompressed", true);
    //     info.put("picture", bytes);
    //     return;
    //   }

    //   debugPrint("Picture already compressed!");
    //   info.put("picture", await picture.readAsBytes());
    // } else {
    //   info.delete("picture");
    //   info.delete("isPictureAlreadyCompressed");
    // }

    load();
  }

  void load() {
    final info = Hive.box("info");
    Get.find<InfoController>().listenLocationUpdates();

    imei.value = info.get("imei") ?? "";
    name.value = info.get("name") ?? "";
    address.value = info.get("address") ?? "";
    contactNo.value = info.get("contactNo") ?? "";
    lat.value = info.get("lat") ?? "";
    lng.value = info.get("lng") ?? "";
    notes.value = info.get("notes") ?? "";

    // picture.value = info.get("picture") ?? Uint8List.fromList([]);
    // isPictureAlreadyCompressed.value =
    //     info.get("isPictureAlreadyCompressed") ?? false;
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
        CborString("notes"): CborString(notes.value),
        // CborString("picture"): CborBytes(picture.value),
      }),
    );
  }
}
