import 'package:emergency_pulse/components/slide_to_confirm.dart';
import 'package:emergency_pulse/controllers/network.controller.dart';
import 'package:emergency_pulse/controllers/responder.controller.dart';
import 'package:emergency_pulse/model/alert.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RespondConfirmationDialog extends StatelessWidget {
  final AlertModel alert;

  const RespondConfirmationDialog({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final networkCtrl = Get.find<NetworkController>();
    final responderCtrl = Get.find<ResponderController>();

    return AlertDialog(
      title: const Text("Resolve Alert?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Mark this alert as resolved? Your device details will be recorded for audit purposes.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Note: This action can work even without an active internet connection. You just need your mobile data to be turned on.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0,
            ),
          ),

          const SizedBox(height: 16),

          SlideToConfirm(
            onConfirmed: () {
              networkCtrl.resolve(alert);
              responderCtrl.fetchAlerts();
            },
            onClose: () {},
          ),
        ],
      ),
    );
  }
}
