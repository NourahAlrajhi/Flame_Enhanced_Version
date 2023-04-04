import 'dart:convert';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flame/Constants/constants.dart';
import 'package:flame/controller/user_cubit.dart';
import 'package:flame/view/editprofile/EditProfilePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'dart:developer';
import 'dart:io'; // for File
import 'package:file_picker/file_picker.dart';

class EditProfileHeader extends StatefulWidget {
  final File? newImage;

  const EditProfileHeader({Key? key, this.newImage}) : super(key: key);

  @override
  State<EditProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<EditProfileHeader> {
  String? userImage;
  Future? futureMethod;
  String userName = ""; //come backkkkkkkkkkkkkkkkkk
  bool isEdit = true;
  File? image;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
      return imageTemp;
      // String encodedImageString = base64.encode(File(image.path).readAsBytesSync().toList());
//Image.memory(base64.decode(encodedImageString)) to encoud
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

// dialoge to choose image
  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          title: const Text('Create a Recommendation',
              style: TextStyle(
                fontFamily: 'Tajawal',
              )),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                    )),
                onPressed: () {
                  pickImage(ImageSource.camera);
                  Navigator.pop(context);
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                    )),
                onPressed: () {
                  pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text(
                "Cancel",
                style: TextStyle(fontFamily: 'Tajawal', color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

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
      userImage = userImage;
      userName = userName;
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
            color: Color(0xFF0D6EF8),
            size: 20,
          ),
        ),
      );

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return buildSingleChildScrollView(context, screenWidth);
  }

  SingleChildScrollView buildSingleChildScrollView(
    BuildContext context,
    double screenWidth,
  ) {
    return SingleChildScrollView(
      child:
          //header
          Container(
        child: Container(
          child: Positioned(
            left: 0,
            right: 0,
            bottom: -120,
            child: Center(
              child: Stack(clipBehavior: Clip.none, children: [
                Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      boxShadow: [
                        BoxShadow(color: Colors.white, spreadRadius: 4),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CachedNetworkImage(
                        imageUrl: userImage.toString(),
                      ),
                      // Image.network(
                      //   userImage == null || userImage == 'null'
                      //       ? 'https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2FdefaultProfilePic.png?alt=media&token=6b1583e9-76ff-4f24-a518-c2a7062cbb29'
                      //       : userImage!,
                      // ),
                    )),
                InkWell(
                    onTap: () {
                      _selectImage(context);
                    },
                    child: Container(
                        child: Positioned(
                            bottom: -7,
                            right: -7,
                            child: buildEditIcon(
                              Color.fromARGB(7, 8, 9, 88),
                            )))),
                Container(
                  margin: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * .1,
                    top: MediaQuery.of(context).size.height * 0.05,
                    left: MediaQuery.of(context).size.width * .1,
                  ),
                  child: InkWell(
                    onTap: () {
                      // bool valid = validation();
                      // if(valid){SignupWithPhone(context);}
                      UserCubit.get(context).updateProfileImage(userImage!);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xffFF7F1D),
                          border: Border.all(color: Color(0xffFF7F1D)),
                          borderRadius: BorderRadius.circular(10)),
                      width: 331,
                      height: 54,
                      child: Center(
                        child: Text('Save »',
                            style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Future getData() async {
    await GetNameandPic();
  }
}
