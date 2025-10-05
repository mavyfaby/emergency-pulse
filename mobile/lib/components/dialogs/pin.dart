import 'package:emergency_pulse/components/dialogs/done.dart';
import 'package:emergency_pulse/components/dialogs/image.dart';
import 'package:emergency_pulse/model/alert.dart';
import 'package:emergency_pulse/network/request.dart';
import 'package:emergency_pulse/utils/date.dart';
import 'package:flutter/material.dart';

class DialogPin extends StatelessWidget {
  final AlertModel alert;

  const DialogPin({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(alert.name),
          Text(
            alert.uuid,
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

            if (alert.doneAt == null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
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
              ),

            if (alert.doneAt != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => DialogImage(
                        imageUrl:
                            "${getBaseURL()}/api/alerts/${alert.hashId}/done-image",
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
        // if (alert.hasImage)
        //   FilledButton.tonalIcon(
        //     onPressed: () {
        //       showDialog(
        //         context: context,
        //         builder: (context) => DialogImage(
        //           imageUrl: "${getBaseURL()}/api/alerts/${alert.hashId}/image",
        //         ),
        //       );
        //     },
        //     icon: const Icon(Icons.image_outlined),
        //     label: const Text("View Image"),
        //   )
        // else
        //   const SizedBox.shrink(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
