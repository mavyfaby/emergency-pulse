import 'package:emergency_pulse/controllers/location.controller.dart';
import 'package:emergency_pulse/controllers/settings.controller.dart';
import 'package:emergency_pulse/network/request.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PageMap extends StatefulWidget {
  const PageMap({super.key});

  @override
  State<PageMap> createState() => _PageMapState();
}

class _PageMapState extends State<PageMap> {
  // with AutomaticKeepAliveClientMixin<PageMap> {
  String darkStyle = "";
  BitmapDescriptor? markerIcon;

  final settingsCtrl = Get.find<SettingsController>();
  final locationCtrl = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();

    // Load the dark mode style
    rootBundle.loadString("assets/map_styles/aubergine.json").then((value) {
      darkStyle = value;
    });

    locationCtrl.refreshKey.currentState?.show();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: locationCtrl.refreshKey,
      onRefresh: () async {
        final config = ImageConfiguration(size: const Size(35, 45));

        markerIcon ??= await BitmapDescriptor.asset(
          config,
          "assets/marker.png",
        );

        locationCtrl.isRefreshing.value = true;
        await fetchAlerts();
        locationCtrl.isRefreshing.value = false;
      },
      child: Obx(
        () => Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              style: settingsCtrl.isDarkMode.value ? darkStyle : null,
              myLocationEnabled: true,
              buildingsEnabled: true,
              compassEnabled: false,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              fortyFiveDegreeImageryEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(10.3157, 123.8854),
                zoom: 10,
              ),
              onMapCreated: (controller) {
                locationCtrl.mapController.complete(controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // bool get wantKeepAlive => true;
}
