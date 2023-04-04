import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flame/Constants/theme.dart';
import 'package:flame/view/users_profile/Profile.dart';
import 'package:flame/Constants/color.dart';
import 'package:flame/Constants/constants.dart';
import 'package:flame/controller/user_cubit.dart';
import 'package:flame/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flame/view/posts/PostRec.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controller/local_push_notification.dart';

class Nav extends StatefulWidget {
  Nav({Key? key}) : super(key: key);
  static String id = "Nav";

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  late final LocalNotificationService service;

  int currentTab = 0;
  final List<Widget> screens = [
    const HomePage(),
    const PostRec(),
    const Profile_()
  ];

  storeNotificationToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(uId)
        .set({'token': token}, SetOptions(merge: true));
  }

  initNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {});
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // Navigator.push(BuildContext() , MaterialPageRoute(builder: (context) => addFriend()));
      // Navigator.of(context).pushNamed(message);

      Navigator.of(context).pushNamed("requestList");
    });
  }

  @override
  void initState() {
    super.initState();
    initNotifications();
    service = LocalNotificationService();
    service.initialize();
    UserCubit.get(context).getRequest(id: uId);
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((event) {
      LocalNotificationService.display(event);
    });

    storeNotificationToken();
  }

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const HomePage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageStorage(bucket: bucket, child: currentScreen),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 80,
        width: 80,
        child: FittedBox(
          child: FloatingActionButton(
              heroTag: "btn1",
              focusElevation: 0,
              highlightElevation: 0,
              splashColor: Colors.transparent,
              onPressed: () {
                postSheet(context);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              isExtended: true,
              child: Image.asset(
                "assets/filledLogosmall.png",
                height: 70,
                width: 60,
              )),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        //shape: CircularNotchedRectangle(),
        //notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 30),
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      currentScreen = const HomePage();
                      currentTab = 0;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        color: currentTab == 0 ? primary : inActiveColor,
                      ),
                      Text(
                        'Map',
                        style: TextStyle(
                            fontFamily: font,
                            color: currentTab == 0 ? primary : inActiveColor),
                      )
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const SizedBox(
                    height: 27,
                  ),
                  const Text(
                    'Post',
                    style: TextStyle(fontFamily: font, color: textColor),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(right: 30),
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      currentScreen = const Profile_();
                      currentTab = 1;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        color: currentTab == 1 ? primary : inActiveColor,
                      ),
                      Text(
                        'Profile',
                        style: TextStyle(
                            fontFamily: font,
                            color: currentTab == 1 ? primary : inActiveColor),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

postSheet(BuildContext context) {
  showCupertinoModalBottomSheet(
    enableDrag: false,
    context: context,
    topRadius: const Radius.circular(20),
    builder: (context) => const PostRec(),
    backgroundColor: Colors.transparent,
    isDismissible: false,
  );
}
