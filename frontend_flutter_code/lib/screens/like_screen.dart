import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/helper/shared_preferences_helper.dart';
import '../utils/helper/url_helper.dart';
import 'list_widget/google_map_widget.dart';
import 'list_widget/grid_view_widget.dart';
import 'list_widget/list_view_widget.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({Key? key}) : super(key: key);

  @override
  _LikeScreenState createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  // State variable to track selected view:
  // 0 - List View, 1 - Grid View, 2 - Map View
  int _selectedView = 0;

  // Holds the fetched location data
  List<Map<String, dynamic>> locationData = [];

  // Loading state and error message
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// Fetches favorite locations from the server
  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Retrieve stored user email from shared preferences
      final String? email =
      await SharedPreferencesHelper.getString("user_email");

      // Ensure email is valid before making API request
      if (email == null || email.isEmpty) {
        throw Exception("User email not found.");
      }

      // Make API request to fetch favorite locations
      final response = await http.post(
        Uri.parse(UrlHelper.getFavouritesUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"userEmail": email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Parse response and update state with fetched data
          locationData =
          List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title
      appBar: AppBar(title: const Text("Tourist App")),

      // Navigation Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Favourite Places"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // Main content layout
      body: Column(
        children: [
          // View selection bar
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.blueAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.list,
                          color: _selectedView == 0
                              ? Colors.yellow
                              : Colors.white),
                      onPressed: () => setState(() => _selectedView = 0),
                    ),
                    IconButton(
                      icon: Icon(Icons.grid_view,
                          color: _selectedView == 1
                              ? Colors.yellow
                              : Colors.white),
                      onPressed: () => setState(() => _selectedView = 1),
                    ),
                    IconButton(
                      icon: Icon(Icons.map,
                          color: _selectedView == 2
                              ? Colors.yellow
                              : Colors.white),
                      onPressed: () => setState(() => _selectedView = 2),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator()) // Show loading indicator
                : _errorMessage.isNotEmpty
                ? Center(
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
                : IndexedStack(
              index: _selectedView,
              children: [
                // List View
                ListViewWidget(
                  key: ValueKey(locationData.hashCode),
                  locationData: locationData,
                ),
                // Grid View
                GridViewWidget(
                  key: ValueKey(locationData.hashCode),
                  locationData: locationData,
                ),
                // Google Map View
                GoogleMapWidget(
                  key: ValueKey(locationData.hashCode),
                  locationData: locationData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
