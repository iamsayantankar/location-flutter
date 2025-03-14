import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sd_project/utils/helper/shared_preferences_helper.dart';

import '../utils/helper/url_helper.dart';

class TouristSpotDetails extends StatefulWidget {
  final Map? oneValue;

  const TouristSpotDetails({
    Key? key,
    required this.oneValue,
  }) : super(key: key);

  @override
  _TouristSpotDetailsState createState() => _TouristSpotDetailsState();
}

class _TouristSpotDetailsState extends State<TouristSpotDetails> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;

  bool? _isLiked; // null = no selection, true = liked, false = disliked

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // Api call
    loadData();
  }

// Function to load liked data from the server
  Future<void> loadData() async {
    // Retrieve the user's email from shared preferences
    final String? email = await SharedPreferencesHelper.getString("user_email");

    try {
      // Send a POST request to fetch liked data
      final response = await http.post(
        Uri.parse(UrlHelper.getLikeUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"userEmail": email}),
      );

      // If the request is successful (HTTP 200 OK)
      if (response.statusCode == 200) {
        // Decode the response JSON into a list of liked IDs
        List likeIds = json.decode(response.body);

        // Check if the current item's ID is in the list of liked items
        if (likeIds.contains(widget.oneValue!["uid"])) {
          setState(() {
            _isLiked = true; // Mark the item as liked
          });
        } else if (likeIds.isNotEmpty) {
          setState(() {
            _isLiked = false; // Mark the item as not liked
          });
        }
      }
    } catch (e) {
      // Print error message if request fails
      print("Error fetching liked data: $e");
    }
  }

// Function to update like status on the server
  Future<void> _updateLike() async {
    // Retrieve the user's email from shared preferences
    final String? email = await SharedPreferencesHelper.getString("user_email");

    try {
      // Send a POST request to update the like status
      final response = await http.post(
        Uri.parse(UrlHelper.setLikeUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "userEmail": email,
          "touristId": widget.oneValue!["uid"], // ID of the item being liked
        }),
      );

      // If the request is successful (HTTP 200 OK)
      if (response.statusCode == 200) {
        // Decode the response JSON into a list of liked IDs
        List likeIds = json.decode(response.body);

        // Check if the current item's ID is in the list of liked items
        if (likeIds.contains(widget.oneValue!["uid"])) {
          setState(() {
            _isLiked = true; // Mark the item as liked
          });
        } else if (likeIds.isNotEmpty) {
          setState(() {
            _isLiked = false; // Mark the item as not liked
          });
        }
      }
    } catch (e) {
      // Print error message if request fails
      print("Error updating like status: $e");
    }
  }

