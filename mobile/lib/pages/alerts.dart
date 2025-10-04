import 'package:emergency_pulse/components/dialogs/info.dart';
import 'package:emergency_pulse/controllers/info.controller.dart';
import 'package:emergency_pulse/controllers/network.controller.dart';
import 'package:emergency_pulse/enums/status.dart';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageAlerts extends StatelessWidget {
  const PageAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    final infoCtrl = Get.find<InfoController>();
    final networkCtrl = Get.find<NetworkController>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
        child: Center(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (infoCtrl.hasInfoFilled())
                  Column(
                    children: [
                      IntrinsicHeight(
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              spacing: 6,
                              children: [
                                Text(
                                  infoCtrl.lat.value.isEmpty
                                      ? "-"
                                      : infoCtrl.lat.value,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  "Latitude",
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                            VerticalDivider(
                              thickness: 2,
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                            Column(
                              spacing: 6,
                              children: [
                                Text(
                                  infoCtrl.lng.value.isEmpty
                                      ? "-"
                                      : infoCtrl.lng.value,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  "Longitude",
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      Text(
                        infoCtrl.name.value,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        infoCtrl.contactNo.value,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        infoCtrl.address.value,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),

                SizedBox(height: 32),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    AvatarGlow(
                      glowColor: getStatusColor(),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: getStatusColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Text(
                      getStatusText(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: getStatusColor(),
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32),

                PressableDough(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: AvatarGlow(
                      animate:
                          infoCtrl.hasInfoFilled() &&
                          infoCtrl.isLocationListening.value &&
                          networkCtrl.status.value == NetworkStatus.connected &&
                          !infoCtrl.isSendingAlert.value,
                      glowColor: Theme.of(context).colorScheme.primary,
                      child: FilledButton(
                        onPressed:
                            infoCtrl.hasInfoFilled() &&
                                infoCtrl.isLocationListening.value &&
                                networkCtrl.status.value ==
                                    NetworkStatus.connected &&
                                !infoCtrl.isSendingAlert.value
                            ? () {
                                infoCtrl.isSendingAlert.value = true;
                                infoCtrl.checkLocationPermission();
                                networkCtrl.sendAlert();
                              }
                            : null,
                        child: Text(
                          infoCtrl.isSendingAlert.value
                              ? "Sending..."
                              : "Send Alert",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (!infoCtrl.hasInfoFilled())
                  Column(
                    children: [
                      SizedBox(height: 100),
                      Text(
                        "Fill in your information to send an alert!",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return DialogInfo();
                            },
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 20,
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 24),
                        label: Text(
                          'Add Information',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  )
                else
                  Column(
                    children: [
                      SizedBox(height: 50),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit, size: 24),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return DialogInfo(isUpdate: true);
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                        ),
                        label: Text(
                          "Update Information",
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color getStatusColor() {
    final networkCtrl = Get.find<NetworkController>();

    switch (networkCtrl.status.value) {
      case NetworkStatus.connected:
        return Colors.green;
      case NetworkStatus.connecting:
        return Colors.orange;
      case NetworkStatus.disconnecting:
        return Colors.yellow;
      case NetworkStatus.disconnected:
        return Colors.red;
    }
  }

  String getStatusText() {
    final networkCtrl = Get.find<NetworkController>();

    switch (networkCtrl.status.value) {
      case NetworkStatus.connected:
        return "Connected";
      case NetworkStatus.connecting:
        return "Connecting";
      case NetworkStatus.disconnecting:
        return "Disconnecting";
      case NetworkStatus.disconnected:
        return "Disconnected";
    }
  }
}
