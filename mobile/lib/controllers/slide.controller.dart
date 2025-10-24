import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlideConfirmController extends GetxController {
  final confirmed = false.obs;
  final expanding = false.obs;

  Future<void> confirm(VoidCallback onClose) async {
    confirmed.value = true;
    update();
    await Future.delayed(const Duration(milliseconds: 150));
    expanding.value = true;
    update();
    await Future.delayed(const Duration(seconds: 1));
    reset();
    onClose();
  }

  void reset() {
    confirmed.value = false;
    expanding.value = false;
    update();
  }
}
