// import 'dart:js';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flame/view/Friends/addFriend.dart';
import 'package:flame/Constants/constants.dart';
import 'package:flame/controller/user_cubit.dart';
import 'package:flame/model/save_data.dart';
import 'package:flame/view/Auth/Register.dart';
import 'package:flame/view/Auth/Signin.dart';
import 'package:flame/view/Splash.dart';
import 'package:flame/view/Auth/inotp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/view/Auth/index.dart';
import 'package:flame/view/Auth/Signup.dart';
import 'package:flame/view/Nav.dart';
import 'firebase_options.dart';

import 'view/Auth/upotp.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
      //options: DefaultFirebaseOptions.currentPlatform
      );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        //   name: "flame-49dfd",
        //  options: DefaultFirebaseOptions.currentPlatform
        );
  }

  await SaveData.init();
  uId = await SaveData.getData(key: "idUser") ?? "null";
  print("the uId is : $uId");

  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 1000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..userInteractions = true
    ..dismissOnTap = true;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {});
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    // Navigator.push(BuildContext() , MaterialPageRoute(builder: (context) => addFriend()));
    // Navigator.of(context).pushNamed(message);
  });

  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => UserCubit()
              ..getAllUser()
              ..getAllRequist()
              ..getDataUser(id: uId)
              ..getAllLoaded()
              ..getAllDone(),
          ),
        ],
        child: MaterialApp(
          // navigatorKey: NavigationService.navigationKey,
          debugShowCheckedModeBanner: false,
          home: uId == "null" ? const SplashScreen() : Nav(),
          builder: EasyLoading.init(),
          routes: {
            IndexScreen.id: (context) => const IndexScreen(),
            SignupScreen.id: (context) => const SignupScreen(),
            UPOTPScreen.id: (context) => UPOTPScreen(),
            INOTPScreen.id: (context) => INOTPScreen(),
            SigninScreen.id: (context) => const SigninScreen(),
            RegisterScreen.id: (context) => RegisterScreen(),
            Nav.id: (context) => Nav(),
            addFriend.id: (context) => addFriend(),
          },
        ));
  }
}
