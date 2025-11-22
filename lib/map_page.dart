import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  void initLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      log(_locationData.toString());
      mapController.move(
        LatLng(_locationData?.latitude ?? 0, _locationData?.longitude ?? 0),
        16,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Карта')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(initialZoom: 5),
            children: [
              TileLayer(
                //urlTemplate: 'https://tiles.stadiamaps.com/tiles/stamen_toner/{z}/{x}/{y}.png',
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',

                //urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.myapp.dev/1.0',
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'ArcGIS online',
                  ),
                  // Also add images...
                ],              )
            ],
          ),
        ],
      ),
    );
  }
}
