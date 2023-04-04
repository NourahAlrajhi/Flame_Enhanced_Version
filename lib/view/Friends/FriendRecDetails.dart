// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/Constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../Constants/constants.dart';
import '../../controller/user_cubit.dart';
import '../../Constants/color.dart';

class FriendRecDetails extends StatefulWidget {
  final String? Pic;
  final String? review;
  final String? placeName;
  final String? tag;
  final String? category;
  final String? POSTID;
  final Color? TagColor;
  final String? Date;
  const FriendRecDetails(
      {super.key,
      this.Pic,
      this.review,
      this.placeName,
      this.tag,
      this.category,
      this.POSTID,
      this.TagColor,
      this.Date});
  @override
  State<FriendRecDetails> createState() => _FriendRecDetailsState();
}

class _FriendRecDetailsState extends State<FriendRecDetails> {
  bool unsave = false;
  String FilledSave = "assets/icons/saved.svg";
  String UnFilledSave = "assets/icons/unsaved.svg";
  bool ISSaved = true;
  void CheckIfExist2() {
    unsave = false;

    setState(() {
      unsave = true;
    });
  }

  showAlertDialog(BuildContext context, VoidCallback fun) {
    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      title: const Text(""),
      content: const Text('Are you sure you want to remove the saved post ?',
          style: TextStyle(
            fontFamily: font,
          )),
      actions: [
        TextButton(
            onPressed: fun,
            child: const Text(
              'Remove',
              style: TextStyle(fontFamily: font, color: Colors.red),
            )),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel',
                style: TextStyle(
                  fontFamily: font,
                ))),
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

  void CheckIfExist({required String POSTID, required String USERID}) {
    ISSaved = true;
    FirebaseFirestore.instance
        .collection("Users")
        .doc(USERID)
        .collection("MySavedPost")
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (element.data()["PostID"] == POSTID) {
          setState(() {
            ISSaved = false;
          });
        }
      }
    });
  }

  @override
  void initState() {
    CheckIfExist(POSTID: widget.POSTID!, USERID: uId);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;
    return BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              color: Colors.white,
              child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Scaffold(
                    extendBodyBehindAppBar: true,
                    resizeToAvoidBottomInset: false,
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      title: Column(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/dash.svg',
                            width: 0.001 * width,
                            height: height * 0.007,
                          ),
                          const SizedBox(
                            height: 25,
                          )
                        ],
                      ),
                      centerTitle: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .3,
                              width: double.infinity,
                              child: ClipRRect(
                                child: Image.network(
                                  widget.Pic!,
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * .2,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: width * 0.75,
                                        child: Text(
                                          // UserCubit.get(context).UserPost[0]['placeName'],
                                          widget.placeName!,
                                          style: const TextStyle(
                                              fontFamily: font,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22),
                                        ),
                                      ),
                                      GestureDetector(
                                        child: InkWell(
                                          onTap: (ISSaved
                                              ? () {
                                                  UserCubit.get(context)
                                                      .GetSavedPost(
                                                          POSTID:
                                                              widget.POSTID!);
                                                  Timer(
                                                      const Duration(
                                                          milliseconds: 500),
                                                      () {
                                                    setState(() {
                                                      CheckIfExist(
                                                          POSTID:
                                                              widget.POSTID!,
                                                          USERID: uId);
                                                    });
                                                  });
                                                }
                                              : () {
                                                  UserCubit.get(context)
                                                      .deletUserSavedPost(
                                                          IDPost:
                                                              widget.POSTID!,
                                                          USERID: uId);

                                                  setState(() {
                                                    CheckIfExist(
                                                        POSTID: widget.POSTID!,
                                                        USERID: uId);
                                                  });
                                                }),
                                          splashColor: background,
                                          child: ISSaved
                                              ? SvgPicture.asset(
                                                  UnFilledSave,
                                                  width: 24,
                                                  height: 27,
                                                )
                                              : SvgPicture.asset(
                                                  FilledSave,
                                                  width: 24,
                                                  height: 27,
                                                ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        // height: 22,
                                        padding: EdgeInsets.all(width * 0.01),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: widget.TagColor!),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(widget.category!,
                                            style: const TextStyle(
                                                fontFamily: font,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12)),
                                      ),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Image.asset(
                                            //   "assets/tag.png",
                                            //   height: 12,
                                            //   width: 12,
                                            // ),
                                            // SvgPicture.asset("assets/icons/subtag.svg",
                                            // color: widget.TagColor!,
                                            // height: height*0.025,),
                                            Text(
                                              widget.tag!,
                                              style: const TextStyle(
                                                  fontFamily: font,
                                                  fontSize: 12),
                                            ),

                                            const SizedBox(
                                              width: 2,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                          ]),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: width * 0.25),
                                    child: const Divider(
                                      thickness: 1,
                                    ),
                                  ),
                                  Text(
                                    widget.review!,
                                    style: const TextStyle(
                                        fontFamily: font,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: width * 0.75),
                                    child: const Divider(
                                      thickness: 1,
                                    ),
                                  ),
                                  Text(
                                    // nourah here put date
                                    widget.Date!,
                                    style: const TextStyle(
                                        fontFamily: font, fontSize: 10),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )));
        });
  }
}
