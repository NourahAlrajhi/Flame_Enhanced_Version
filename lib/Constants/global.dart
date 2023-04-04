import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_marker/marker_icon.dart';
import 'package:flame/constants/constants.dart';
import 'package:flame/controller/user_cubit.dart';
import 'package:flame/model/Recommendation.dart';
import 'package:flame/model/categoriesModel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class Global {
  static String mapStylePath = "assets/map/MapAubergineStyle.json";
  static List<CategoriesModel> categories = [];
  static Recommendation? selectedMarker;
  static String? SAVESTATUS;
  static Set<Marker> myMarker = {};
  static double lat = 37.42796133580664;
  static double long = -122.085749655962;
  static double zoom = 14.4746;

  static void initMarker(specify, specifyId, BuildContext context) async {
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

    print("22222222222222222222");
    print("!!!!!!!!!!!! ${lat} ${lng}");
    print("22222222222222222222");
    //place colors
    String category = specify['category'];
    Color? categColor;

    for (int i = 0; i < Global.categories.length; i++) {
      if (Global.categories[i].name == category) {
        categColor =
            Color(int.parse(Global.categories[i].color!.replaceAll('#', '0x')));
      }
    }
    /*   if (category == "Resturants") {
      setState(() {
        categColor = Color(0xffF96A59);
      });
    } else if (category == "Things to Do") {
      setState(() {
        categColor = Color(0xff77C89F);
      });
    } else if (category == "Shopping") {
      setState(() {
        categColor = Color(0xffFFB700);
      });
    } else if (category == "Things to See") {
      setState(() {
        categColor = Color(0xff73B5EC);
      });
    } else if (category == "Coffee Places") {
      setState(() {
        categColor = Color(0xffFFE576);
      });
    } else if (category == "Lodging") {
      setState(() {
        categColor = Color(0xffECCAE7);
      });
    }*/

    print("333333333333333333333333");
    // print(UserPic);
    print("3333333333333333333333");
    Marker marker = Marker(
        position: LatLng(specify['place'].latitude, specify['place'].longitude),
        icon: await MarkerIcon.downloadResizePictureCircle(
            UserPhoto == null
                ? "https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2Fimage_picker472907647.png?alt=media&token=d81258c2-f0ff-4f4f-be31-f9c986478de9"
                : UserPhoto,
            size: 150,
            addBorder: true,
            borderColor: categColor!,
            borderSize: 20),
        onTap: () {
          Fluttertoast.showToast(msg: "Clicked");
          //    getRecCard(photo, placeName, review, tag, lat, lng);
          selectedMarker = Recommendation(photo, review, tag,
              GeoPoint(lat, lng), placeName, categoryName, POSTID, phoneNumber);
          //   SAVESTATUS = UserCubit.get(context)
          // .CheckIfExist(POSTID: selectedMarker!.PostIDDDDD, USERID: uId);
        },
        markerId: markerId);
    myMarker.add(marker);
    // print("MARKERS ${myMarker}");
  }

  static Future<bool> determinePosition() async {
    LocationPermission permission;
    Position position;
    permission = await Geolocator.requestPermission();
    print(permission);
    if (permission == LocationPermission.denied) {
      return false;
    } else if (permission == LocationPermission.deniedForever) {
      return false;
    }
    if (await Geolocator.isLocationServiceEnabled()) {
      position = await Geolocator.getCurrentPosition();
      if (!position.longitude.isNaN) {
        Global.lat = position.latitude;
        Global.long = position.longitude;
        print('lat = ${Global.lat} , long = ${Global.long}');
        return true;
      } else {
        return false;
      }
    } else {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!position.longitude.isNaN) {
        Global.lat = position.latitude;
        Global.long = position.longitude;
        print('lat = ${Global.lat} , long = ${Global.long}');
        return true;
      } else {
        return false;
      }
    }
  }

  static Future<BitmapDescriptor> getMarkerIcon(
      String imagePath, Size size) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 2);

    final Paint shadowPaint = Paint()..color = Colors.white;
    final double shadowWidth = 10.0;

    final Paint borderPaint = Paint()..color = Colors.blueAccent;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, size.width, size.height),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(shadowWidth, shadowWidth,
              size.width - (shadowWidth * 2), size.height - (shadowWidth * 2)),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());

    // Convert image to bytes
    final ByteData? byteData =
        await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? uint8List = byteData?.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List!);
  }

  static void getLatAndLong(
      {required String placeId,
      required GoogleMapController controller}) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=AIzaSyCNSCKybMgjaxZO_O_uqZWZpGfxKHsJ700'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      var data2 = json.decode(data);
      Global.lat = data2['result']['geometry']['location']['lat'];
      Global.long = data2['result']['geometry']['location']['lng'];
      //myMarker.clear();
      // myMarker.add(
      // Marker(
      //   markerId: MarkerId('marker_1'),
      // position: LatLng(lat, long),
      //  icon: await getMarkerIcon('', Size(50, 50))),
      // );
      // circles = Set.from([
      //  Circle(
      //  circleId: CircleId('marker_1'),
      //center: LatLng(lat, long),
      // radius: 700,
      // strokeWidth: 1,
      //fillColor: Colors.blue.shade100.withOpacity(0.5),
      //strokeColor: Colors.blue.shade100.withOpacity(0.9),
      // )
      //]);
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(Global.lat, Global.long), zoom: Global.zoom),
        ),
      );
    } else {
      print(response.reasonPhrase);
    }
  }
}
