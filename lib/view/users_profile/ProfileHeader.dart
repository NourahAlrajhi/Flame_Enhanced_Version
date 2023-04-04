// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flame/Constants/color.dart';
import 'package:flame/Constants/constants.dart';
import 'package:flame/Constants/theme.dart';
import 'package:flame/view/editprofile/EditProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String? userImage;
  Future? futureMethod;
  String userName = ""; //come backkkkkkkkkkkkkkkkkk
  bool isEdit = false;

  Future GetNameandPic() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uId)
        .get()
        .then((value) {
      userImage = value.data()!['userImage'];
      userName = value.data()!['fullName'];
    });
    setState(() {
      // userImage = userImage;
      // userName = userName;
    });
  }

  @override
  void initState() {
    // GetNameandPic();
    futureMethod = getData();
    super.initState();
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
          all: 8,
          child: Icon(
            isEdit ? Icons.add_a_photo : Icons.edit,
            color: Buttonblue,
            size: 20,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String firstLayer = 'assets/images/firstLayer.svg';
    String secondLayer = 'assets/images/secondLayer.svg';
    String thirdLayer = 'assets/images/thirdLayer.svg';

//first layer
    final Widget headerFirstLayer = SvgPicture.asset(
      firstLayer,
      semanticsLabel: 'frst layer',
      color: const Color.fromARGB(255, 244, 186, 64),
      width: screenWidth,
    );
//second layer
    final Widget headerSecondLayer = SvgPicture.asset(
      secondLayer,
      semanticsLabel: 'second layer',
      color: const Color.fromARGB(255, 255, 127, 29),
      width: screenWidth,
    );
//third layer
    final Widget headerThirdLayer = SvgPicture.asset(
      secondLayer,
      semanticsLabel: 'frst layer',
      color: const Color.fromARGB(255, 255, 115, 0),
      width: screenWidth,
    );
    return futureBody(screenWidth, screenHeight, headerFirstLayer,
        headerSecondLayer, headerThirdLayer);
  }

  SingleChildScrollView buildSingleChildScrollView(
      double screenWidth,
      double screenHeight,
      Widget headerFirstLayer,
      Widget headerSecondLayer,
      Widget headerThirdLayer) {
    return SingleChildScrollView(
      child:
          //header
          Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: screenWidth,
            child: headerFirstLayer,
          ),
          Positioned(
            width: screenWidth,
            bottom: -80,
            child: headerSecondLayer,
          ),
          Positioned(
            width: screenWidth,
            bottom: -150,
            child: headerThirdLayer,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -120,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const EditProfilePage()),
                );
              },
              child: Center(
                child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      boxShadow: [
                        BoxShadow(color: Colors.white, spreadRadius: 4),
                      ],

                      // edit profile option
                    ),
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        userImage == null || userImage == 'null'
                            ? 'https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2FdefaultProfilePic.png?alt=media&token=cb0d6f13-05c0-41c6-bb5a-d43f741b9adf'
                            : userImage.toString(),
                      ),
                    )),
              ),
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: -150,
              child: Center(
                child: Text(
                  userName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.06,
                      fontFamily: font),
                  textAlign: TextAlign.center,
                ),
              ))
        ],
      ),
    );
  }

  Widget futureBody(screenWidth, screenHeight, headerFirstLayer,
      headerSecondLayer, headerThirdLayer) {
    return FutureBuilder(
        future: futureMethod,
        // ignore: missing_return
        builder: (context, snapshots) {
          if (snapshots.hasError) {
            return const Text(
              "",
            );
          }
          switch (snapshots.connectionState) {
            case ConnectionState.waiting:
              return Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "",
                  )
                ],
              ));

            case ConnectionState.done:
              // EasyLoading.dismiss();
              return buildSingleChildScrollView(screenWidth, screenHeight,
                  headerFirstLayer, headerSecondLayer, headerThirdLayer);
            case ConnectionState.none:
              break;
            case ConnectionState.active:
              break;
          }
          return const Text(
            "",
          );
        });
  }

  Future getData() async {
    await GetNameandPic();
  }
}
