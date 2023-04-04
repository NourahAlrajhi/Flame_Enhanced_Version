import 'package:firebase_core/firebase_core.dart';
import 'package:flame/Constants/constants.dart';
import 'package:flame/controller/user_cubit.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../firebase_options.dart';

addData(File img, String catg, String wholePlace, double place1, double place2,
    String rev, String tag, String ID) async {
  print("enterrrrr");
  //WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  String fileName = basename(img.path);

  //uploadImageToFirebase
  FirebaseStorage firebaseStorageRef = FirebaseStorage.instance;
  Reference ref = firebaseStorageRef.ref().child('images/$fileName');
  UploadTask uploadTask = ref.putFile(img);
  final TaskSnapshot downloadUrl = (await uploadTask);
  final String url = await downloadUrl.ref.getDownloadURL();
  print("enterrrrr22");

  var now = new DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd');
  String formattedDate = formatter.format(now);
  print(formattedDate); // 2022-10-24

  var id111 = Uuid().v4();
  /* Adding the post to sub collection in  user doc*/
  FirebaseFirestore.instance.collection('Users').doc(uId).get().then((value) {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(uId)
        .collection('MyPost')
        .doc(id111)
        .set({
      "Uid": ID,
      "category": catg,
      "photo": url,
      "placeName": wholePlace,
      "place": GeoPoint(place1, place2),
      //place
      "review": rev,
      "tag": tag,
      "UserPic": value.data()!['userImage'],
      'PostID': id111,
      'phone': value.data()!['phone'],
      'PostDate': formattedDate
    }).then((value) => UserCubit.get(context).getUserPost(USERID: uId));
    print("enterrrrr33");
  });

  /* Adding the post to  collection Post*/
  var id2222 = Uuid().v4();
  String POST;
  FirebaseFirestore.instance.collection('Users').doc(uId).get().then((value) {
    FirebaseFirestore.instance.collection('Post').doc(id111).set({
      "Uid": ID,
      "category": catg,
      "photo": url,
      "placeName": wholePlace,
      "place": GeoPoint(place1, place2),
      //place
      "review": rev,
      "tag": tag,
      "UserPic": value.data()!['userImage'],
      'PostID': id111,
      "phone": value.data()!['phone'],
      'PostDate': formattedDate
    });
    print("enterrrrr44");
  });

  FirebaseFirestore.instance.collection("Users").get().then((value5) {
    print("enter CheckingForavalibale friend 1");

    value5.docs.forEach((element3) {
      print("enter CheckingForavalibale friend 2");
      FirebaseFirestore.instance
          .collection("Users")
          .doc(element3.data()['id'])
          .collection("Friends")
          .get()
          .then((value6) {
        value6.docs.forEach((element4) {
          if (element4.data()['idFriend'] == uId) {
            print("enter CheckingForavalibale friend  3");

            FirebaseFirestore.instance
                .collection('Users')
                .doc(element3.data()['id'])
                .collection('FriendsPost')
                .doc(id111)
                .set({
              "Uid": ID,
              "category": catg,
              "photo": url,
              "placeName": wholePlace,
              "place": GeoPoint(place1, place2),
              //place
              "review": rev,
              "tag": tag,
              "UserPic": element4.data()['FriendsImage'],
              'PostID': id111,
              "phone": element4.data()['phoneFriend'],
              'PostDate': formattedDate
            });
          }
        });
      });
    });
  });
}

@override
void initState() {
  initState();
}
