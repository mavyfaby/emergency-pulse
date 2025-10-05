import 'package:emergency_pulse/components/card_alert.dart';
import 'package:emergency_pulse/controllers/location.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SheetAlerts extends StatelessWidget {
  final TabController tabController;

  const SheetAlerts({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final locationCtrl = Get.find<LocationController>();

    return SizedBox(
      height: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => FilledButton.tonal(
                    onPressed: locationCtrl.isRefreshing.value
                        ? null
                        : () {
                            locationCtrl.refreshKey.currentState?.show();
                          },
                    child: Text(
                      locationCtrl.isRefreshing.value
                          ? "Refreshing..."
                          : "Refresh Alerts",
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Obx(
            () => TabBar(
              controller: tabController,
              tabs: [
                Badge.count(
                  count: locationCtrl.alerts
                      .where((alert) => alert.doneAt == null)
                      .length,
                  child: Tab(
                    text: "Pending",
                    icon: Icon(Icons.warning_amber_outlined),
                    height: 56,
                  ),
                ),
                Badge.count(
                  count: locationCtrl.alerts
                      .where((alert) => alert.doneAt != null)
                      .length,
                  child: Tab(
                    text: "Done",
                    icon: Icon(Icons.checklist_outlined),
                    height: 56,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount: locationCtrl.alerts
                      .where((alert) => alert.doneAt == null)
                      .length,
                  itemBuilder: (context, index) {
                    return CardAlert(
                      alert: locationCtrl.alerts
                          .where((alert) => alert.doneAt == null)
                          .elementAt(index),
                    );
                  },
                ),
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount: locationCtrl.alerts
                      .where((alert) => alert.doneAt != null)
                      .length,
                  itemBuilder: (context, index) {
                    return CardAlert(
                      alert: locationCtrl.alerts
                          .where((alert) => alert.doneAt != null)
                          .elementAt(index),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
