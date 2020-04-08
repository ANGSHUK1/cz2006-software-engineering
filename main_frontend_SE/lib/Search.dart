import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:location/location.dart' as loc;
import 'package:search_map_place/search_map_place.dart';
import 'Routez.dart';
import 'package:google_maps_webservice/places.dart';

import 'SearchResults.dart';

class Search extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

GoogleMapsPlaces _places =
    GoogleMapsPlaces(apiKey: "AIzaSyA3YCs9pJnxE9gXAAkGDO3vNxxOsVgjWw8");

class _MyAppState extends State<Search> {
  BitmapDescriptor sourceicon;
  Completer<GoogleMapController> _controller = Completer();
  // GoogleMapController mapController;
  String googleAPIKey = "AIzaSyA3YCs9pJnxE9gXAAkGDO3vNxxOsVgjWw8";
   Set<Marker> _markers = Set<Marker>();
  //int _count = 0;
  final LatLng _center = const LatLng(1.3483, 103.6831);
  double _value = 1;
  Prediction p;
  TextEditingController _startloc = new TextEditingController();
  TextEditingController _endloc = new TextEditingController();
  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          GoogleMap(
            myLocationEnabled: true,
            markers: _markers,
            onMapCreated: onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 12.0,
            ),
          ),
          Column(children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 50),
              padding: EdgeInsets.only(right: 20, left: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            spreadRadius: 2.5,
                          ),
                        ],
                      ),
                      child: TextField(
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        controller: _startloc,
                        onTap: () async {
                          p = await PlacesAutocomplete.show(
                              context: context,
                              apiKey: googleAPIKey,
                              language: "en",
                              components: [Component(Component.country, "sg")],
                              mode: Mode.overlay);
                          _startloc.text = p.description;
                          var loc = displayPrediction(p);
                          print(loc);
                        },
                        decoration: InputDecoration(
                          labelText: "Start Location...",
                          //border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              padding: EdgeInsets.only(right: 20, left: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            spreadRadius: 2.5,
                          ),
                        ],
                      ),
                      child: TextField(
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        controller: _endloc,
                        onTap: () async {
                          Prediction p = await PlacesAutocomplete.show(
                              context: context,
                              apiKey: googleAPIKey,
                              language: "en",
                              components: [Component(Component.country, "sg")],
                              mode: Mode.overlay);
                          _endloc.text = p.description;
                          displayPrediction(p);
                        },
                        decoration: InputDecoration(
                            //border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                            labelText: "End Location..."),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              padding: EdgeInsets.only(right: 20, left: 20),
              height: 30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 150,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(),
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.airline_seat_recline_extra,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 700,
                    child: Container(
                      height: 40,
                      child: SliderTheme(
                        child: Slider(
                          value:
                              _value, // This value should be taken from the database, and used as initial value
                          min: 1,
                          max: 5,
                          divisions: 4,
                          onChanged: (double newValue) {
                            setState(() {
                              _value = newValue.toDouble(); // Should update to database only if the tick button is clicked.
                            });},
                            ),
                        
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 30,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 0),
                          thumbColor: Colors.black,
                          activeTrackColor: Colors.black,
                          inactiveTrackColor: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 150,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(),
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              padding: EdgeInsets.only(right: 20, left: 20),
              height: 40,
              width: 300,
              //color: Colors.white,
              child: RaisedButton(
                  color: Colors.black,
                  child: Text('Find Routes',
                      style: TextStyle(color: Colors.white)),
                  splashColor: Colors.grey,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  }),
            ),
            
            Container(
              margin: EdgeInsets.only(top: 80),
              child: Row(
              children: <Widget>[
                Spacer(flex:9),
                FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.my_location),
                  onPressed: () {_currentLocation();},
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ), 
                Spacer(),
              ],
            ),
          ),
          ])
        ],
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
      //controller.setMapStyle(Utils.mapStyles);
      _controller.complete(controller);
    }

  void _currentLocation() async {
   final GoogleMapController controller = await _controller.future;
   loc.LocationData currentLocation;
   var location = new loc.Location();
   try {
     currentLocation = await location.getLocation();
     } on Exception {
       currentLocation = null;
       }

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 17.0,
      ),
    ));
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;
      var startpoint=LatLng(lat,lng);

    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: startpoint,
        icon: sourceicon));

      var address = await Geocoder.local.findAddressesFromQuery(p.description);
      return (p.description);
    }
  }
}