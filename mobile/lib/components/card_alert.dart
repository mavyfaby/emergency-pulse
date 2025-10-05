import 'package:emergency_pulse/controllers/location.controller.dart';
import 'package:emergency_pulse/model/alert.dart';
import 'package:emergency_pulse/utils/date.dart';

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
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      margin: const EdgeInsets.only(top: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            SelectableText(
              alert.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              spacing: 8,
              children: [
                Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
                SelectableText(
                  alert.contactNo,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    letterSpacing: 0,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
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
                SelectableText(
                  alert.address,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    letterSpacing: 0,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
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
                SelectableText(
                  toHumanDate(alert.createdAt),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    letterSpacing: 0,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    locationCtrl.mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(
                          double.parse(alert.lat),
                          double.parse(alert.lng),
                        ),
                        15,
                      ),
                    );
                  },
                  child: const Text("Highlight Location"),
                ),

                const SizedBox(width: 8),

                FilledButton(
                  onPressed: () {},
                  child: const Text("View Details"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
