import 'package:flame/view/Filter/FilterByFriend.dart';
import 'package:flame/view/Filter/FilterByTag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../controller/user_cubit.dart';
import '../../../Constants/color.dart';
import '../../../Constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  @override
  void initState() {
    UserCubit.get(context).getUserFriend(id: uId);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;
    return Container(
        height: height * 0.35,
        color: Colors.white,
        child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: Scaffold(
              extendBodyBehindAppBar: false,
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text(
                  "Filter",
                  style: TextStyle(fontFamily: 'Tajawal', color: Colors.black),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  //insert validation method
                ),
              ),
              body: Padding(
                padding:
                    EdgeInsets.only(left: width * 0.08, right: width * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: height * 0.04,
                    ),
                    InkWell(
                      onTap: () {
                        showCupertinoModalBottomSheet(
                          context: context,
                          // expand: true,
                          isDismissible: false,
                          topRadius: const Radius.circular(20),
                          builder: (context) => const FilterByFriend(),
                          backgroundColor: Colors.transparent,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(
                              Icons.people_outline_outlined,
                              color: Colors.black,
                              size: height * 0.040,
                            ),
                            SizedBox(
                              width: width * 0.012,
                            ),
                            Text("Filter by Friends",
                                style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: height * 0.025)),
                          ]),
                          Icon(Icons.arrow_forward_ios_outlined),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                      child: Divider(
                        thickness: 0.5,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    InkWell(
                      onTap: () {
                        showCupertinoModalBottomSheet(
                          context: context,
                          // expand: true,
                          isDismissible: false,
                          topRadius: const Radius.circular(20),
                          builder: (context) => const FilterByTag(),
                          backgroundColor: Colors.transparent,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            SvgPicture.asset(
                              'assets/icons/subtag.svg',
                              // width: 0.38 * width,
                              height: height * 0.035,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: width * 0.020,
                            ),
                            Text("Filter by Tags",
                                style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: height * 0.025)),
                          ]),
                          Icon(Icons.arrow_forward_ios_outlined)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
