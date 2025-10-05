import 'package:emergency_pulse/components/dialogs/pin.dart';
import 'package:emergency_pulse/controllers/location.controller.dart';
import 'package:emergency_pulse/controllers/settings.controller.dart';
import 'package:emergency_pulse/network/request.dart';
import 'package:emergency_pulse/views/alerts_sheet.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PageMap extends StatefulWidget {
  const PageMap({super.key});

  @override
  State<PageMap> createState() => _PageMapState();
}

class _PageMapState extends State<PageMap> with TickerProviderStateMixin {
  /// Maximum amount of cluster managers.
  static const int _clusterManagerMaxCount = 2;

  /// Amount of markers to be added to the cluster manager at once.
  static const int _markersToAddToClusterManagerCount = 2;

  /// Counter for added cluster manager ids.
  int _clusterManagerIdCounter = 1;

  /// Cluster that was tapped most recently.
  Cluster? lastCluster;

  /// Map of clusterManagers with identifier as the key.
  Map<ClusterManagerId, ClusterManager> clusterManagers =
      <ClusterManagerId, ClusterManager>{};

  /// Map of markers with identifier as the key.
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  final config = ImageConfiguration(size: const Size(35, 45));
  final locationCtrl = Get.find<LocationController>();
  final settingsCtrl = Get.find<SettingsController>();

  String darkStyle = "";

  BitmapDescriptor? markerDoneIcon;
  BitmapDescriptor? markerPendingIcon;

  @override
  void dispose() {
    settingsCtrl.tabController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _addClusterManager();

    settingsCtrl.tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );

    // Load the dark mode style
    rootBundle.loadString("assets/map_styles/aubergine.json").then((value) {
      darkStyle = value;
    });

    onRefresh();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      settingsCtrl.bottomSheetCtrl = showBottomSheet(
        context: context,
        enableDrag: true,
        showDragHandle: true,
        builder: (context) {
          return SheetAlerts(tabController: settingsCtrl.tabController!);
        },
      );

      settingsCtrl.isTabOpen.value = true;
      settingsCtrl.bottomSheetCtrl?.closed.then((_) {
        settingsCtrl.isTabOpen.value = false;
      });
    });
  }

  void _onMapCreated(GoogleMapController controllerParam) {
    setState(() {
      locationCtrl.mapController = controllerParam;
    });
  }

  void _addClusterManager() {
    if (clusterManagers.length == _clusterManagerMaxCount) {
      return;
    }

    final String clusterManagerIdVal =
        'cluster_manager_id_$_clusterManagerIdCounter';

    _clusterManagerIdCounter++;

    final ClusterManagerId clusterManagerId = ClusterManagerId(
      clusterManagerIdVal,
    );

    final ClusterManager clusterManager = ClusterManager(
      clusterManagerId: clusterManagerId,
      onClusterTap: (Cluster cluster) => setState(() {
        lastCluster = cluster;
      }),
    );

    setState(() {
      clusterManagers[clusterManagerId] = clusterManager;
    });

    _addMarkersToCluster(clusterManager);
  }

  void _addMarkersToCluster(ClusterManager clusterManager) {
    for (int i = 0; i < _markersToAddToClusterManagerCount; i++) {
      markers.forEach((markerId, marker) {
        final newMarker = Marker(
          clusterManagerId: clusterManager.clusterManagerId,
          markerId: markerId,
          position: marker.position,
          icon: marker.icon,
          infoWindow: marker.infoWindow,
          onTap: marker.onTap,
        );

        markers[markerId] = newMarker;
      });
    }

    setState(() {});
  }

  Future<void> onRefresh() async {
    markerDoneIcon ??= await BitmapDescriptor.asset(
      config,
      "assets/marker_done.png",
    );
    markerPendingIcon ??= await BitmapDescriptor.asset(
      config,
      "assets/marker_pending.png",
    );

    locationCtrl.isRefreshing.value = true;
    await fetchAlerts();
    locationCtrl.isRefreshing.value = false;

    markers.clear();
    clusterManagers.clear();

    for (final alert in locationCtrl.alerts) {
      final markerId = MarkerId(alert.hashId);

      final marker = Marker(
        markerId: markerId,
        position: LatLng(double.parse(alert.lat), double.parse(alert.lng)),
        icon: alert.doneAt == null ? markerPendingIcon! : markerDoneIcon!,
        infoWindow: InfoWindow(title: alert.name, snippet: alert.contactNo),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => DialogPin(alert: alert),
          );
        },
      );

      markers[markerId] = marker;
    }

    _addClusterManager();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: locationCtrl.refreshKey,
      onRefresh: onRefresh,
      child: Obx(
        () => GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: MapType.normal,
          style: settingsCtrl.isDarkMode.value ? darkStyle : null,
          myLocationEnabled: true,
          buildingsEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: false,
          indoorViewEnabled: true,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: true,
          trafficEnabled: true,
          fortyFiveDegreeImageryEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(10.3157, 123.8854),
            zoom: 10,
          ),
          markers: Set<Marker>.of(markers.values),
          clusterManagers: Set<ClusterManager>.of(clusterManagers.values),
        ),
      ),
    );
  }
}