// Function to get the current GPS location of the user
  Future<void> _getCurrentLocation() async {
    // Fetch the current position with high accuracy
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Update the state with the new location
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _setMarkers(); // Update markers on the map
    });
  }


  late GoogleMapController mapController;

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyDQ2c_pOSOFYSjxGMwkFvCVWKjYOM9siow";

  /// Function to set markers on the map, including origin, destination, and nearby shops.
  void _setMarkers() {
    // Add a marker for the user's current location (origin)
    _addMarker(
      _currentLocation!, // Current location coordinates
      "origin", // Unique marker ID
      "My Location", // Marker title
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Blue color for origin
    );

    // Add a marker for the destination location
    _addMarker(
      LatLng(
        double.parse(widget.oneValue!["locationLat"].toString()),
        double.parse(widget.oneValue!["locationLong"].toString()),
      ),
      "destination", // Unique marker ID for destination
      widget.oneValue!["name"], // Destination name
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Red color for destination
    );

    // Draw the route (polyline) between origin and destination
    _getPolyline();

    // Add markers for nearby shops
    for (int i = 0; i < widget.oneValue!["nearShops"].length; i++) {
      _addMarker(
        LatLng(
          double.parse(widget.oneValue!["nearShops"][i]["locationLat"].toString()),
          double.parse(widget.oneValue!["nearShops"][i]["locationLong"].toString()),
        ),
        "shop_$i", // Unique marker ID for each shop
        widget.oneValue!["nearShops"][i]["name"], // Shop name
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // Green color for shops
      );
    }

    // Update the UI after adding markers
    setState(() {});
  }

  /// Function to focus the camera on the user's current location.
  Future<void> _focusOnCurrentLocation() async {
    // Get the user's current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // High accuracy for better positioning
    );

    // Convert position to LatLng format
    LatLng currentLocation = LatLng(position.latitude, position.longitude);

    // Move the camera to the current location with zoom level 15
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLocation, zoom: 15), // Zoom in for better visibility
      ),
    );
  }

  /// Callback function triggered when the map is created.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller; // Store the controller instance
    _focusOnCurrentLocation(); // Automatically focus on user's location after map loads
  }

  /// Function to add a marker to the map.
  void _addMarker(
      LatLng position, // Coordinates of the marker
      String id, // Unique ID for the marker
      String title, // Title of the marker (displayed in the info window)
      BitmapDescriptor descriptor, // Custom marker icon/color
      ) {
    MarkerId markerId = MarkerId(id); // Create a unique marker ID
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor, // Custom marker appearance
      position: position, // Marker position
      anchor: const Offset(0.5, 0.5), // Center the marker
      infoWindow: InfoWindow(
        title: title, // Display marker title in an info window
      ),
    );

    // Add the marker to the markers map
    markers[markerId] = marker;
  }


  _addPolyLine() {
    PolylineId id = PolylineId("route");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.green,
      // Set color to green
      width: 5,
      // Set width to 1px
      points: polylineCoordinates,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<void> _getPolyline() async {
    if (_currentLocation == null) return;

    // Get polyline route
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyAy8IOF5Fdx7gPUfWWelE_-kYFiyzYZqYE",
      request: PolylineRequest(
        origin: PointLatLng(
            _currentLocation!.latitude, _currentLocation!.longitude),
        destination: PointLatLng(
            double.parse(widget.oneValue!["locationLat"].toString()),
            double.parse(widget.oneValue!["locationLong"].toString())),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();

      // Convert points to LatLng
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      // Generate 8 waypoints within 1 km
      List<PolylineWayPoint> waypoints =
          _generateWaypoints(polylineCoordinates);

      // Re-fetch route with waypoints
      _getPolylineWithWaypoints(waypoints);
    }
  }

  Future<void> _getPolylineWithWaypoints(
      List<PolylineWayPoint> waypoints) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyAy8IOF5Fdx7gPUfWWelE_-kYFiyzYZqYE",
      request: PolylineRequest(
        origin: PointLatLng(
            _currentLocation!.latitude, _currentLocation!.longitude),
        destination: PointLatLng(
            double.parse(widget.oneValue!["locationLat"].toString()),
            double.parse(widget.oneValue!["locationLong"].toString())),
        mode: TravelMode.driving,
        wayPoints: waypoints,
      ),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      _addPolyLine();
    }
  }

  List<PolylineWayPoint> _generateWaypoints(List<LatLng> routePoints) {
    List<PolylineWayPoint> waypoints = [];
    double totalDistance = 0.0;
    int waypointCount = 0;
    const int maxWaypoints = 100;
    const double maxDistance = 1.0; // 1 km

    for (int i = 1; i < routePoints.length; i++) {
      double segmentDistance = Geolocator.distanceBetween(
            routePoints[i - 1].latitude,
            routePoints[i - 1].longitude,
            routePoints[i].latitude,
            routePoints[i].longitude,
          ) /
          1000; // Convert to km

      totalDistance += segmentDistance;

      if (totalDistance <= maxDistance && waypointCount < maxWaypoints) {
        waypoints.add(PolylineWayPoint(
          location: "${routePoints[i].latitude},${routePoints[i].longitude}",
        ));
        waypointCount++;
      }
    }

    return waypoints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.oneValue?["name"] ?? "Unknown",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ====== Location Map ======
                  sectionTitle("Location Map"),
                  Container(
                    height: 300,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            double.parse(
                                widget.oneValue!["locationLat"].toString()),
                            double.parse(
                                widget.oneValue!["locationLong"].toString()),
                          ),
                          zoom: 12,
                        ),
                        myLocationEnabled: true,
                        tiltGesturesEnabled: true,
                        compassEnabled: true,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        myLocationButtonEnabled: true,
                        onMapCreated: _onMapCreated,
                        markers: Set<Marker>.of(markers.values),
                        polylines: Set<Polyline>.of(polylines.values),
                      ),
                    ),
                  ),

                  // ====== Like/Dislike Buttons ======
                  _buildLikeDislikeButtons(),

                  // ====== Tourist Spot Details ======
                  sectionTitle("Tourist Spot Details"),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.oneValue!["photoUrl"],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  infoText(widget.oneValue?["name"] ?? "", 22, FontWeight.bold),
                  subInfoText("State: ${widget.oneValue!["stateName"]}"),
                  descriptionText(widget.oneValue?["description"] ?? ""),

                  // ====== Nearby Shops ======
                  sectionTitle("Nearby Locations & Shops"),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(8),
                      itemCount: widget.oneValue!["nearShops"].length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio:
                            0.7, // Adjusted to allow more flexibility
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        var data = widget.oneValue!["nearShops"][index];
                        return IntrinsicHeight(
                          // Makes the item height flexible
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      data["photoUrl"],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  infoText(data["name"], 16, FontWeight.bold),
                                  SizedBox(height: 5),
                                  Flexible(
                                    child: Text(
                                      "Description: ${data["description"]}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ====== Guides ======
                  sectionTitle("Available Guides"),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.oneValue!["guides"].length,
                      itemBuilder: (context, index) {
                        var data = widget.oneValue!["guides"][index];
                        return Card(
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            title: infoText(data["name"], 18, FontWeight.bold),
                            subtitle: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.black),
                                children: [
                                  textSpan("Email: ", true),
                                  textSpan("${data["email"]}\n", false),
                                  textSpan("Phone No: ", true),
                                  textSpan("${data["phone"]}", false),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLikeDislikeButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),

          IconButton(
            icon: Icon(Icons.thumb_up, size: 30),
            color: _isLiked == true ? Colors.green : Colors.grey,
            onPressed: () {
              setState(() {
                _isLiked = _isLiked == true ? null : true;
              });
              _updateLike();
            },
          ),
          SizedBox(width: 20),
          // IconButton(
          //   icon: Icon(Icons.thumb_down, size: 30),
          //   color: _isLiked == false ? Colors.red : Colors.grey,
          //   onPressed: () {
          //     setState(() {
          //       _isLiked = _isLiked == false ? null : false;
          //     });
          //     _updateLike();
          //   },
          // ),
        ],
      ),
    );
  }

  // Helper Widgets for Beautiful Styling
  Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple),
      ),
    );
  }

  Widget infoText(String text, double size, FontWeight weight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        text,
        style: TextStyle(fontSize: size, fontWeight: weight),
      ),
    );
  }

  Widget subInfoText(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[700], fontSize: 14),
      ),
    );
  }

  Widget descriptionText(String text) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  TextSpan textSpan(String text, bool bold) {
    return TextSpan(
      text: text,
      style: TextStyle(
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: Colors.black87,
      ),
    );
  }
}
