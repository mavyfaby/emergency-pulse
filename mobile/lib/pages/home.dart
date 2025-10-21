import 'package:emergency_pulse/components/dialogs/about.dart';
import 'package:emergency_pulse/controllers/info.controller.dart';
import 'package:emergency_pulse/controllers/network.controller.dart';
import 'package:emergency_pulse/controllers/settings.controller.dart';
import 'package:emergency_pulse/pages/alerts.dart';
import 'package:emergency_pulse/pages/map.dart';
import 'package:emergency_pulse/views/alerts_sheet.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> with WidgetsBindingObserver {
  final selectedIndex = 0.obs;
  final infoCtrl = Get.find<InfoController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final networkCtrl = Get.find<NetworkController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      networkCtrl.connect();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      final permission = await Geolocator.checkPermission();
      infoCtrl.isLocationPermissionGranted.value =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (infoCtrl.isLocationPermissionGranted.value) {
        infoCtrl.load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final infoCtrl = Get.find<InfoController>();
    final settingsCtrl = Get.find<SettingsController>();
    final pageCtrl = PageController();

    return Scaffold(
      key: settingsCtrl.mainScaffoldKey,
      appBar: AppBar(
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selectedIndex.value == 0
                ? [
                    const Text('Alerts'),
                    Text(
                      infoCtrl.imei.value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ]
                : [
                    const Text('Map'),
                    Text(
                      "Needs internet connection",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: "About app",
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(context: context, builder: (context) => DialogAbout());
            },
          ),
          Obx(
            () => Switch(
              value: settingsCtrl.isDarkMode.value,
              thumbIcon: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Icon(Icons.dark_mode);
                }

                return const Icon(Icons.light_mode);
              }),
              onChanged: (value) {
                settingsCtrl.setDarkMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: PageView(
        controller: pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [PageAlerts(), PageMap()],
        onPageChanged: (index) {
          selectedIndex.value = index;
        },
      ),

      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(
        () => selectedIndex.value == 0
            ? SizedBox()
            : FloatingActionButton(
                onPressed: () {
                  if (settingsCtrl.isTabOpen.value) {
                    settingsCtrl.isTabOpen.value = false;
                    settingsCtrl.bottomSheetCtrl?.close();
                    return;
                  }

                  settingsCtrl.bottomSheetCtrl = settingsCtrl
                      .mainScaffoldKey
                      .currentState!
                      .showBottomSheet(
                        (context) {
                          return SheetAlerts(
                            tabController: settingsCtrl.tabController!,
                          );
                        },
                        enableDrag: true,
                        showDragHandle: true,
                      );

                  settingsCtrl.isTabOpen.value = true;
                  settingsCtrl.bottomSheetCtrl?.closed.then((_) {
                    settingsCtrl.isTabOpen.value = false;
                  });
                },
                child: Icon(
                  settingsCtrl.isTabOpen.value
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                ),
              ),
      ),

      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: selectedIndex.value,
          backgroundColor: Theme.of(context).colorScheme.surface,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.warning_amber_outlined),
              selectedIcon: const Icon(Icons.warning_amber),
              label: 'Send Alerts',
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map),
              label: 'Map',
            ),
          ],
          onDestinationSelected: (index) {
            if (index == 0) {
              settingsCtrl.bottomSheetCtrl?.close();
              settingsCtrl.isTabOpen.value = false;
            } else if (index == 1) {
              infoCtrl.checkLocationPermission();
            }

            selectedIndex.value = index;
            pageCtrl.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }
}
