import 'package:emergency_pulse/components/dialogs/done.dart';
import 'package:emergency_pulse/components/dialogs/image.dart';
import 'package:emergency_pulse/controllers/network.controller.dart';
import 'package:emergency_pulse/model/alert.dart';
import 'package:emergency_pulse/utils/date.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogPin extends StatelessWidget {
  final AlertModel alert;

  const DialogPin({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final networkCtrl = Get.find<NetworkController>();

    return AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(alert.name),
          Text(
            alert.imei,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
                Text(
                  alert.contactNo,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(letterSpacing: 0),
                ),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  alert.address,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(letterSpacing: 0),
                ),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.date_range_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  toHumanDate(alert.createdAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(letterSpacing: 0),
                ),
              ],
            ),

            SizedBox(height: 8),

            TextField(
              readOnly: true,
              controller: TextEditingController(text: alert.notes),
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(filled: true, labelText: "Notes"),
            ),

            if (alert.doneAt != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => DialogImage(
                        imageUrl:
                            "${networkCtrl.apiBaseUrl}/api/alerts/${alert.hashId}/done-image",
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Text("Done at ${toHumanDate(alert.doneAt!)}"),
                  ),
                ),
              ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        FilledButton.icon(
          onPressed: alert.doneAt != null
              ? null
              : () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => DialogDone(alert: alert),
                  );
                },
          icon: const Icon(Icons.check),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: const Text("Mark as done"),
          ),
        ),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
