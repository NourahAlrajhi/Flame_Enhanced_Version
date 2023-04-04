import 'dart:async';
import 'package:flame/Constants/color.dart';
import 'package:flame/controller/firbase_services.dart';
import 'package:flame/Constants/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:custom_marker/marker_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flame/model/categoriesModel.dart';

import '../../Constants/constants.dart';

class ProfileMap extends StatefulWidget {
  const ProfileMap({Key? key, DetailsResult? VALUELOCATION}) : super(key: key);

  @override
  State<ProfileMap> createState() => _ProfileMapState();
}

class _ProfileMapState extends State<ProfileMap> {
  late GoogleMapController _controller;

  final _auth = FirebaseAuth.instance;
  String mapTheme = "";
  CategoriesModel? selectedCategory;

  void initMarker(specify, specifyId) async {
    var markerIdVal = specifyId;
    final MarkerId markerId = MarkerId(markerIdVal);

    String category = specify['category'];
    Color? categColor;

    for (int i = 0; i < Global.categories.length; i++) {
      if (Global.categories[i].name == category) {
        setState(() {
          categColor = Color(
              int.parse(Global.categories[i].color!.replaceAll('#', '0x')));
        });
      }
    }
    Marker marker = Marker(
        position: LatLng(specify['place'].latitude, specify['place'].longitude),
        icon: await MarkerIcon.downloadResizePictureCircle(specify['photo'],
            size: 150,
            addBorder: true,
            borderColor: categColor!,
            borderSize: 15),
        markerId: markerId);

    setState(() {
      myMarker.add(marker);
    });
  }

  getMarkerData(String loggedInUser) async {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(uId)
        .collection('MyPost')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        for (int i = 0; i < value.docs.length; i++) {
          initMarker(value.docs[i].data(), value.docs[i].id);
        }
      }
    });
  }

  Future<void> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await getMarkerData(user.uid);

        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  late Timer timerDistance;

  int secondsUpdate = 1500;

  bool runAutomatic = false;
  Set<Marker> myMarker = {};

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  DetailsResult? startPosition;

  @override
  void initState() {
    changeMapStyle();
    FirebaseServices.getAllCategories();
    getCurrentUser();
    super.initState();
    String Key = "AIzaSyCNSCKybMgjaxZO_O_uqZWZpGfxKHsJ700";
    googlePlace = GooglePlace(Key);
    Future.delayed(const Duration(seconds: 1), () {
      getLocationAndUpdate();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: height * 0.01),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: height * .2,
                    width: 90,
                    child: Stack(children: [
                      GoogleMap(
                        mapType: MapType.normal,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        markers: myMarker,
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(31.528955, 34.455524),
                        ),
                        onMapCreated: (GoogleMapController c) {
                          c.setMapStyle(mapTheme);
                          _controller = c;
                        },
                        // ignore: prefer_collection_literals
                        gestureRecognizers: Set()
                          ..add(Factory<EagerGestureRecognizer>(
                              () => EagerGestureRecognizer())),
                        // circles: circles,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () async {
                              getLocationAndUpdate();
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              margin:
                                  const EdgeInsets.only(bottom: 20, right: 20),
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(
                                Icons.gps_fixed,
                                color: Buttonblue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  )),
            ],
          ),
        ),
      )
    ]);
  }

  getLocationAndUpdate() async {
    bool state = await Global.determinePosition();
    if (state) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(Global.lat, Global.long), zoom: Global.zoom),
        ),
      );
      if (!runAutomatic) {
        runAutomatic = true;
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

  changeMapStyle() {
    DefaultAssetBundle.of(context)
        .loadString('assets/map/MapAubergineStyle.json')
        .then((value) {
      mapTheme = value;
      setState(() {});
    });
  }
}
