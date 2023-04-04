import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/Constants/theme.dart';
import 'package:flame/view/Nav.dart';
import 'package:flame/Constants/constants.dart';
import 'package:flame/model/save_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../model/Customer.dart';
import 'animated_text_field.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key, @required num}) : super(key: key);
  static String id = "RegisterScreen";
  String num = "";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState(phone: num);
}

class _RegisterScreenState extends State<RegisterScreen> {
  _RegisterScreenState({Key? key, @required phone});
  final _formKey = GlobalKey<FormState>();
  DateTime dateTime = DateTime.now();
  TextEditingController _date = TextEditingController();
  String phone = "";
  Customer cust = Customer();
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController _text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print(phone);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: size.height / 3 + 70,
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: HeaderPainter(),
                      child: SizedBox(
                        width: size.width,
                        height: size.height / 3,
                        child: const Center(
                          child: Text(
                            'One step left!',
                            style: TextStyle(
                                fontFamily: font,
                                fontSize: 25,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    // Align(
                    //     alignment: Alignment.center,
                    //     child: Container(
                    //       child: Image.asset(
                    //         'assets/filledLogo.png',
                    //         width: 120,
                    //         height: 120,
                    //       ),
                    //     ))
                  ],
                ),
              ),
              // const SizedBox(
              //   height: 15,
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  controller: _text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    cust.fullName = value;
                    print(cust.fullName);
                  },
                  cursorColor: Color(0xffFF7F1D),
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: 'Full name',
                    icon: Icon(Icons.person),
                    iconColor: Color(0xffFF7F1D),
                    focusColor: Color(0xffFF7F1D),
                    prefixIconColor: Color(0xffFF7F1D),
                    fillColor: Color(0xffFF7F1D),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  controller: _date,
                  cursorColor: Color(0xffFF7F1D),
                  decoration: const InputDecoration(
                      fillColor: Color(0xffFF7F1D),
                      iconColor: Color(0xffFF7F1D),
                      focusColor: Color(0xffFF7F1D),
                      icon: Icon(Icons.calendar_today_rounded),
                      labelText: "Birthdate"),
                  onTap: () async {
                    DateTime? pickeddate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2200));

                    if (pickeddate != null) {
                      setState(() {
                        _date.text =
                            DateFormat('dd-MM-yyyy').format(pickeddate);
                        cust.birthDate = _date.text;
                        //    dateUser = _date.text;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                child: InkWell(
                  onTap: () async {
                    cust.phone = auth.currentUser!.phoneNumber!;
                    cust.id = auth.currentUser!.uid;
                    cust.status = 'Active';
                    cust.userImage =
                        "https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2FdefaultProfilePic.png?alt=media&token=cb0d6f13-05c0-41c6-bb5a-d43f741b9adf";
                    SaveData.setData(key: 'idUser', value: cust.id);

                    setState(() {
                      uId = auth.currentUser!.uid;
                      nameUser = _text.text;
                      phoneUser = auth.currentUser!.phoneNumber!;
                      dateUser = _date.text;
                      STATUS = 'Active';
                      ImageUser =
                          "https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2FdefaultProfilePic.png?alt=media&token=cb0d6f13-05c0-41c6-bb5a-d43f741b9adf";
                    });
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(auth.currentUser!.uid)
                        .set(cust.toMap())
                        .catchError(
                            (error) => print("Failed to add user: $error"));
                    Navigator.pushNamed(context, Nav.id);
                  },
                  highlightColor: Color(0xffFF7F1D),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffFF7F1D)),
                        borderRadius: BorderRadius.circular(10)),
                    width: 300,
                    height: 54,
                    child: Center(
                      child: Text('Start using Flame',
                          style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDatePicker() => SizedBox(
        height: 180,
        child: CupertinoDatePicker(
          maximumYear: DateTime.now().year,
          initialDateTime: dateTime,
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (dateTime) =>
              setState(() => this.dateTime = dateTime),
        ),
      );
}

class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Color(0xffFF7F1D);
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
        size.width / 2, size.height - 120, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
