import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flame/Constants/constants.dart';
import 'package:flame/model/save_data.dart';
import 'package:flame/view/Auth/Signup.dart';
import 'package:flame/view/Auth/index.dart';
import 'package:flame/view/Auth/inotp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../Constants/constants.dart';
import '../../controller/user_cubit.dart';

class SigninScreen extends StatefulWidget {
  //
  const SigninScreen({super.key});
  static String id = "SigninScreen";

  @override
  State<SigninScreen> createState() => _SigninScreenState();
  static String textNumberPhone = '';
  static String dialCodeInitial = '+966';
} //

FirebaseAuth auth = FirebaseAuth.instance;
TextEditingController phoneController =
    TextEditingController(text: "+923028997122");
TextEditingController otpController = TextEditingController();
String verificationID = "";

class _SigninScreenState extends State<SigninScreen> {
  //
  late FlCountryCodePicker countryPicker;
  CountryCode? countryCode = CountryCode.fromMap(
      {"name": "Saudi Arabia", "code": "SA", "dial_code": "+966"});
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    final favoriteCountries = ['SA', 'GB', 'US'];
    countryPicker = FlCountryCodePicker(
        favorites: favoriteCountries, favoritesIcon: Icon(Icons.remove));
    super.initState();
  }

  bool validation() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
        //
        resizeToAvoidBottomInset: false,
        body: Column(//
            children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: InkWell(
                  child: Icon(
                    Icons.close,
                    size: 35,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ), //row
          Container(
            margin: const EdgeInsets.only(top: 100, right: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '  Welcome back',
                  style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      fontSize: 40),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5, right: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don’t have an account?',
                  style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: Color(0xff3F3D43)),
                ),
                InkWell(
                  onTap: () {
                    showCupertinoModalBottomSheet(
                      context: context,
                      expand: true,
                      isDismissible: true,
                      topRadius: Radius.circular(20),
                      builder: (context) => SignupScreen(),
                      backgroundColor: Colors.transparent,
                    );
                  },
                  child: Text(
                    ' Sign up',
                    style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        color: Color(0xffFF7F1D)),
                  ),
                ),
              ],
            ),
          ),
          Form(
              key: _formKey,
              child: Container(
                  margin: const EdgeInsets.only(top: 100, left: 20),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length != 9) {
                        return 'Please enter your phone number';
                      }
                      phoneController.text = countryCode!.dialCode + value;
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    maxLength: 9,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    cursorColor: Color(0xffFF7F1D),
                    decoration: InputDecoration(
                        hintText: '50XXXXXXX',
                        hintStyle: TextStyle(color: Color(0xffC1C1CD)),
                        border: InputBorder.none,
                        counterText: '',
                        prefixIcon: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            GestureDetector(
                                onTap: () async {
                                  final code = await countryPicker.showPicker(
                                      context: context);

                                  setState(() {
                                    countryCode = code;
                                  });
                                  print(countryCode);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left: 8, right: 2),
                                  height: 45,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          Color.fromARGB(255, 238, 236, 236)),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 5),
                                        child: countryCode != null
                                            ? countryCode!.flagImage
                                            : null,
                                      ),
                                      Container(
                                          child: Text(
                                        countryCode?.dialCode ?? "+966",
                                        style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ))
                                    ],
                                  ), //row
                                ) //container
                                ), //gesture
                          ]), //row
                        )),
                  ))), //form
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: InkWell(
              onTap: () async {
                bool valid = validation();
                if (valid) {
                  await loginWithPhone(context);
                  SaveData.setData(key: 'idUser', value: auth.currentUser!.uid);
                  setState(() {
                    uId = auth.currentUser!.uid;
                    phoneUser = phoneController.text;
                    // FirebaseFirestore.instance.collection("Users").doc(uId).get().then((value) {

                    //dateUser=value.data()!['birthDate'];
                    //   });
                  });
                }
                SaveData.setData(key: 'idUser', value: auth.currentUser!.uid);
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
                  child: Text('Continue »',
                      style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ),
          )
        ]));
    //column
    //scaffold
  } //
}

Future loginWithPhone(BuildContext context) async {
  auth.verifyPhoneNumber(
    phoneNumber: phoneController.text,
    verificationCompleted: (PhoneAuthCredential credential) async {
      print("Hi");
      await auth.signInWithCredential(credential).then((value) {
        SaveData.setData(key: 'idUser', value: credential.providerId);
        UserCubit.get(context).getDataUser(id: uId);
        print("Hi");
      });
    },
    verificationFailed: (FirebaseAuthException e) {
      print(e.message);
      print("hi after");
      SaveData.setData(key: 'idUser', value: e.credential!.providerId);
      UserCubit.get(context).getDataUser(id: uId);
    },
    codeSent: (String verificationId, int? resendToken) {
      verificationID = verificationId;
      showCupertinoModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        builder: (context) => INOTPScreen(),
        backgroundColor: Colors.transparent,
      );
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      verificationID = verificationId;
    },
  );
}

Future<bool> verifyOTP(String otp1) async {
  print(verificationID);
  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: otp1);

    return await auth.signInWithCredential(credential).then((value) {
      if (auth.currentUser!.displayName == null) {
        print("Unregistered user");
        print(auth.currentUser!.displayName);
        return false;
      } else {
        return true;
      }
      // auth.currentUser!.updateDisplayName(registered);
    });
  } catch (e) {
    print(e);
    print("Hello from catch");
    return false;
  }
}
