import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/view/Nav.dart';
import 'package:flame/Constants/constants.dart';
import 'package:flame/view/Auth/Register.dart';
import 'package:flame/view/Auth/Signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flame/view/Auth/Signin.dart' as signin;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../controller/user_cubit.dart';
import '../../model/save_data.dart';
import 'index.dart';

class INOTPScreen extends StatefulWidget {
  static String id = "ININOTPScreen";
  INOTPScreen({super.key});

  @override
  State<INOTPScreen> createState() => _INOTPScreenState();
}

class _INOTPScreenState extends State<INOTPScreen> {
  String otp = '';
  String otp1 = '';
  String otp2 = '';
  String otp3 = '';
  String otp4 = '';
  String otp5 = '';
  String otp6 = '';
  int start = 60;
  bool result = true;
  var _controller1 = TextEditingController();
  var _controller2 = TextEditingController();
  var _controller3 = TextEditingController();
  var _controller4 = TextEditingController();
  var _controller5 = TextEditingController();
  var _controller6 = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    StartTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;
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
            margin: EdgeInsets.only(top: 60),
            child: Text(
              'OTP Code Verification',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Code has been sent to ',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                  ),
                ),
                Text(
                  signin.phoneController.text,
                  style: TextStyle(
                      fontFamily: 'Tajawal', color: Color(0xffFF7F1D)),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 150, bottom: 40),
            child: Form(
                key: _formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: height * 0.06,
                      width: width * 0.15,
                      child: TextFormField(
                        controller: _controller1,
                        onChanged: (value) {
                          if (value.length == 1) {
                            otp1 = value;
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        cursorColor: Color(0xffFF7F1D),
                        // decoration: InputDecoration(focusColor: Color(0xffFF7F1D), b ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.06,
                      width: width * 0.15,
                      child: TextFormField(
                        controller: _controller2,
                        onChanged: (value) {
                          if (value.length == 1) {
                            otp2 = value;

                            FocusScope.of(context).nextFocus();
                          }
                        },
                        cursorColor: Color(0xffFF7F1D),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.06,
                      width: width * 0.15,
                      child: TextFormField(
                        controller: _controller3,
                        onChanged: (value) {
                          if (value.length == 1) {
                            otp3 = value;

                            FocusScope.of(context).nextFocus();
                          }
                        },
                        cursorColor: Color(0xffFF7F1D),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.06,
                      width: width * 0.15,
                      child: TextFormField(
                        controller: _controller4,
                        onChanged: (value) {
                          if (value.length == 1) {
                            otp4 = value;

                            FocusScope.of(context).nextFocus();
                          }
                        },
                        cursorColor: Color(0xffFF7F1D),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.06,
                      width: width * 0.15,
                      child: TextFormField(
                        controller: _controller5,
                        onChanged: (value) {
                          if (value.length == 1) {
                            otp5 = value;

                            FocusScope.of(context).nextFocus();
                          }
                        },
                        cursorColor: Color(0xffFF7F1D),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.06,
                      width: width * 0.15,
                      child: TextFormField(
                        controller: _controller6,
                        onChanged: (value) async {
                          if (value.length == 1) {
                            otp6 = value;
                            otp = otp1 + otp2 + otp3 + otp4 + otp5 + otp6;

                            result = await signin.verifyOTP(otp);
                            setState(() {
                              result;
                            });
                            if (result) {
                              SaveData.setData(
                                  key: 'idUser',
                                  value: signin.auth.currentUser!.uid);
                              uId = await SaveData.getData(key: 'idUser');
                              Future.delayed(Duration(seconds: 2))
                                  .then((value) {
                                UserCubit.get(context).getDataUser(id: uId);
                                UserCubit.get(context).getAllLoaded();
                                UserCubit.get(context).getAllDone();

                                Navigator.pushNamed(context, Nav.id);
                                print("the login is Done $uId");
                              });
                            } else {
                              setState(() {
                                _controller1.clear();
                                _controller2.clear();
                                _controller3.clear();
                                _controller4.clear();
                                _controller5.clear();
                                _controller6.clear();
                              });
                              print("NOT REGISTERED");
                              showCupertinoDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: Text(
                                        "This number is not registered",
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                      content: Text(
                                        "Do you want to go to sign up screen?",
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: Text("No",
                                              style: TextStyle(
                                                fontFamily: 'Tajawal',
                                              )),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, IndexScreen.id);
                                          },
                                        ),
                                        CupertinoDialogAction(
                                          child: Text("Yes",
                                              style: TextStyle(
                                                fontFamily: 'Tajawal',
                                              )),
                                          onPressed: () {
                                            showCupertinoModalBottomSheet(
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                  top: Radius.circular(30),
                                                ),
                                              ),
                                              builder: (context) =>
                                                  SignupScreen(),
                                              backgroundColor:
                                                  Colors.transparent,
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            }
                          }
                        },
                        cursorColor: Color(0xffFF7F1D),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    )
                  ],
                )),
          ),
          Visibility(
            visible: result == false,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("WRONG OTP",
                  style: TextStyle(fontFamily: 'Tajawal', color: Colors.red)),
            ]),
          ),
          Visibility(
            visible: start != 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Resend OTP in ",
                  style: TextStyle(fontFamily: 'Tajawal', color: Colors.black)),
              Text("$start",
                  style: TextStyle(fontFamily: 'Tajawal', color: Colors.black)),
              Text(" seconds",
                  style: TextStyle(fontFamily: 'Tajawal', color: Colors.black))
            ]),
          ),
          Visibility(
            visible: start == 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              InkWell(
                onTap: () {
                  signin.loginWithPhone(context);
                },
                child: Text("Resend OTP",
                    style: TextStyle(
                        fontFamily: 'Tajawal', color: Color(0xffFF7F1D))),
              ),
            ]),
          )
        ],
      ),
    );
  }

  void StartTimer() {
    const onsec = Duration(seconds: 1);
    Timer timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }
}
