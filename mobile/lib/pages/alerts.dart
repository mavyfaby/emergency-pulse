import 'dart:async';

import 'package:emergency_pulse/components/banner_alert.dart';
import 'package:emergency_pulse/components/dialogs/info.dart';
import 'package:emergency_pulse/controllers/info.controller.dart';
import 'package:emergency_pulse/controllers/network.controller.dart';
import 'package:emergency_pulse/controllers/settings.controller.dart';
import 'package:emergency_pulse/enums/status.dart';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:dough/dough.dart';
import 'package:emergency_pulse/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

class PageAlerts extends StatelessWidget {
  const PageAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    final infoCtrl = Get.find<InfoController>();
    final networkCtrl = Get.find<NetworkController>();
    final settingsCtrl = Get.find<SettingsController>();
    final timeoutInSeconds = 3;
    final currentTimeout = timeoutInSeconds.obs;
    final isPressed = false.obs;
    final scale = 1.0.obs;

    Timer? timer;

    return RefreshIndicator(
      onRefresh: () async {
        await infoCtrl.load();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
          child: Center(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (infoCtrl.isLocationListening.value &&
                      infoCtrl.isLocationServiceEnabled.value &&
                      infoCtrl.isLocationPermissionGranted.value)
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
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
                        SizedBox(height: 32),
                        Text(
                          infoCtrl.name.value,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),

                  if (!networkCtrl.hasNetworkConnectivity.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: BannerAlert(
                        message:
                            "Keep mobile data on — no internet needed. \n Pull to refresh.",
                      ),
                    ),

                  if (!infoCtrl.isLocationServiceEnabled.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: BannerAlert(
                        message:
                            "Location is off — enable it to send your alert. \n Pull to refresh.",
                      ),
                    ),

                  if (!infoCtrl.isLocationPermissionGranted.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: BannerAlert(
                        message:
                            "Location permission is required to send alerts. \n Pull to refresh.",
                      ),
                    ),

                  SizedBox(height: 12),

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
                    child: AnimatedScale(
                      scale: scale.value,
                      curve: Curves.elasticOut,
                      duration: Duration(seconds: timeoutInSeconds),
                      child: SizedBox(
                        width: 250,
                        height: 250,
                        child: AvatarGlow(
                          animate:
                              infoCtrl.isLocationPermissionGranted.value &&
                              infoCtrl.isLocationServiceEnabled.value &&
                              infoCtrl.isLocationListening.value &&
                              networkCtrl.hasNetworkConnectivity.value &&
                              networkCtrl.status.value ==
                                  NetworkStatus.connected &&
                              !infoCtrl.isSendingAlert.value,
                          glowColor: isPressed.value
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.primary,

                          child: GestureDetector(
                            onLongPressStart: (details) {
                              if (!infoCtrl.isLocationPermissionGranted.value ||
                                  !infoCtrl.isLocationServiceEnabled.value ||
                                  !infoCtrl.isLocationListening.value ||
                                  !networkCtrl.hasNetworkConnectivity.value ||
                                  networkCtrl.status.value !=
                                      NetworkStatus.connected ||
                                  infoCtrl.isSendingAlert.value) {
                                return;
                              }

                              debugPrint("Long press started");
                              isPressed.value = true;
                              scale.value = 1.2;

                              if (settingsCtrl.hasVibrator.value) {
                                Vibration.vibrate(
                                  preset: VibrationPreset.gentleReminder,
                                );
                              }

                              timer = Timer.periodic(
                                const Duration(seconds: 1),
                                (timer) {
                                  currentTimeout.value--;

                                  if (currentTimeout.value <= 0) {
                                    if (settingsCtrl.hasVibrator.value) {
                                      Vibration.vibrate(
                                        preset: VibrationPreset.emergencyAlert,
                                      );
                                    }

                                    timer.cancel();
                                    isPressed.value = false;
                                    scale.value = 1;
                                    networkCtrl.sendAlert();
                                    currentTimeout.value = timeoutInSeconds;
                                  }
                                },
                              );
                            },
                            onLongPressEnd: (details) {
                              if (!infoCtrl.isLocationPermissionGranted.value ||
                                  !infoCtrl.isLocationServiceEnabled.value ||
                                  !infoCtrl.isLocationListening.value ||
                                  !networkCtrl.hasNetworkConnectivity.value ||
                                  networkCtrl.status.value !=
                                      NetworkStatus.connected ||
                                  infoCtrl.isSendingAlert.value) {
                                return;
                              }

                              debugPrint("Long press ended");
                              isPressed.value = false;
                              timer?.cancel();
                              currentTimeout.value = timeoutInSeconds;
                              scale.value = 1;

                              if (settingsCtrl.hasVibrator.value) {
                                Vibration.vibrate(
                                  preset: VibrationPreset.gentleReminder,
                                );
                              }

                              showAlertDialog(
                                "Alert canceled",
                                "You stopped the alert. Everything's okay.",
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    infoCtrl.isSendingAlert.value ||
                                        !infoCtrl
                                            .isLocationPermissionGranted
                                            .value ||
                                        !infoCtrl
                                            .isLocationServiceEnabled
                                            .value ||
                                        !infoCtrl.isLocationListening.value ||
                                        !networkCtrl
                                            .hasNetworkConnectivity
                                            .value ||
                                        networkCtrl.status.value !=
                                            NetworkStatus.connected
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainer
                                    : isPressed.value
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              width: double.infinity,
                              height: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (infoCtrl
                                          .isLocationPermissionGranted
                                          .value &&
                                      infoCtrl.isLocationServiceEnabled.value &&
                                      infoCtrl.isLocationListening.value &&
                                      networkCtrl
                                          .hasNetworkConnectivity
                                          .value &&
                                      networkCtrl.status.value ==
                                          NetworkStatus.connected &&
                                      !infoCtrl.isSendingAlert.value)
                                    Text(
                                      isPressed.value
                                          ? "Will send alert in"
                                          : "Long press for 3 seconds to",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0,
                                            color: isPressed.value
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.surface
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                      .withAlpha(220),
                                          ),
                                    ),

                                  if (isPressed.value)
                                    Text(
                                      "${currentTimeout.value}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                          ),
                                    )
                                  else
                                    Text(
                                      infoCtrl
                                                  .isLocationPermissionGranted
                                                  .value &&
                                              infoCtrl
                                                  .isLocationServiceEnabled
                                                  .value &&
                                              infoCtrl
                                                  .isLocationListening
                                                  .value &&
                                              networkCtrl
                                                  .hasNetworkConnectivity
                                                  .value &&
                                              networkCtrl.status.value ==
                                                  NetworkStatus.connected &&
                                              !infoCtrl.isSendingAlert.value
                                          ? "Send Alert"
                                          : "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                infoCtrl
                                                        .isLocationPermissionGranted
                                                        .value &&
                                                    infoCtrl
                                                        .isLocationServiceEnabled
                                                        .value &&
                                                    infoCtrl
                                                        .isLocationListening
                                                        .value &&
                                                    networkCtrl
                                                        .hasNetworkConnectivity
                                                        .value &&
                                                    networkCtrl.status.value ==
                                                        NetworkStatus
                                                            .connected &&
                                                    !infoCtrl
                                                        .isSendingAlert
                                                        .value
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      SizedBox(height: 24),
                      Text(
                        "By sending an alert, you agree to share your location and details for emergency purposes.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          letterSpacing: 0,
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 32),
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
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          showSnackbar("Long press to learn more");
                        },
                        onLongPress: () {
                          launchUrl(
                            Uri.parse(
                              "https://pulse.mavyfaby.com/privacy-policy",
                            ),
                          );
                        },
                        child: Text(
                          "Learn more about how your data is used",
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
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
