import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flame/view/users_profile/Notifications.dart';
import 'package:flame/view/editprofile/EditProfileHeader.dart';
import 'package:flame/view/editprofile/TextFieldWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../Constants/constants.dart';
import '../../controller/user_cubit.dart';
import 'package:path/path.dart';

class EditProfilePage extends StatefulWidget {
  final File? newImage;

  const EditProfilePage({Key? key, this.newImage}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? userImage;
  String? dummyImage;
  Future? futureMethod;
  String userName = "";
  String NewuserName = ""; //come backkkkkkkkkkkkkkkkkk
  bool isEdit = true;
  File? image;
  TextEditingController controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  ///check image or name changed or not.
  checkChanges() {
    return dummyImage != userImage ||
        (userName != controller.text && controller.text.isNotEmpty);
  }

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
      String fileName = basename(imageTemp.path);
      FirebaseStorage firebaseStorageRef = FirebaseStorage.instance;
      Reference ref = firebaseStorageRef.ref().child('images/$fileName');
      UploadTask uploadTask = ref.putFile(imageTemp);
      final TaskSnapshot downloadUrl = (await uploadTask);
      dummyImage = await downloadUrl.ref.getDownloadURL();
      setState(() {});
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
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          title: const Text('Upload Image',
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

  @override
  void initState() {
    // GetNameandPic();
    /*futureMethod = */ getData();
    super.initState();
    // controller = TextEditingController();
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
            color: const Color(0xFF0D6EF8),
            size: 20,
          ),
        ),
      );

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return buildBody(context, screenWidth);
  }

  Future GetNameandPic() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uId)
        .get()
        .then((value) {
      userImage = value.data()!['userImage'];
      dummyImage = value.data()!['userImage'];
      userName = value.data()!['fullName'];
      controller.text = value.data()!['fullName'];
    });
    setState(() {
      // userImage = userImage;
      // userName = userName;
    });
  }

  @override
  Widget buildBody(BuildContext context, double screenWidth) {
    return BlocConsumer<UserCubit, UserState>(listener: (context, state) {
      // TODO: implement listener
    }, builder: (context, state) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Scaffold(
            extendBodyBehindAppBar: false,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                    fontFamily: 'Tajawal', fontSize: 20.0, color: Colors.black),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
                onPressed: () {
                  if (checkChanges())
                    showEditAlertDialog(context);
                  else
                    Navigator.pop(context);
                },
                //insert validation method
              ),

              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              // ),
              backgroundColor: Colors.transparent,
              // Colors.white.withOpacity(0.1),
              elevation: 0,
            ),

            //header and body
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Container(
                        child: Center(
                          child: Stack(clipBehavior: Clip.none, children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: CachedNetworkImage(
                                imageUrl: dummyImage.toString(),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                    child: SizedBox(
                                        height: 15,
                                        width: 15,
                                        child: CircularProgressIndicator(
                                          color: Color(0xffFF7F1D),
                                        ))),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),

                            // Container(
                            //     width: 100,
                            //     height: 100,
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.all(Radius.circular(100)),
                            //       boxShadow: [
                            //         BoxShadow(color: Colors.white, spreadRadius: 4),
                            //       ],
                            //     ),
                            //     child: CircleAvatar(
                            //       backgroundImage:
                            //       CachedNetworkImageProvider(userImage.toString(),),
                            //
                            //       // NetworkImage(userImage == null || userImage == 'null'
                            //       //       ? 'https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2FdefaultProfilePic.png?alt=media&token=6b1583e9-76ff-4f24-a518-c2a7062cbb29'
                            //       //       : userImage!),
                            //
                            //     )),
                            Container(
                                child: Positioned(
                                    bottom: -7,
                                    right: -7,
                                    child: InkWell(
                                        onTap: () {
                                          _selectImage(context);
                                        },
                                        child: buildEditIcon(
                                          const Color.fromARGB(7, 8, 9, 88),
                                        )))),
                          ]),
                        ),
                      ),

                      // Container(
                      //    margin: EdgeInsets.only(right: MediaQuery.of(context).size.width*.05, top:  MediaQuery.of(context).size.height*0.03,left: MediaQuery.of(context).size.width*.05, ),
                      //   child: TextFieldWidget(
                      //     label: 'Display Name',
                      //     text: userName,
                      //     onChanged: (name) {},
                      //     hinttext: userName,
                      //   ),
                      // ),
                      Container(
                          margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * .05,
                            top: MediaQuery.of(context).size.height * 0.03,
                            left: MediaQuery.of(context).size.width * .05,
                          ),
                          child: Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    ('Display Name'),
                                    style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .009),
                                  TextFormField(
                                    maxLength: 20,
                                    onChanged: (newText) {
                                      NewuserName = newText;
                                    },
                                    controller: controller,
                                    decoration: InputDecoration(
                                      hintText: "Enter Name",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Name can not be empty";
                                      }
                                      if (!RegExp(r'^[a-z A-z]+$')
                                          .hasMatch(value)) {
                                        return "Name should only contain letters";
                                      }
                                      if (value.length > 20) {
                                        return "Name is too long";
                                      }
                                      if (value.length <= 2) {
                                        return "Name is too short";
                                      } else {
                                        return null;
                                      }
                                    },
                                    maxLines: 1,
                                  ),
                                ],
                              ))),
                      Container(
                        margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * .1,
                          top: MediaQuery.of(context).size.height * 0.03,
                          left: MediaQuery.of(context).size.width * .1,
                        ),
                        child: InkWell(
                          onTap: !checkChanges()
                              ? () {}
                              : () {
                                  if (NewuserName.isNotEmpty) {
                                    if (formKey.currentState!.validate()) {
                                      UserCubit.get(context)
                                          .updateDisplayName(NewuserName);
                                      UserCubit.get(context)
                                          .updateProfileImage(dummyImage!);

                                      Navigator.pop(context);
                                    }
                                  } else {
                                    UserCubit.get(context)
                                        .updateProfileImage(dummyImage!);
                                    Navigator.pop(context);
                                  }
                                },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                                color: !checkChanges()
                                    ? Colors.grey
                                    : const Color(0xff0D6EF8),
                                border: Border.all(
                                    color: !checkChanges()
                                        ? Colors.grey
                                        : const Color(0xff0D6EF8)),
                                borderRadius: BorderRadius.circular(10)),
                            width: MediaQuery.of(context).size.width * .05,
                            height: MediaQuery.of(context).size.height * .07,
                            child: Center(
                              child: Text('Save',
                                  style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.055,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Image.asset(
                  "assets/sun.png",
                  width: MediaQuery.of(context).size.width,
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Future getData() async {
    await GetNameandPic();
  }

  showEditAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel",
          style: TextStyle(
            fontFamily: 'Tajawal',
          )),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget quit = TextButton(
      child: Text("Discard",
          style: TextStyle(fontFamily: 'Tajawal', color: Colors.red)),
      onPressed: () {
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text("Are you sure you want to discard your changes?",
          style: TextStyle(
            fontFamily: 'Tajawal',
          )),
      actions: [
        quit,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
