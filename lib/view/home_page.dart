// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_marker/marker_icon.dart';
import 'package:flame/Constants/constants.dart';
import 'package:flame/Constants/theme.dart';
import 'package:flame/controller/user_cubit.dart';
import 'package:flame/model/Recommendation.dart';
import 'package:flame/model/categoriesModel.dart';
import 'package:flame/view/Filter/Filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/Constants/color.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, DetailsResult? VALUELOCATION}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

Color? categColor;
List<CategoriesModel> categories = [];
CategoriesModel? selectedCategory;
String? SAVESTATUS;
bool ISSaved = true;
bool filterOn = true;

class _HomePageState extends State<HomePage> {
  // Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _controller;
  late User loggedInUser;
  String? loggedInUser2;
  final _auth = FirebaseAuth.instance;
  Recommendation? selectedMarker;
  String FilledSave = "assets/icons/saved.svg";
  String UnFilledSave = "assets/icons/unsaved.svg";
  Set<Marker> markers = {};

  getAllCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("Category").get();
    categories = snapshot.docs.map((e) => CategoriesModel.fromJson(e)).toList();
    setState(() {});
  }

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

  Color Choosecolor({required String category}) {
    for (int i = 0; i < categories.length; i++) {
      if (categories[i].name == category) {
        categColor =
            Color(int.parse(categories[i].color!.replaceAll('#', '0x')));
      }
    }
    return categColor!;
  }

  void CheckIfExist({required String POSTID, required String USERID}) {
    ISSaved = true;
    FirebaseFirestore.instance
        .collection("Users")
        .doc(USERID)
        .collection("MySavedPost")
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (element.data()["PostID"] == POSTID) {
          setState(() {
            ISSaved = false;
          });
        }
      }
    });
  }

  void initMarker(specify, specifyId) async {
    var markerIdVal = specifyId;
    final MarkerId markerId = MarkerId(markerIdVal);
    double lat = specify['place'].latitude;
    double lng = specify['place'].longitude;
    String photo = specify['photo'];
    String placeName = specify['placeName'];
    String review = specify['review'];
    String UserPhoto = specify['UserPic'];
    String tag = specify['tag'];
    String categoryName = specify['category'];
    String UserID = specify['Uid'];
    String POSTID = specify['PostID'];
    String phoneNumber = specify['phone'];
    //  addUserPicOnMap(UserID: UserID);

    //print(UserPic);
    //place colors
    String category = specify['category'];

    Marker marker = Marker(
        position: LatLng(specify['place'].latitude, specify['place'].longitude),
        icon: await MarkerIcon.downloadResizePictureCircle(
            // ignore: prefer_if_null_operators
            UserPhoto == null
                ? "https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2FdefaultProfilePic.png?alt=media&token=cb0d6f13-05c0-41c6-bb5a-d43f741b9adf"
                : UserPhoto,
            size: 150,
            addBorder: true,
            borderColor: Choosecolor(category: category),
            borderSize: 20),
        onTap: () {
          //    getRecCard(photo, placeName, review, tag, lat, lng);
          selectedMarker = Recommendation(photo, review, tag,
              GeoPoint(lat, lng), placeName, categoryName, POSTID, phoneNumber);

          setState(() {});
          CheckIfExist(POSTID: selectedMarker!.PostIDDDDD, USERID: uId);
        },
        markerId: markerId);

    setState(() {
      myMarker.add(marker);
    });
  }

  getMarkerData() async {
    if (filterByFriend.length <= 1 && filterByTag.length <= 1) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(uId)
          .collection('FriendsPost')
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          for (int i = 0; i < value.docs.length; i++) {
            initMarker(value.docs[i].data(), value.docs[i].id);
          }
        }
      });
    } else if (filterByTag.length > 1) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(uId)
          .collection('FriendsPost')
          .get()
          .then((value) {
        value.docs.forEach((element) {
          for (int i = 0; i < filterByTag.length; i++) {
            for (int j = 0; j < value.docs.length; j++) {
              if (element.data()['category'] == filterByTag.elementAt(i)) {
                initMarker(element.data(), element.id);
              }
            }
          }
        });
      });
    } else if (filterByFriend.length > 1) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(uId)
          .collection('FriendsPost')
          .get()
          .then((value) {
        for (var element in value.docs) {
          for (int i = 0; i < filteredFriends.length; i++) {
            for (int j = 0; j < value.docs.length; j++) {
              if (element.data()['Uid'] == filteredFriends.elementAt(i)) {
                initMarker(element.data(), element.id);
              }
            }
          }
        }
      });
    }
  }

  getUserPhoto() async {
    FirebaseFirestore.instance.collection('Users').get().then((value) {
      if (value.docs.isNotEmpty) {
        for (int i = 0; i < value.docs.length; i++) {
          if (value.docs[i].data()['id'] == loggedInUser2) {
            initMarker(value.docs[i].data(), value.docs[i].id);
          } else {
            FirebaseFirestore.instance
                .collection("Users")
                .doc(uId) //also the other friend
                .collection("Friends")
                .get()
                .then((value2) {
              if (value2.docs.isNotEmpty) {
                for (int j = 0; j < value2.docs.length; j++) {
                  if (value.docs[i].data()['id'] ==
                      value2.docs[j].data()['idFriend']) {
                    initMarker(value.docs[i].data(), value.docs[i].id);
                  }
                }
              }
            });
          }
        }
      }
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
  int secondsUpdate = 80;
//Toggling UI as we need;
  bool searchToggle = false;
  bool runAutomatic = false;
  Set<Marker> myMarker = {};
  late Set<Circle> circles;

//Text Editing Controllers
  TextEditingController searchController = TextEditingController();

  //Initial map position on load
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  DetailsResult? startPosition;

  /// change map theme function
  String mapTheme = "";
  changeMapStyle() {
    DefaultAssetBundle.of(context)
        .loadString('assets/map/MapAubergineStyle.json')
        .then((value) {
      mapTheme = value;
      setState(() {});
    });
  }

  @override
  void initState() {
    getAllCategories();
    Future.delayed(Duration(milliseconds: 600), () {
      getMarkerData();
    });

    getCurrentUser();
    super.initState();
    String Key = "AIzaSyCNSCKybMgjaxZO_O_uqZWZpGfxKHsJ700";
    googlePlace = GooglePlace(Key);
    changeMapStyle();
    Future.delayed(const Duration(seconds: 1), () {
      getLocationAndUpdate();
    });
  }

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );

  Widget buildEditIcon(Color color) => buildCircle(
        color: kBackgroundColor,
        all: 3,
        child: buildCircle(
          color: color,
          all: 4,
          child: Icon(
            Icons.close,
            color: Colors.red,
            size: 15,
          ),
        ),
      );
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
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: <Widget>[
                SizedBox(
                  height: screenHeight,
                  width: screenWidth,
                  child: GoogleMap(
                    onTap: (argument) {
                      selectedMarker = null;
                      setState(() {});
                    },
                    mapType: MapType.normal,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    markers: myMarker,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(31.528955, 34.455524),
                      // zoom: 10,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      controller.setMapStyle(mapTheme);
                      _controller = controller;
                    },
                    // circles: circles,
                  ),
                ),
                ///////////////////////////////////////////////////////deatails card
                if (selectedMarker != null)
                  Positioned(
                      bottom: 50,
                      right: 0,
                      left: 0,
                      child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Container(
                              height: MediaQuery.of(context).size.height * .20,
                              width: MediaQuery.of(context).size.height * .12,
                              margin: const EdgeInsets.all(8),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .25,
                                      width: 100,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            bottomLeft: Radius.circular(15)),
                                        child: Image.network(
                                          selectedMarker!.photo,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .12,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .15,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Text(
                                                      selectedMarker!.title,
                                                      style: const TextStyle(
                                                          fontFamily: font,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  SizedBox(
                                                    // color: Colors.amber,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.55,
                                                    height: 43,
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      child: Text(
                                                          selectedMarker!
                                                              .review,
                                                          style:
                                                              const TextStyle(
                                                            fontFamily: font,
                                                          )),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 12,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        height: 25,
                                                        // decoration: BoxDecoration(
                                                        //   border: Border.all(
                                                        //       color: lightgrey),
                                                        //   borderRadius:
                                                        //       BorderRadius.circular(
                                                        //           10),
                                                        // ),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              SvgPicture.asset(
                                                                "assets/icons/subtag.svg",
                                                                color: Choosecolor(
                                                                    category:
                                                                        selectedMarker!
                                                                            .category),
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.025,
                                                              ),
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              Text(
                                                                selectedMarker!
                                                                    .tag,
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        font,
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                            ]),
                                                      ),
                                                      // This might be done when pressing on saved button( selectedMarker!.PostIDDDDD,)
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  child: InkWell(
                                                    onTap:
                                                        (ISSaved /*SAVESTATUS == UnFilledSave*/
                                                            ? () {
                                                                UserCubit.get(
                                                                        context)
                                                                    .GetSavedPost(
                                                                        POSTID:
                                                                            selectedMarker!.PostIDDDDD);
                                                                Timer(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            500),
                                                                    () {
                                                                  setState(() {
                                                                    CheckIfExist(
                                                                        POSTID: selectedMarker!
                                                                            .PostIDDDDD,
                                                                        USERID:
                                                                            uId);
                                                                  });
                                                                });
                                                              }
                                                            : () {
                                                                UserCubit.get(
                                                                        context)
                                                                    .deletUserSavedPost(
                                                                        IDPost: selectedMarker!
                                                                            .PostIDDDDD,
                                                                        USERID:
                                                                            uId);

                                                                setState(() {
                                                                  CheckIfExist(
                                                                      POSTID: selectedMarker!
                                                                          .PostIDDDDD,
                                                                      USERID:
                                                                          uId);
                                                                });
                                                              }),
                                                    splashColor: background,
                                                    child: ISSaved
                                                        ? SvgPicture.asset(
                                                            UnFilledSave,
                                                            width: 24,
                                                            height: 27,
                                                          )
                                                        : SvgPicture.asset(
                                                            FilledSave,
                                                            width: 24,
                                                            height: 27,
                                                          ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                InkWell(
                                                  onTap: (() {
                                                    messageFriend(
                                                        selectedMarker!.number,
                                                        selectedMarker!.title,
                                                        selectedMarker!.photo);
                                                  }),
                                                  child: SvgPicture.asset(
                                                    "assets/icons/message-2.svg",
                                                    width: 22,
                                                    height: 24,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 8,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              )))),

                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                        onTap: () {
                          showCupertinoModalBottomSheet(
                            context: context,
                            // expand: true,
                            isDismissible: true,
                            topRadius: const Radius.circular(20),
                            builder: (context) => const Filter(),
                            backgroundColor: Colors.transparent,
                          );
                          setState(() {
                            filterByTag = filterByTag;
                          });
                        },
                        child: Stack(clipBehavior: Clip.none, children: [
                          Container(
                              height: 55,
                              width: 55,
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height * 0.1,
                                  right: 18),
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(
                                Icons.filter_alt_outlined,
                                color: Color(0xff0D6EF8),
                                size: 30,
                              )),
                          if (filterByFriend.length > 1 ||
                              filterByTag.length > 1)
                            Container(
                                child: Positioned(
                                    bottom: 30,
                                    left: -10,
                                    child: InkWell(
                                        onTap: () {
                                          filterByFriend = {''};
                                          filterByTag = {''};
                                          filteredFriends = {''};
                                          getMarkerData();
                                        },
                                        child: buildEditIcon(
                                          const Color.fromARGB(7, 8, 9, 88),
                                        ))))
                        ])),
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () async {
                        getLocationAndUpdate();
                      },
                      child: Container(
                        height: 55,
                        width: 55,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.19,
                            right: 18),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(
                          Icons.gps_fixed_outlined,
                          color: Color(0xff0D6EF8),
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
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
        print('lat = $lat , long = $long');
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
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, long), zoom: zoom),
        ),
      );
      if (!runAutomatic) {
        runAutomatic = true;
        updateLocationAutomatic();
      }
      // ignore: prefer_collection_literals
      circles = Set.from([
        Circle(
          circleId: const CircleId('marker_1'),
          center: LatLng(lat, long),
          radius: 700,
          strokeWidth: 1,
          fillColor: Colors.blue.shade100.withOpacity(0.5),
          strokeColor: Colors.blue.shade100.withOpacity(0.9),
        )
      ]);
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
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, long), zoom: zoom),
        ),
      );
    } else {}
  }

  void messageFriend(String Recpiant, String RecommendationPlace,
      dynamic RecommendationImage) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      Uri SMSURri = Uri(
          scheme: 'sms',
          path: '$Recpiant',
          queryParameters: <String, String>{
            'body': Uri.encodeComponent('Hi!'),
          });

      String uri = SMSURri.toString().replaceAll('?', '&');
      launchUrlString(uri);
    } else {
      Uri SMSURri = Uri(
          scheme: 'sms',
          path: '$Recpiant',
          queryParameters: <String, String>{
            'body': Uri.encodeComponent(
                'Just came across your flame!\nHow was $RecommendationPlace? '),
          });

      try {
        launchUrl(SMSURri, mode: LaunchMode.platformDefault);
      } catch (error) {
        print(error);
      }
    }
  }
}
