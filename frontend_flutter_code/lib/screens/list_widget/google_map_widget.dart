import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../tourist_spot _details.dart';

class GoogleMapWidget extends StatefulWidget {
  final List<Map<String, dynamic>> locationData;

  const GoogleMapWidget({Key? key, required this.locationData}) : super(key: key);

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {

  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];


  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629), // Default position (India)
    zoom: 5,
  );


  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Map<String, dynamic>? getLocationByUid(String uid) {
    return widget.locationData.firstWhere(
          (location) => location["uid"] == uid,
      orElse: () => {}, // Returns null if no match is found
    );
  }
  Future<void> _loadMarkers() async {

    for (var data in widget.locationData) {
      Uint8List? markerImage = await _loadNetworkImage(data["photoUrl"]);
      if (markerImage != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(data["uid"].toString()),
            position: LatLng(
              double.parse(data["locationLat"].toString()),
              double.parse(data["locationLong"].toString()),
            ),
            icon: BitmapDescriptor.fromBytes(markerImage),
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow(
              title: data["name"].toString(),
              onTap: () => _showInfoDialog(
                data["name"].toString(),
                data["description"].toString(),
                data["uid"].toString(),
              ),
            ),
          ),
        );
      }
    }
    setState(() {});
  }


  Future<Uint8List?> _loadNetworkImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return _createRoundMarker(response.bodyBytes);
      }
    } catch (e) {
      debugPrint("Image load error: $e");
    }
    return null;
  }


  Future<Uint8List> _createRoundMarker(Uint8List imageBytes, {int size = 100}) async {
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes, targetWidth: size, targetHeight: size);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..isAntiAlias = true;

    final double radius = size / 2;
    final Offset center = Offset(radius, radius);

    final Path clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);
    canvas.drawImage(image, Offset.zero, paint);

    final ui.Image roundedImage = await recorder.endRecording().toImage(size, size);
    final ByteData? byteData = await roundedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }


  void _showInfoDialog(String name, String description, String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint("UID: $uid");
              Navigator.pop(context);

              Map? result = getLocationByUid(uid);


              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TouristSpotDetails(
                    oneValue: result,
                  ),
                ),
              );
            },
            child: const Text("Read More"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: Set<Marker>.of(_markers),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}
