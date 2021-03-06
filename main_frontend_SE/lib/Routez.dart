import 'dart:async';
import 'dart:convert';
import 'package:bicycle/new_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'liveNav.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class Routez extends StatefulWidget {
  int id;
  var route;
  Routez({@required this.id, @required this.route});
  @override
  _MapPageState createState() => _MapPageState(UserID:id, routeDet: route);
}


const double CAMERA_ZOOM = 15;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;


class _MapPageState extends State<Routez> {
  int UserID;
  var routeDet;
  var weight;
  _MapPageState({@required this.UserID, @required this.routeDet});
    Completer<GoogleMapController> _controller = Completer();
    Set<Marker> _markers = {};
    Set<Polyline> _polylines = {};
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    String googleAPIKey = "AIzaSyA3YCs9pJnxE9gXAAkGDO3vNxxOsVgjWw8";
    BitmapDescriptor sourceIcon;
    BitmapDescriptor destinationIcon;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
        children: <Widget>[GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            tiltGesturesEnabled: false,
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
                                      zoom: CAMERA_ZOOM,
                                      bearing: CAMERA_BEARING,
                                      tilt: CAMERA_TILT,
                                      target: LatLng(routeDet[0]['legs'][0]["end_location"]['lat'], routeDet[0]['legs'][0]["end_location"]['lng']),),

            onMapCreated: onMapCreated),

          Column(children: <Widget> [
            Spacer(flex: 2,),
            Container(child: Row(children: <Widget>[Spacer(),
                FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.arrow_back),
                  backgroundColor: Colors.white,
                  onPressed:(){
                    Navigator.pop(context);
                  }
                    
                  ,
                  foregroundColor: Colors.black,
                ),
                Spacer(flex:9),
              ],
            ),
          ),
            Spacer(flex: 17,),
            Container(child: Row(
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
          Spacer(),
          Container(child: Row(
              children: <Widget>[
                
                Spacer(flex:9),
                Container(
                child: CupertinoButton(
                  child: Text("START"),
                  color: Colors.black,
                  onPressed:() async {
                    await getWeight();
                    print(weight);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
              LiveNav(id: UserID, route: routeDet, weight1: weight)),
        );}
                    //_onButtonPressedf
                  ,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                ),
                Spacer(),
              ],
            ),),
          Spacer(),
        ],
      ),

      ],
        ),
      );
    }

    // @override
    // void initState() {
    //   super.initState();
    //   setSourceAndDestinationIcons();
    // }

    void setSourceAndDestinationIcons() async {
      sourceIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');
      destinationIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5),
          'assets/destination_map_marker.png');
    }
    void onMapCreated(GoogleMapController controller) {
      //controller.setMapStyle(Utils.mapStyles);
      _controller.complete(controller);
      setMapPins();
      setPolylines();
    }

    void setMapPins() {
      setState(() {
        // source pin
        _markers.add(Marker(
            markerId: MarkerId('sourcePin'),
            position: LatLng(routeDet[0]['legs'][0]["start_location"]['lat'], routeDet[0]['legs'][0]["start_location"]['lng']),
            icon: sourceIcon));
        // destination pin
        _markers.add(Marker(
            markerId: MarkerId('destPin'),
            position: LatLng(routeDet[0]['legs'][0]["end_location"]['lat'], routeDet[0]['legs'][0]["end_location"]['lng']),
            icon: destinationIcon));
      });
    }

    setPolylines() async {

        // List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        //     googleAPIKey,
        //     SOURCE_LOCATION.latitude,
        //     SOURCE_LOCATION.longitude,
        //     DEST_LOCATION.latitude,
        //     DEST_LOCATION.longitude);
        List<PointLatLng> result = polylinePoints.decodePolyline(routeDet[7]);
        print(result);
        if (result.isNotEmpty) {
          // loop through all PointLatLng points and convert them
          // to a list of LatLng, required by the Polyline
          result.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
        }

      setState(() {
          // create a Polyline instance
          // with an id, an RGB color and the list of LatLng pairs
          Polyline polyline = Polyline(
              polylineId: PolylineId("poly"),
              color: Color.fromARGB(255, 40, 122, 198),
              points: polylineCoordinates);

          // add the constructed polyline as a set of points
          // to the polyline set, which will eventually
          // end up showing up on the map
          _polylines.add(polyline);
      });
  }
  void _currentLocation() async {
   final GoogleMapController controller = await _controller.future;
   LocationData currentLocation;
   var location = new Location();
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
  getWeight() async {
    var response1 = await http.get('http://localhost:3333/users/id/?id='+UserID.toString());
  if (response1.statusCode==200)
  {
  weight = await (json.decode(response1.body))['weight'];
  } else{
    throw Exception('Failed to load weight');
  }
  }
}
/*
class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}
*/