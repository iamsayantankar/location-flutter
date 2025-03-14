import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../tourist_spot _details.dart';

class ListViewWidget extends StatefulWidget {
  final List<Map<String, dynamic>> locationData;

  const ListViewWidget({Key? key, required this.locationData}) : super(key: key);

  @override
  _ListViewWidgetState createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.locationData.length,
      itemBuilder: (context, index) {
        var data = widget.locationData[index];
        return GestureDetector(
            onTap: () {
              // navigate to details page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TouristSpotDetails(
                    oneValue: data,
                  ),
                ),
              );
            },
            child:  Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                leading: ClipOval(
                  child: Image.network(
                    data["photoUrl"],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(data["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style, // Inherit default text style
                    children: [
                      TextSpan(
                        text: "Description: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "${data["description"]}\n"),
                      TextSpan(
                        text: "State: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "${data["stateName"]}"),
                    ],
                  ),
                ),
              ),
            ),
        );


      },
    );
  }
}
