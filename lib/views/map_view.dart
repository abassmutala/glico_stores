import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  const MapView({super.key, required this.latitude, required this.longitude});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller = Completer();
  late BitmapDescriptor markerIcon;
  final Set<Marker> _markers = <Marker>{};
  late LatLng centre;

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _showMapPins();
  }

  void setCentreIcon() async {
    markerIcon = BitmapDescriptor.defaultMarker;
  }

  void setInitialLocation() {
    centre = LatLng(
      widget.latitude,
      widget.longitude,
    );
  }

  void _showMapPins() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('store_location'),
          position: LatLng(widget.latitude, widget.longitude),
          icon: markerIcon,
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    setInitialLocation();
    setCentreIcon();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.latitude, widget.longitude),
        zoom: 16.0,
      ),
      onMapCreated: _onMapCreated,
      myLocationButtonEnabled: false,
      markers: _markers,
    );
  }
}
