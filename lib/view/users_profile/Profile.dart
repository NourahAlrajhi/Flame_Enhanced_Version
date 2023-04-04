import 'dart:async';

import 'package:flame/Constants/theme.dart';
import 'package:flame/view/users_profile/Notifications.dart';
import 'package:flame/view/users_profile/ProfileBody.dart';
import 'package:flame/view/users_profile/ProfileHeader.dart';
import 'package:flame/view/users_profile/ProfileMap.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../Friends/addFriend.dart';

import '../../Constants/constants.dart';
import '../../controller/user_cubit.dart';
import '../../model/save_data.dart';
import '../Auth/index.dart';

class Profile_ extends StatefulWidget {
  const Profile_({
    Key? key,
  }) : super(key: key);

  @override
  State<Profile_> createState() => _Profile_State();
}

class _Profile_State extends State<Profile_> {
  List<Contact> contacts = [];
  bool _waiting = true;
  void getPhoneData() async {
    _waiting = true;
    if (await FlutterContacts.requestPermission())
      // ignore: curly_braces_in_flow_control_structures
      await FlutterContacts.getContacts(withProperties: true, withPhoto: false)
          .then((value) {
        setState(() {
          contacts = value;
          _waiting = false;
          print(contacts);
        });
        //  UserCubit.get(context).getSearchContacs(contacts, '', context);
        //UserCubit.get(context).getAllDone();
        //  UserCubit.get(context).getAllLoaded();
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPhoneData();
    UserCubit.get(context).getUserPost(USERID: uId);
    UserCubit.get(context).getUserSavedPost(USERID: uId);
    UserCubit.get(context).getFrinds();
    UserCubit.get(context).getMyPost(ID: uId);
    UserCubit.get(context).getAllFriends(ID: uId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(listener: (context, state) {
      // TODO: implement listener
    }, builder: (context, state) {
      return Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Notifications()),
                );
              },
            ),
            actions: [
              // IconButton(
              //   icon: Icon(Icons.person_add),
              //   onPressed: () {
              //     UserCubit.get(context).search = [];

              //     addSheet(context);
              //   },
              // ),

              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  UserCubit.get(context).getAllDone();
                  UserCubit.get(context).getAllLoaded();

                  showAlertDialog(context);
                },
              ),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            backgroundColor: Colors.transparent,
            // Colors.white.withOpacity(0.1),
            elevation: 0,
          ),

          //header and body
          body: state is profilePicUpdate
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(children: [
                  ProfileHeader(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  ProfileBody1(),
                  Expanded(child: ProfileMap())
                ]));
    });
  }

  void addSheet(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      topRadius: const Radius.circular(20),
      builder: (context) => addFriend(),
      backgroundColor: Colors.transparent,
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel",
          style: TextStyle(
            fontFamily: font,
          )),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Log out",
          style: TextStyle(
            color: Colors.red,
            fontFamily: font,
          )),
      onPressed: () {
        UserCubit.get(context).currentIndex = 0;
        SaveData.removeKey(key: "idUser");

        UserCubit.get(context).currentIndex = 0;

        uId = "null";
        nameUser = "null";
        phoneUser = "null";
        dateUser = "null";
        Future.delayed(const Duration(seconds: 1)).then((value) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              IndexScreen.id, (Route<dynamic> route) => false);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: const Text("Are you sure you want to Logout?",
          style: TextStyle(
            fontFamily: 'Tajawal',
          )),
      actions: [
        continueButton,
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
