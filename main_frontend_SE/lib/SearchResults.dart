import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bicycle/Routez.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'loadingPage.dart';
import 'package:google_fonts/google_fonts.dart';

// void main() {
//   runApp(MyApp());
// }

const double CAMERA_ZOOM = 12;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
//const LatLng SOURCE_LOCATION = LatLng(1.355435, 103.685172);
//const LatLng DEST_LOCATION = LatLng(1.341454, 103.684035);
//enum ElevationLevel { Uphill, Downhill, Balanced, Flat }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

class MyRecommPage extends StatefulWidget {
  var routes;
  int id;
  int length;
  var search;
  double maxDist;
  int minCal;
  MyRecommPage(
      {@required this.routes,
      @required this.id,
      @required this.length,
      @required this.search,
      this.maxDist,
      this.minCal});
  State<StatefulWidget> createState() => RecommenderState(
      UserID: id,
      searchOutput: routes,
      len: length,
      searchAttr: search,
      maxDist: maxDist,
      minCal: minCal);
}

class RecommenderState extends State<MyRecommPage> {
  var searchOutput;
  int UserID;
  int len;
  var searchAttr;
  double maxDist;
  int minCal;
  RecommenderState(
      {@required this.searchOutput,
      @required this.UserID,
      @required this.len,
      @required this.searchAttr,
      this.maxDist,
      this.minCal});

  var SearchResults = [];
  GoogleMapController mapController;
  List<Set> poly = [];
  List<Set> mark = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String googleAPIKey = "AIzaSyA3YCs9pJnxE9gXAAkGDO3vNxxOsVgjWw8";
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _textcontrollerdist = new TextEditingController();
  TextEditingController _textcontrollercalo = new TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (maxDist != null) {
      _textcontrollerdist.text = maxDist.toString();
    }
    if (minCal != null) {
      _textcontrollercalo.text = minCal.toString();
    }

