// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/Constants/theme.dart';
import 'package:flame/model/Recommendation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../Constants/color.dart';

class SearchandPreview extends StatefulWidget {
  const SearchandPreview({Key? key, DetailsResult? VALUELOCATION})
      : super(key: key);

  @override
  State<SearchandPreview> createState() => _SearchandPreviewState();
}

class _SearchandPreviewState extends State<SearchandPreview> {
  // Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _controller;
  late User loggedInUser;
  String? loggedInUser2;
  String? UserPhoto;
  Marker? prevMarker;
  BitmapDescriptor? myIcon;
  late var placeId;
  late var details;
  final _auth = FirebaseAuth.instance;
  Recommendation? selectedMarker;

  Set<Marker> markers = {};
  String? SAVESTATUS;

  String? UserPic;
  void addUserPicOnMap({required String UserID}) {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(UserID)
        .get()
        .then((value) {
      setState(() {
        UserPic = value.data()!['userImage'];
      });
    });
  }

  void launchMap(double lati, double lngi) async {
    String lat = lati.toString();
    String lng = lngi.toString();
    final String url =
        "https://maps.google.com/maps/search/?api=1&query=$lat,$lng";

    final String encodedURL = Uri.encodeFull(url);
    if (await canLaunchUrlString(encodedURL)) {
      await launchUrlString(encodedURL);
    } else {
      throw 'Couldnt launch map';
    }
  }

  late Timer timerDistance;
  Timer? debounce;
  double lat = 37.42796133580664;
  double long = -122.085749655962;
  double zoom = 14.4746;
  int secondsUpdate = 1500;
  bool searchToggle = false;
  bool runAutomatic = false;
  bool locChosen = false;
  String hinttext = 'Search a Place';
  Set<Marker> myMarker = {};
  late Set<Circle> circles;

//Text Editing Controllers
  TextEditingController searchController = TextEditingController();

  //Initial map position on load
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;
  DetailsResult? startPosition;

