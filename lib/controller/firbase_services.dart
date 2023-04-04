import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/model/categoriesModel.dart';
import 'package:flame/Constants/global.dart';
import 'package:flutter/material.dart';

class FirebaseServices {
  static getAllCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("Category").get();
    Global.categories =
        snapshot.docs.map((e) => CategoriesModel.fromJson(e)).toList();
  }

  static getMarkerData(BuildContext context, String loggedInUser) async {
    FirebaseFirestore.instance.collection('Post').get().then((value) {
      if (value.docs.isNotEmpty) {
        for (int i = 0; i < value.docs.length; i++) {
          // if (value.docs[i].data()['Uid'] == loggedInUser2) {
          // initMarker(value.docs[i].data(), value.docs[i].id);
          // } else {
          FirebaseFirestore.instance
              .collection("Users")
              .doc(loggedInUser) //also the other friend
              .collection("Friends")
              .get()
              .then((value2) {
            if (value2.docs.isNotEmpty) {
              for (int j = 0; j < value2.docs.length; j++) {
                if (value.docs[i].data()['Uid'] ==
                    value2.docs[j].data()['idFriend']) {
                  Global.initMarker(
                      value.docs[i].data(), value.docs[i].id, context);
                }
              }
            }
          });
          //}
        }
      }
    });
  }

  ///no use in home page
  /*static getUserPhoto(BuildContext context,String loggedInUser) async {
    FirebaseFirestore.instance.collection('Users').get().then((value) {
      if (value.docs.isNotEmpty) {
        for (int i = 0; i < value.docs.length; i++) {
          if (value.docs[i].data()['id'] == loggedInUser) {
            Global.initMarker(value.docs[i].data(), value.docs[i].id,context);
          } else {
            FirebaseFirestore.instance
                .collection("Users")
                .doc(loggedInUser) //also the other friend
                .collection("Friends")
                .get()
                .then((value2) {
              if (value2.docs.isNotEmpty) {
                for (int j = 0; j < value2.docs.length; j++) {
                  if (value.docs[i].data()['id'] ==
                      value2.docs[j].data()['idFriend']) {
                    Global.initMarker(value.docs[i].data(), value.docs[i].id,context);
                  }
                }
              }
            });
          }
        }
      }
    });
  }*/

}
