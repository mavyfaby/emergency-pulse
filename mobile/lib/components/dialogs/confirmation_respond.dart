import 'package:emergency_pulse/controllers/network.controller.dart';
import 'package:emergency_pulse/model/alert.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RespondConfirmationDialog extends StatelessWidget {
  final AlertModel alert;

  const RespondConfirmationDialog({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final networkCtrl = Get.find<NetworkController>();
    final isAgree = false.obs;

    return AlertDialog(
      title: const Text("Respond to Alert?"),
      content: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "You’re about to respond to this emergency. Proceed only if you’re able to assist and take responsibility for the response.",
          ),

          Obx(
            () => CheckboxListTile(
              value: isAgree.value,

              onChanged: (value) => isAgree.value = value ?? false,
              title: Text(
                'I understand and accept responsibility for responding.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(letterSpacing: 0),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        Obx(
          () => TextButton(
            onPressed: !isAgree.value
                ? null
                : () {
                    networkCtrl.respond(alert);
                    Navigator.pop(context);
                  },
            child: const Text("Respond"),
          ),
        ),
      ],
    );
  }
}
