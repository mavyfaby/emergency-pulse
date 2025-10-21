import 'package:emergency_pulse/controllers/responder.controller.dart';
import 'package:emergency_pulse/controllers/settings.controller.dart';
import 'package:emergency_pulse/utils/dialog.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SheetAlerts extends StatelessWidget {
  final TabController tabController;

  const SheetAlerts({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final responderCtrl = Get.find<ResponderController>();

    return SizedBox(
      height: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => DropdownMenu<int>(
                    initialSelection: settingsCtrl.selectedRadius.value,
                    label: const Text("Alert Range Radius"),
                    inputDecorationTheme: const InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    dropdownMenuEntries:
                        <int>[
                          1000,
                          3000,
                          5000,
                          10000,
                          50000,
                          100000,
                        ].map<DropdownMenuEntry<int>>((int value) {
                          return DropdownMenuEntry<int>(
                            value: value,
                            label: "${(value / 1000).toInt()} km",
                          );
                        }).toList(),
                    onSelected: (int? newValue) {
                      if (newValue != null) {
                        settingsCtrl.setSelectedRadius(newValue);
                      } else {
                        showAlertDialog(
                          "Error",
                          "Failed to set radius! Please try again.",
                        );
                      }
                    },
                  ),
                ),
                Obx(
                  () => FilledButton.tonal(
                    onPressed: responderCtrl.isFetchingAlerts.value
                        ? null
                        : () {
                            responderCtrl.fetchAlerts();
                          },
                    child: responderCtrl.isFetchingAlerts.value
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: const CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          )
                        : const Text("Refresh Alerts"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Obx(
          //   () => TabBar(
          //     controller: tabController,
          //     tabs: [
          //       Badge.count(
          //         count: responderCtrl.alerts
          //             .where((alert) => alert.doneAt == null)
          //             .length,
          //         child: Tab(
          //           text: "Pending",
          //           icon: Icon(Icons.warning_amber_outlined),
          //           height: 56,
          //         ),
          //       ),
          //       Badge.count(
          //         count: responderCtrl.alerts
          //             .where((alert) => alert.doneAt != null)
          //             .length,
          //         child: Tab(
          //           text: "Done",
          //           icon: Icon(Icons.checklist_outlined),
          //           height: 56,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Expanded(
          //   child: TabBarView(
          //     controller: tabController,
          //     children: [
          //       Obx(
          //         () => ListView.builder(
          //           padding: const EdgeInsets.symmetric(horizontal: 12.0),
          //           itemCount: responderCtrl.alerts
          //               .where((alert) => alert.doneAt == null)
          //               .length,
          //           itemBuilder: (context, index) {
          //             return CardAlert(
          //               alert: responderCtrl.alerts
          //                   .where((alert) => alert.doneAt == null)
          //                   .elementAt(index),
          //             );
          //           },
          //         ),
          //       ),
          //       Obx(
          //         () => ListView.builder(
          //           padding: const EdgeInsets.symmetric(horizontal: 12.0),
          //           itemCount: responderCtrl.alerts
          //               .where((alert) => alert.doneAt != null)
          //               .length,
          //           itemBuilder: (context, index) {
          //             return CardAlert(
          //               alert: responderCtrl.alerts
          //                   .where((alert) => alert.doneAt != null)
          //                   .elementAt(index),
          //             );
          //           },
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
