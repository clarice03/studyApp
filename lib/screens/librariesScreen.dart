import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LibrariesScreen extends StatefulWidget {
  const LibrariesScreen({super.key});

  @override
  State<LibrariesScreen> createState() => _LibrariesScreenState();
}

class _LibrariesScreenState extends State<LibrariesScreen> {
  Position? currentPosition;
  String status = "Press button to get your location";

  final double libraryLat = 35.8997;
  final double libraryLng = 14.5146;

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        status = "Location services are disabled";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          status = "Location permission denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        status = "Permission permanently denied";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentPosition = position;

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        libraryLat,
        libraryLng,
      );

      status =
          "Your Location:\n"
          "Lat: ${position.latitude}\n"
          "Lng: ${position.longitude}\n\n"
          "Distance to library: ${(distance / 1000).toStringAsFixed(2)} km";
    });
  }

  Future<void> openGoogleMaps() async {
    if (currentPosition == null) return;

    final url =
        "https://www.google.com/maps/dir/?api=1"
        "&origin=${currentPosition!.latitude},${currentPosition!.longitude}"
        "&destination=$libraryLat,$libraryLng"
        "&travelmode=walking";

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Libraries (GPS)"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.location_on,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: getLocation,
              icon: const Icon(Icons.my_location),
              label: const Text("Get My Location"),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed:
                  currentPosition == null ? null : openGoogleMaps,
              icon: const Icon(Icons.map),
              label: const Text("Open in Google Maps"),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const Text(
              "Example Library:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const Text("University Main Library (Malta)"),
          ],
        ),
      ),
    );
  }
}