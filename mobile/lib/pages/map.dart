import 'package:emergency_pulse/controllers/settings.controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class PageMap extends StatefulWidget {
  const PageMap({super.key});

  @override
  State<PageMap> createState() => _PageMapState();
}

class _PageMapState extends State<PageMap> with TickerProviderStateMixin {
  final httpClient = RetryClient(Client());
  final settingsCtrl = Get.find<SettingsController>();

  @override
  void initState() {
    super.initState();

    settingsCtrl.tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: MapController(),
      options: MapOptions(
        initialCenter: const LatLng(10.3157, 123.8854),
        initialZoom: 10,
        minZoom: 2,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: "com.mavyfaby.pulse",
          tileProvider: NetworkTileProvider(
            httpClient: httpClient,
            cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(
              maxCacheSize: 1_000_000_000, // 1GB
            ),
          ),
        ),
        RichAttributionWidget(
          alignment: AttributionAlignment.bottomLeft,
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () =>
                  launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    );
  }
}
