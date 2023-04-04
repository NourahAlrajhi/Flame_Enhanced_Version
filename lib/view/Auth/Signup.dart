import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flame/view/Auth/Register.dart';
import 'package:flame/view/Auth/Signin.dart';
import 'package:flame/view/Auth/upotp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../Constants/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  static String id = "SignupScreen";

  @override
  State<SignupScreen> createState() => _SignupScreenState();
  static String textNumberPhone = '';
  static String dialCodeInitial = '+966';
}

FirebaseAuth auth = FirebaseAuth.instance;
TextEditingController phoneController1 =
    TextEditingController(text: "+923028997122");
TextEditingController otpController = TextEditingController();
String verificationID1 = "";

class _SignupScreenState extends State<SignupScreen> {
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisSize: MainAxisSize.min,
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
          ),
          Container(
            margin: const EdgeInsets.only(top: 100, left: 30),
            child: Row(
              children: [
                Text(
                  'Let’s light your flame',
                  style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5, left: 30),
            child: Row(
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: Color(0xff3F3D43)),
                ),
                InkWell(
                  onTap: () {
                    showCupertinoModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      builder: (context) => SigninScreen(),
                      backgroundColor: Colors.transparent,
                    );
                  },
                  child: Text(
                    ' Sign in',
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
                    if (value == null && value!.isEmpty && value.length == 9) {
                      return 'Please enter your phone number';
                    }
                    phoneController1.text = countryCode!.dialCode + value;
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  maxLength: 9,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      hintText: '50XXXXXXX',
                      hintStyle: TextStyle(color: Color(0xffC1C1CD)),
                      border: InputBorder.none,
                      counterText: '',
                      prefixIcon: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                                onTap: () async {
                                  final code = await countryPicker.showPicker(
                                      context: context);
                                  setState(() {
                                    countryCode = code;
                                  });
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
                                  ),
                                )),
                          ],
                        ),
                      )),
                )),
          ),
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: InkWell(
              onTap: () {
                bool valid = validation();
                if (valid) {
                  SignupWithPhone(context);
                  print('*******************enter inkwell');
                }
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
        ],
      ),
    );
  }
}

void SignupWithPhone(BuildContext context) async {
  print('*******************11111');
  auth.verifyPhoneNumber(
    phoneNumber: phoneController1.text,
    verificationCompleted: (PhoneAuthCredential credential) async {
      await auth.signInWithCredential(credential).then((value) {
        print("Hi");
      });
    },
    verificationFailed: (FirebaseAuthException e) {
      print(e.message);
    },
    codeSent: (String verificationId, int? resendToken) {
      print('*******************222222222');
      verificationID1 = verificationId;
      showCupertinoModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        builder: (context) => UPOTPScreen(),
        backgroundColor: Colors.transparent,
      );
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      verificationID1 = verificationId;
    },
  );
}

Future<bool> SignupOTP(String otp1) async {
  print(verificationID1);
  print(verificationID1);

  print(verificationID1);

  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID1, smsCode: otp1);

    return await auth.signInWithCredential(credential).then((value) {
      if (auth.currentUser!.displayName != null) {
        print("PHONE NUMBER ALREADY TAKEN");
        print(auth.currentUser!.displayName);
        return false;
      } else {
        auth.currentUser!.updateDisplayName(registered);
        return true;
      }
    });
  } catch (e) {
    print(e);
    print("Hello from catch");
    return false;
  }
}