    return loading
        ? LoadingPage()
        : Scaffold(
            resizeToAvoidBottomPadding: false,
            resizeToAvoidBottomInset: false,
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                'Recommended Routes',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                splashColor: Colors.black.withAlpha(30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: Colors.black,
                  ),
                  splashColor: Colors.black.withAlpha(30),
                  onPressed: () => _scaffoldKey.currentState.openDrawer(),
                ),
              ],
            ),
            drawer: new Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      "Filter",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                    decoration: BoxDecoration(color: Colors.white),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      //obscureText: true,
                      controller:
                          _textcontrollerdist, // This value should be taken from the database, and used as initial value
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Max Distance (Kms)',
                      ),
                      onChanged: (String value){
                        if(value==''){
                          maxDist = null;
                          _textcontrollerdist.text = null;
                        }
                        else{
                        maxDist = double.parse(value);
                        _textcontrollerdist.text = value;
                        _textcontrollerdist.selection=TextSelection.collapsed(offset:_textcontrollerdist.text.length);
                        }
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      //obscureText: true,
                      controller:
                          _textcontrollercalo, // This value should be taken from the database, and used as initial value
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Total Calories to burn (KCal))',
                      ),
                      
                      onChanged: (String value){
                        if(value==''){
                          minCal = null;
                          _textcontrollercalo.text = null;
                        }
                        else{
                        minCal = int.parse(value);
                        _textcontrollercalo.text = value;
                        _textcontrollercalo.selection=TextSelection.collapsed(offset:_textcontrollercalo.text.length);
                        }
                      },
                      
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: IconButton(
                            icon: Icon(
                              Icons.done,
                              size: 50,
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              setState(() => loading = true);
                              var SearchResultsLat = await getSearchResults();
                              setState(() => loading = false);
                              if (_textcontrollerdist.text == '' &&
                                  _textcontrollercalo.text == '') {
                                
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => MyRecommPage(
                                            id: UserID,
                                            routes: SearchResultsLat,
                                            length: SearchResultsLat[0].length,
                                            search: searchAttr,
                                            maxDist: null,
                                            minCal: null,
                                          )),
                                );
                              } else if (_textcontrollerdist.text != '' &&
                                  _textcontrollercalo.text == '') {
                                
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => MyRecommPage(
                                            id: UserID,
                                            routes: SearchResultsLat,
                                            length: SearchResultsLat[0].length,
                                            search: searchAttr,
                                            maxDist: double.parse(
                                                _textcontrollerdist.text),
                                            minCal: null,
                                          )),
                                );
                              } else if (_textcontrollerdist.text == '' &&
                                  _textcontrollercalo.text != '') {
                                
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => MyRecommPage(
                                            id: UserID,
                                            routes: SearchResultsLat,
                                            length: SearchResultsLat[0].length,
                                            search: searchAttr,
                                            maxDist: null,
                                            minCal: int.parse(
                                                _textcontrollercalo.text),
                                          )),
                                );
                              } else if (_textcontrollerdist.text != '' &&
                                  _textcontrollercalo.text != '') {
                                
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => MyRecommPage(
                                            id: UserID,
                                            routes: SearchResultsLat,
                                            length: SearchResultsLat[0].length,
                                            search: searchAttr,
                                            maxDist: double.parse(
                                                _textcontrollerdist.text),
                                            minCal: int.parse(
                                                _textcontrollercalo.text),
                                          )),
                                );
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: Icon(
                              Icons.cached,
                              size: 50,
                            ),
                            onPressed: () {
                              _textcontrollercalo.value =
                                  TextEditingValue.empty;
                              _textcontrollerdist.value =
                                  TextEditingValue.empty;

                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: (len == 0)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Spacer(flex: 1),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.only(right: 30, left: 30),
                          alignment: Alignment.center,
                          child: Text(
                              "Sorry, we couldnt find a route matching all your preferences. Can you try again with different filters? Thank you!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lora(
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic)),
                        ),
                      ),
                      Spacer(flex: 1),
                    ],
                  )
                : (searchAttr[4] != searchOutput[6][0])
                    ? SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                        "Sorry, we couldnt find a route for your fitness level. However, here are routes of different fitness levels!",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.lora(
                                            color: Colors.black,
                                            fontStyle: FontStyle.italic)),
                                    Container(height: 20),
                                    for (var i = 0; i < len; i++)
                                      _mapfunc(context, i)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: <Widget>[
                                    for (var i = 0; i < len; i++)
                                      _mapfunc(context, i)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          );
  }

  void onMapCreated(GoogleMapController controller) {
    //controller.setMapStyle(Utils.mapStyles);
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  Widget _mapfunc(BuildContext context, int index) {
    

    final polyline = searchOutput[9];
    final routeAsc = searchOutput[1];
    final routeDesc = searchOutput[2];
    final routeFlat = searchOutput[3];
    final routeDist = searchOutput[4];
    final routeTime = searchOutput[7];
    final routeCal = searchOutput[8];
    final routeElevDetails = searchOutput[10];
    final routeFitLvl = searchOutput[6];
    final startLocs = List<LatLng>.filled(
        len,
        LatLng(searchOutput[0][0]['legs'][0]["start_location"]['lat'],
            searchOutput[0][0]['legs'][0]["start_location"]['lng']));
    final endLocs = List<LatLng>.filled(
        len,
        LatLng(searchOutput[0][0]['legs'][0]["end_location"]['lat'],
            searchOutput[0][0]['legs'][0]["end_location"]['lng']));
    setMapPins(startLocs[index], endLocs[index]);
    setPolylines(polyline[index], [], PolylinePoints());

    return Card(
      semanticContainer: true,
      margin: EdgeInsets.only(bottom: 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          setState(() => loading = true);
          var routeDet = [];
          routeDet.add(searchOutput[0][index]);
          routeDet.add(routeDist[index].toStringAsFixed(1));
          routeDet.add(routeTime[index].round().toString());
          routeDet.add(routeCal[index].round().toString());
          routeDet.add(routeAsc[index].toStringAsFixed(1));
          routeDet.add(routeDesc[index].toStringAsFixed(1));
          routeDet.add(routeFlat[index].toStringAsFixed(1));
          routeDet.add(polyline[index]);
          routeDet.add(routeElevDetails[index]);
          routeDet.add(searchOutput[6][index]);
          //routeDet.add(routeFitLvl[index].toStringAsFixed(1));
          
          setState(() => loading = false);
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => Routez(id: UserID, route: routeDet)),
          );
        },
        child: Container(
          width: 500,
          height: 300,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: 500,
                    height: 150,
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20)),
                      color: Colors.blue,
                    ),

                    child: GoogleMap(
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      compassEnabled: false,
                      tiltGesturesEnabled: true,

                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                          zoom: CAMERA_ZOOM,
                          bearing: CAMERA_BEARING,
                          tilt: CAMERA_TILT,
                          target: LatLng(
                              searchOutput[0][0]['legs'][0]["end_location"]
                                  ['lat'],
                              searchOutput[0][0]['legs'][0]["end_location"]
                                  ['lng'])),
                      onMapCreated: (controller) {
                        setState(() {
                          mapController = controller;
                          //setMapPins(startLocs[index], endLocs[index]);
                          //setPolylines(polyline[index], [],PolylinePoints());
                        });
                      },
                      markers: _markers,
                      polylines: poly[index],

                      // (GoogleMapController controller) {
                      //   _controller.complete(controller);
                      //   setMapPins(startLocs[index], endLocs[index]);
                      //   setPolylines(polyline[index], [],PolylinePoints());
                      // },

                      //options:
                    ),

                    //color: Colors.green,

                    //alignment: Alignment.topCenter,
                  ),
                  Container(
                    width: 500,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black38, width: 1),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              routeDist[index].toStringAsFixed(1) +
                                  ' Km', // this is a random value. original value must be extracted from database / route detail and replaced here
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                right:
                                    BorderSide(color: Colors.black38, width: 1),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              routeTime[index].round().toString() +
                                  ' Mins', // this is a random value. original value must be extracted from database / route detail and replaced here
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                right:
                                    BorderSide(color: Colors.black38, width: 1),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              routeCal[index].round().toString() +
                                  ' KCal', // this is a random value. original value must be extracted from database / route detail and replaced here
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 500,
                    height: 50,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black38,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Ascent: ' +
                                  routeAsc[index].toStringAsFixed(1) +
                                  ' Km', // this is a random value. original value must be extracted from database / route detail and replaced here
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                right:
                                    BorderSide(color: Colors.black38, width: 1),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Descent: ' +
                                  routeDesc[index].toStringAsFixed(1) +
                                  ' Km', // this is a random value. original value must be extracted from database / route detail and replaced here
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 500,
                    height: 50,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Flat: ' +
                                  routeFlat[index].toStringAsFixed(1) +
                                  ' Km', // this is a random value. original value must be extracted from database / route detail and replaced here
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                right:
                                    BorderSide(color: Colors.black38, width: 1),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  flex: 70,
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "Fitness Level: ", // this is a random value. original value must be extracted from database / route detail and replaced here
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 30,
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      alignment: Alignment.center,
                                      decoration: new BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        routeFitLvl[index].toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setMapPins(LatLng source, LatLng dest) {
    setState(() {
      _markers = {};
      // source pin
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'), position: source, icon: sourceIcon));
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: dest,
          icon: destinationIcon));

      mark.add(_markers);
    });
  }

  getSearchResults() async {
    var weight = 100; //default

    var response1 = await http
        .get('http://localhost:3333/users/id/?id=' + UserID.toString());
    if (response1.statusCode == 200) {
      weight = (json.decode(response1.body))['weight'];
    } else {
      throw Exception('Failed to load weight');
    }
    var url = 'http://localhost:3333/algo/routes_search/?startPos_lat=' +
        searchAttr[0] +
        '&startPos_long=' +
        searchAttr[1] +
        '&endPos_lat=' +
        searchAttr[2] +
        '&endPos_long=' +
        searchAttr[3] +
        '&fit_level=' +
        searchAttr[4] +
        '&weight=' +
        searchAttr[5];
    searchAttr.add(searchAttr[0]);
    searchAttr.add(searchAttr[1]);
    searchAttr.add(searchAttr[2]);
    searchAttr.add(searchAttr[3]);
    searchAttr.add(searchAttr[4]);
    searchAttr.add(searchAttr[5]);
    if ((_textcontrollerdist.text) != "") {
      url = url + '&max_dist=' + _textcontrollerdist.text;
    }
    if ((_textcontrollercalo.text) != "") {
      url = url + '&cal=' + _textcontrollercalo.text;
    }

    var response3 = await http.get(url);

    if (response3.statusCode == 200) {
      var UpdatedSearchResults = (json.decode(response3.body));
      return UpdatedSearchResults;
    } else {
      throw Exception('Failed to load results');
    }
  }

  setPolylines(String pol, List<LatLng> polylineCoordinates,
      PolylinePoints polylinePoints) async {
    // List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
    //     googleAPIKey,
    //     SOURCE_LOCATION.latitude,
    //     SOURCE_LOCATION.longitude,
    //     DEST_LOCATION.latitude,
    //     DEST_LOCATION.longitude);

    List<PointLatLng> result = polylinePoints.decodePolyline(pol);
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
      _polylines = {};
      Polyline polyline = Polyline(
          polylineId: PolylineId("poly"),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);

      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.add(polyline);
      poly.add(_polylines);
    });
  }
}
