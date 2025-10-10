import 'package:emergency_pulse/components/dialogs/pin.dart';
import 'package:emergency_pulse/controllers/location.controller.dart';
import 'package:emergency_pulse/model/alert.dart';
import 'package:emergency_pulse/utils/date.dart';
import 'package:emergency_pulse/utils/dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CardAlert extends StatelessWidget {
  final AlertModel alert;

  const CardAlert({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final locationCtrl = Get.find<LocationController>();

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      elevation: 0,
      margin: const EdgeInsets.only(top: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectableText(
                  alert.name.isEmpty ? "Unknown" : alert.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: "Highlight on map",
                  icon: const Icon(Icons.my_location_outlined),
                  onPressed: () {
                    locationCtrl.mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(
                          double.parse(alert.lat),
                          double.parse(alert.lng),
                        ),
                        18,
                      ),
                    );
                  },
                ),
              ],
            ),

            // Row(
            //   spacing: 8,
            //   children: [
            //     Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
            //     SelectableText(
            //       alert.contactNo,
            //       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            //         letterSpacing: 0,
            //         color: Theme.of(context).colorScheme.onSurface,
            //       ),
            //     ),
            //   ],
            // ),
            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.location_on,
                  color: alert.address.isNotEmpty
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                if (alert.address.isNotEmpty)
                  SelectableText(
                    alert.address,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      letterSpacing: 0,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )
                else
                  Text(
                    "Address not provided",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      letterSpacing: 0,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
            // Row(
            //   spacing: 8,
            //   children: [
            //     Icon(
            //       Icons.date_range_outlined,
            //       color: Theme.of(context).colorScheme.primary,
            //     ),
            //     SelectableText(
            //       toHumanDate(alert.createdAt),
            //       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            //         letterSpacing: 0,
            //         color: Theme.of(context).colorScheme.onSurface,
            //       ),
            //     ),
            //   ],
            // ),
            // Row(
            //   spacing: 8,
            //   children: [
            //     Icon(
            //       Icons.map_outlined,
            //       color: Theme.of(context).colorScheme.primary,
            //     ),
            //     SelectableText(
            //       "${alert.lat}, ${alert.lng}",
            //       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            //         letterSpacing: 0,
            //         color: Theme.of(context).colorScheme.onSurface,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final googleMapsUrl = Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=${alert.lat},${alert.lng}&travelmode=driving',
                    );

                    if (await canLaunchUrl(googleMapsUrl)) {
                      await launchUrl(googleMapsUrl);
                    } else {
                      showAlertDialog("Error", "Could not open Google Maps.");
                    }
                  },
                  icon: const Icon(Icons.directions_outlined),
                  label: const Text("Directions"),
                ),

                const SizedBox(width: 8),

                FilledButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => DialogPin(alert: alert),
                    );
                  },
                  child: const Text("View Pin"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
