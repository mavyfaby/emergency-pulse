import 'package:avatar_glow/avatar_glow.dart';
import 'package:emergency_pulse/controllers/info.controller.dart';
import 'package:emergency_pulse/controllers/responder.controller.dart';
import 'package:emergency_pulse/controllers/settings.controller.dart';
import 'package:emergency_pulse/utils/dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';

class PageMap extends StatefulWidget {
  const PageMap({super.key});

  @override
  State<PageMap> createState() => _PageMapState();
}

class _PageMapState extends State<PageMap> with TickerProviderStateMixin {
  final httpClient = RetryClient(Client());
  final settingsCtrl = Get.find<SettingsController>();
  final infoCtrl = Get.find<InfoController>();
  final responderCtrl = Get.find<ResponderController>();

  late AnimatedMapController animatedMapController;

  @override
  void initState() {
    super.initState();

    settingsCtrl.tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );

    animatedMapController = AnimatedMapController(
      vsync: this,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 500),
      cancelPreviousAnimations: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: animatedMapController.mapController,
      options: MapOptions(
        initialCenter: const LatLng(10.3157, 123.8854),
        initialZoom: 10,
        minZoom: 2,
        onMapReady: () {
          responderCtrl.setBoundsFromMapCamera(
            animatedMapController.mapController.camera,
          );

          responderCtrl.fetchAlerts();
        },
        onPointerUp: (event, point) {
          responderCtrl.setBoundsFromMapCamera(
            animatedMapController.mapController.camera,
          );
        },
      ),
      children: [
        Obx(
          () => settingsCtrl.isDarkMode.value
              ? ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    -0.2126, -0.7152, -0.0722, 0, 255, // Red channel
                    -0.2126, -0.7152, -0.0722, 0, 255, // Green channel
                    -0.2126, -0.7152, -0.0722, 0, 255, // Blue channel
                    0, 0, 0, 1, 0, // Alpha channel
                  ]),
                  child: MapTile(httpClient: httpClient),
                )
              : MapTile(httpClient: httpClient),
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

        CurrentLocationLayer(
          style: LocationMarkerStyle(
            markerSize: const Size(16, 16),
            headingSectorRadius: 75,
          ),
        ),

        Obx(
          () => MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              size: const Size(40, 40),
              markers: responderCtrl.alerts
                  .map(
                    (alert) => Marker(
                      alignment: Alignment.topCenter,
                      point: LatLng(
                        double.parse(alert.lat),
                        double.parse(alert.lng),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 9),
                            child: AvatarGlow(
                              glowRadiusFactor: 2,
                              glowColor: Colors.red,
                              child: SizedBox(width: 40, height: 40),
                            ),
                          ),

                          Icon(
                            Icons.location_pin,
                            size: 40,
                            opticalSize: 40,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              builder: (context, markers) {
                return AvatarGlow(
                  glowRadiusFactor: 2,
                  glowColor: Colors.red,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.red,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        Positioned(
          bottom: 85,
          right: 18,
          child: IconButton.filled(
            onPressed: () {
              final lat = double.tryParse(infoCtrl.lat.value);
              final lng = double.tryParse(infoCtrl.lng.value);

              if (lat == null || lng == null) {
                showAlertDialog(
                  "Error",
                  "Cannot find location. Please try again later.",
                );
                return;
              }

              animatedMapController.animateTo(
                dest: LatLng(lat, lng),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                zoom: 15,
                rotation: 0,
              );
            },
            icon: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(Icons.my_location_rounded),
            ),
          ),
        ),

        const MapCompass.cupertino(
          hideIfRotatedNorth: true,
          alignment: Alignment.topRight,
        ),
      ],
    );
  }
}

class MapTile extends StatelessWidget {
  const MapTile({super.key, required this.httpClient});

  final Client httpClient;

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      retinaMode: RetinaMode.isHighDensity(context),
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: "com.mavyfaby.pulse",
      tileProvider: NetworkTileProvider(
        httpClient: httpClient,
        cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(
          maxCacheSize: 1_000_000_000, // 1GB
        ),
      ),
    );
  }
}
