import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/helper/url_helper.dart';
import 'like_screen.dart';
import 'list_widget/google_map_widget.dart';
import 'list_widget/grid_view_widget.dart';
import 'list_widget/list_view_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedView = 0; // 0: List View, 1: Grid View, 2: Map View

  String _selectedState = "Select State";
  List<String> states = [];
  List<Map<String, dynamic>> locationData = []; // Holds fetched location data

  @override
  void initState() {
    super.initState();
    loadData(); // Load initial data
    loadStates(); // Load state list
  }

  /// Fetches location data based on selected state
  Future<void> loadData() async {
    final response = await http.get(
        Uri.parse("${UrlHelper.getDataUrl}&stateName=$_selectedState"));

    if (response.statusCode == 200) {
      setState(() {
        locationData =
        List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print("Failed to load location data");
    }
  }

  /// Fetches the list of states from the server
  Future<void> loadStates() async {
    final response = await http.get(Uri.parse(UrlHelper.getStateUrl));

    if (response.statusCode == 200) {
      setState(() {
        states = List<String>.from(json.decode(response.body));
      });
    } else {
      print("Failed to load states");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tourist App")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Favourite Places"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LikeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to Settings screen (implement separately)
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Dropdown and View Toggle Buttons
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.blueAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedState,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedState = newValue!;
                    });
                    loadData();
                  },
                  items: ["Select State", ...states]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Row(
                  children: [
                    // Toggle between List, Grid, and Map views
                    IconButton(
                      icon: Icon(Icons.list,
                          color:
                          _selectedView == 0 ? Colors.yellow : Colors.white),
                      onPressed: () => setState(() => _selectedView = 0),
                    ),
                    IconButton(
                      icon: Icon(Icons.grid_view,
                          color:
                          _selectedView == 1 ? Colors.yellow : Colors.white),
                      onPressed: () => setState(() => _selectedView = 1),
                    ),
                    IconButton(
                      icon: Icon(Icons.map,
                          color:
                          _selectedView == 2 ? Colors.yellow : Colors.white),
                      onPressed: () => setState(() => _selectedView = 2),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // View Container (List, Grid, Map)
          Expanded(
            child: IndexedStack(
              index: _selectedView,
              children: [
                ListViewWidget(
                  key: ValueKey(locationData.hashCode),
                  locationData: locationData,
                ),
                GridViewWidget(
                  key: ValueKey(locationData.hashCode),
                  locationData: locationData,
                ),
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
