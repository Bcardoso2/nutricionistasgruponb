import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserTrackingPage extends StatefulWidget {
  final String username;

  UserTrackingPage({required this.username});

  @override
  _UserTrackingPageState createState() => _UserTrackingPageState();
}

class _UserTrackingPageState extends State<UserTrackingPage> {
  late GoogleMapController _mapController;

  // Localização inicial (vazia)
  LatLng _initialLocation = LatLng(0, 0);

  // Localização em tempo real (pode ser atualizada periodicamente)
  LatLng _realTimeLocation = LatLng(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rastreamento de Usuário: ${widget.username}'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialLocation,
          zoom: 15.0, // Nível de zoom inicial
        ),
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
          });
        },
        markers: {
          Marker(
            markerId: MarkerId('realTimeLocation'),
            position: _realTimeLocation,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        },
      ),
    );
  }
}