  @override
  void initState() {
    changeMapStyle();

    BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(2, 2)),
            'assets/images/defaultProfilePic.png')
        .then((onValue) {
      myIcon = onValue;
    });

    getCurrentUser();
    super.initState();
    String Key = "AIzaSyCNSCKybMgjaxZO_O_uqZWZpGfxKHsJ700";
    googlePlace = GooglePlace(Key);
    Future.delayed(const Duration(seconds: 1), () {
      getLocationAndUpdate();
    });
    // ignore: prefer_collection_literals
    circles = Set.from([
      Circle(
        circleId: const CircleId('marker_1'),
        center: LatLng(lat, long),
        radius: 500,
      )
    ]);
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        setState(() {
          loggedInUser2 = loggedInUser.uid;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text(
              'Choose Location',
              style: TextStyle(fontFamily: font, color: Colors.black),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.black, size: 20.0),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.transparent,
            // Colors.white.withOpacity(0.1),
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          border: InputBorder.none,
                          hintText: hinttext,
                          suffixIcon: IconButton(
                            onPressed: () {
                              // getLocationAndUpdate();
                              // predictions.clear();

                              setState(() {
                                placeId = null;
                                searchToggle = false;
                                searchController.text = '';
                                predictions.clear();
                                FocusManager.instance.primaryFocus?.unfocus();
                                hinttext = "Search a Place";
                              });
                            },
                            icon: const Icon(Icons.close),
                          )),
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) {
                          _debounce!.cancel();
                        }
                        _debounce =
                            Timer(const Duration(milliseconds: 1000), () {
                          if (value.isNotEmpty) {
                            //places api
                            autoCompleteSearch(value);
                          } else {
                            //clear out the results
                            setState(() {
                              predictions = [];
                              startPosition = null;
                            });
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the location.';
                        }
                        return null;
                      })),
            ),
            Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Container(
                  margin:  EdgeInsets.only(left: screenWidth*0.06, top: screenHeight*0.03),       
                  child: const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Preview',
                        style: TextStyle(fontFamily: font, fontSize: 20),
                        textAlign: TextAlign.left),
                  ),
                ),
                Container(
                  margin:  EdgeInsets.only( 
                    bottom: screenHeight*0.02,   
                    top: screenHeight*0.06,   
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                    child: SizedBox(
                      height: screenHeight * 0.65, 
                      width: screenWidth * 0.9,
                      child: GoogleMap(
                        onTap: (argument) {
                          selectedMarker = null;
                          setState(() {});
                        },
                        mapType: MapType.normal,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: false,
                        zoomControlsEnabled: false,
                        markers: myMarker,
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(31.528955, 34.455524),
                          // zoom: 10,
                        ),
                        onMapCreated: (GoogleMapController c) {
                          c.setMapStyle(mapTheme);
                          _controller = c;
                        },
                        circles: circles,
                      ),
                    ),
                  ),
                ),
                Scrollbar(
                  thumbVisibility: true,
                  child: Container(
                    margin:  EdgeInsets.only(top: screenHeight*0.01,  ),         
                    decoration: BoxDecoration(
                        color: predictions.isNotEmpty
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(
                              size: screenHeight * 0.045,
                              Icons.pin_drop,
                              color: primary,
                            ),
                            title: Text(
                              predictions[index].description.toString(),
                              style: TextStyle(
                                  fontFamily: font,
                                  fontSize: screenHeight * 0.02),
                            ),
                            onTap: () async {
                              placeId = predictions[index].placeId!;
                              details = await googlePlace.details.get(placeId);

                              FocusManager.instance.primaryFocus?.unfocus();
                              hinttext =
                                  predictions[index].description.toString();
                              locChosen = true;

                              getLatAndLong(
                                  placeId: predictions[index].placeId!);
                            },
                          );
                        }),
                  ),
                ),
                Container(
                  margin:
                       EdgeInsets.only( bottom: screenHeight*0.03, top: screenHeight*0.62),        
                  decoration: BoxDecoration(
                      color: !locChosen ? Colors.grey : const Color(0xff0D6EF8),
                      border: Border.all(
                          color: !locChosen
                              ? Colors.grey
                              : const Color(0xff0D6EF8)),
                      borderRadius: BorderRadius.circular(10)),
                  width: MediaQuery.of(context).size.width * .4,
                  height: MediaQuery.of(context).size.height * .06,
                  child: Center(
                      child: InkWell(
                    onTap: (() {
                      Navigator.of(context).pop(details.result);
                    }),
                    child: Text('Choose Location',
                        style: TextStyle(
                            fontFamily: font,
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                            fontWeight: FontWeight.normal,
                            color: Colors.white)),
                  )),
                ),
              ],
            ),
          ])),
    );
  }

  Future<bool> determinePosition() async {
    LocationPermission permission;
    Position position;
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return false;
    } else if (permission == LocationPermission.deniedForever) {
      return false;
    }
    if (await Geolocator.isLocationServiceEnabled()) {
      position = await Geolocator.getCurrentPosition();
      if (!position.longitude.isNaN) {
        lat = position.latitude;
        long = position.longitude;
        return true;
      } else {
        return false;
      }
    } else {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!position.longitude.isNaN) {
        lat = position.latitude;
        long = position.longitude;
        return true;
      } else {
        return false;
      }
    }
  }

  getLocationAndUpdate() async {
    bool state = await determinePosition();
    if (state) {
      //myMarker.clear();

      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, long), zoom: zoom),
        ),
      );
      if (!runAutomatic) {
        runAutomatic = false;
        updateLocationAutomatic();
      }

      setState(() {});
    }
  }

  updateLocationAutomatic() {
    timerDistance = Timer.periodic(Duration(seconds: secondsUpdate), (Timer t) {
      getLocationAndUpdate();
    });
  }

  void getLatAndLong({required String placeId}) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=AIzaSyCNSCKybMgjaxZO_O_uqZWZpGfxKHsJ700'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      var data2 = json.decode(data);
      lat = data2['result']['geometry']['location']['lat'];
      long = data2['result']['geometry']['location']['lng'];
      myMarker.clear();
      myMarker.add(
        Marker(
          markerId: const MarkerId('marker_1'),
          position: LatLng(lat, long),
          icon: BitmapDescriptor.fromBytes(await getBytesFromAsset(
              'assets/images/defaultProfilePic.png', 150)),
        ),
      );

      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, long), zoom: zoom),
        ),
      );
    } else {}

    setState(() {
      searchToggle = false;
      searchController.text = '';
      predictions = [];
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  String mapTheme = '';
  changeMapStyle() {
    DefaultAssetBundle.of(context)
        .loadString('assets/map/MapAubergineStyle.json')
        .then((value) {
      mapTheme = value;
      setState(() {});
    });
  }
}
