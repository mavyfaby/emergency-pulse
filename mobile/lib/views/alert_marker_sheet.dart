import 'package:emergency_pulse/model/alert.dart';
import 'package:emergency_pulse/model/alert_type.dart';
import 'package:emergency_pulse/utils/date.dart';
import 'package:emergency_pulse/utils/dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertMarkerSheet extends StatelessWidget {
  final AlertModel alert;

  const AlertMarkerSheet({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.2,
      maxChildSize: 1,
      expand: false,
      builder: (context, scrollController) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    alert.alertType.icon,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "${alert.alertType.longName.toUpperCase()} ALERT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            SelectableText(
              alert.name.isEmpty ? 'Unknown' : alert.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 2),

            SelectableText(
              alert.imei,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),

                SelectableText(toHumanDate(alert.createdAt, showSeconds: true)),
              ],
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: () async {
                if (alert.contactNo.isEmpty) return;

                try {
                  await launchUrl(Uri.parse("tel:${alert.contactNo}"));
                } catch (e) {
                  await Clipboard.setData(ClipboardData(text: alert.contactNo));
                  showSnackbar(
                    "Couldn't open phone app! Instead we copied the contact number to clipboard.",
                  );
                }
              },
              child: Row(
                spacing: 8,
                children: [
                  Icon(
                    Icons.phone,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  if (alert.contactNo.isNotEmpty)
                    SelectableText(alert.contactNo)
                  else
                    Text(
                      "No contact number provided",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.home_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),

                if (alert.address.isNotEmpty)
                  SelectableText(alert.address)
                else
                  Text(
                    "No address provided",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.location_on,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),

                Expanded(
                  child: SelectableText(
                    "${alert.lat}, ${alert.lng} (±${alert.accuracyMeters}m accuracy)",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.social_distance_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),

                Text(
                  "${((double.tryParse(alert.distance) ?? 0) / 1000).toStringAsFixed(2)} km (straight line)",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (alert.notes.isNotEmpty)
                    Text(alert.notes)
                  else
                    Text(
                      "No notes provided",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final googleMapsUrl = Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=${alert.lat},${alert.lng}&travelmode=driving',
                    );

                    try {
                      await launchUrl(googleMapsUrl);
                    } catch (e) {
                      showAlertDialog("Error", "Could not open Google Maps.");
                    }
                  },
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text("Directions"),
                  ),
                  icon: Icon(Icons.directions_outlined),
                ),

                FilledButton.icon(
                  onPressed: () {},
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text("Respond"),
                  ),
                  icon: Icon(Icons.emergency_outlined),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              "Sender's Device Information",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.phone_android,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),

                SelectableText("Device Name: ${alert.deviceName}"),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.precision_manufacturing,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),

                SelectableText("Brand: ${alert.deviceBrand}"),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.build,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),

                SelectableText("Model: ${alert.deviceModel}"),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.memory,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),

                SelectableText("Version: ${alert.deviceVersion}"),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.battery_charging_full,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),

                SelectableText(
                  "Battery Level: ${alert.deviceBatteryLevel}% as of the time of this alert.",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
