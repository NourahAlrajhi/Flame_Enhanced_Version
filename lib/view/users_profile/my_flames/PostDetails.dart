// ignore_for_file: non_constant_identifier_names, file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/Constants/color.dart';
import 'package:flame/Constants/theme.dart';
import 'package:flame/model/categoriesModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';

import '../../../Constants/constants.dart';
import '../../../controller/user_cubit.dart';

class PostDetails extends StatefulWidget {
  final String? Pic;
  final String? review;
  final String? placeName;
  final String? tag;
  final String? category;
  final String? POSTID;
  final Color? TagColor;
  final String? Date;
  const PostDetails(
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
  State<PostDetails> createState() => _PostDetailsState();
}

Color? categColor;
List<CategoriesModel> categories = [];
CategoriesModel? selectedCategory;

class _PostDetailsState extends State<PostDetails> {
  //to display each post with it is category

  getAllCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("Category").get();
    categories = snapshot.docs.map((e) => CategoriesModel.fromJson(e)).toList();
    setState(() {});
  }

  void Choosecolor({required String category}) {
    for (int i = 0; i < categories.length; i++) {
      if (categories[i].name == category) {
        setState(() {
          categColor =
              Color(int.parse(categories[i].color!.replaceAll('#', '0x')));
        });
      }
    }
    // print("$categColor");
    // return categColor!;
  }

  final editReview = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  showAlertDialog(BuildContext context, VoidCallback fun) {
    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      title: const Text(""),
      content: const Text('Are you sure you want to delete your Post?',
          style: TextStyle(
            fontFamily: font,
          )),
      actions: [
        TextButton(
            onPressed: fun,
            child: const Text(
              'Delete',
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

  editAlertDialog(String rev) {
    editReview.text = rev;
    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      titlePadding: EdgeInsets.all(0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.black,
                size: 25,
              ),
              onPressed: () {
                if (editReview.text != rev)
                  showEditAlertDialog(context);
                else
                  Navigator.pop(context);
              },
            ),
          ),
          Center(
            child: Text("Edit Review",
                style: TextStyle(
                  fontFamily: 'Tajawal',
                )),
          ),
        ],
      ),
      content: Container(
          width: 390,
          height: 160,
          margin: const EdgeInsets.only(top: 10, left: 5),
          child: TextFormField(
            maxLines: 20,
            maxLength: 200,
            controller: editReview,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 10.0, top: 16.0),
              hintText: "What do you think about the place?",
              hintStyle: const TextStyle(fontFamily: font),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
            ),
          )),
      actions: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: editReview,
          builder: (context, value, child) {
            return TextButton(
                onPressed: editReview.text != rev
                    ? () {
                        if (editReview.text != rev) {
                          UserCubit.get(context).editReview(
                              newRev: editReview.text, Pid: widget.POSTID!);
                          //UserCubit.get(context).Getreview(widget.POSTID!);
                          Future.delayed(Duration(milliseconds: 500), () {
                            Navigator.pop(context);

                            setState(() {
                              UserCubit.get(context).Getreview(widget.POSTID!);
                            });
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      }
                    : null,
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                  ),
                ));
          },
        ),
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

  showEditAlertDialog(BuildContext context) {
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
    Widget quit = TextButton(
      child: const Text("Discard",
          style: TextStyle(fontFamily: font, color: Colors.red)),
      onPressed: () {
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: const Text("Are you sure you want to discard your changes?",
          style: TextStyle(
            fontFamily: font,
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;
    return BlocConsumer<UserCubit, UserState>(listener: (context, state) {
      if (state is EditReviewdone) {
        UserCubit.get(context).Getreview(widget.POSTID!);
        EasyLoading.showSuccess('Review edited successfully');
      }
    }, builder: (context, state) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.755,
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .3,
                              width: double.infinity,
                              child: ClipRRect(
                                // borderRadius: BorderRadius.all(Radius.circular(15)),
                                child: Image.network(
                                  widget.Pic!,
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
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
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    // UserCubit.get(context).UserPost[0]['placeName'],
                                    widget.placeName!,
                                    style: const TextStyle(
                                        fontFamily: font,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22),
                                  ),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                  Row(
                                    children: [
                                      Container(
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
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Container(
                                        height: 22,
                                        // decoration: BoxDecoration(
                                        //   border: Border.all(
                                        //       color: widget.TagColor!),
                                        //   //  color: widget.TagColor,
                                        //   borderRadius:
                                        //       BorderRadius.circular(10),
                                        // ),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                widget.tag!,
                                                style: const TextStyle(
                                                    fontFamily: font,
                                                    fontSize: 12),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                            ]),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                  /////////////////////////////////////////////////////////////////
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: width * 0.25),
                                    child: const Divider(
                                      thickness: 1,
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: width * 0.8,
                                        child: Text(
                                          UserCubit.get(context).review!,
                                          style: const TextStyle(
                                              fontFamily: font,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.03,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          editAlertDialog(
                                              UserCubit.get(context).review!);
                                        },
                                        child: Icon(Icons.edit,
                                            size: 0.03 * height,
                                            color: Buttonblue),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: width * 0.75),
                                    child: const Divider(
                                      thickness: 1,
                                    ),
                                  ),
                                  // SizedBox(height: height*0.01,),
                                  Text(
                                    widget.Date!,
                                    style: TextStyle(
                                        fontFamily: font,
                                        fontSize: width * 0.04),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: (() async {
                            showAlertDialog(
                              context,
                              () {
                                UserCubit.get(context).deletUserPost(
                                    UserPost: widget.POSTID!, USERID: uId);
                                Navigator.pop(context);
                              },
                            );
                          }),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10)),
                              width: MediaQuery.of(context).size.width * .25,
                              height: MediaQuery.of(context).size.height * .042,
                              child: Center(
                                child: Text('Delete',
                                    style: TextStyle(
                                        fontFamily: font,
                                        // decoration: TextDecoration.underline,
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 0.1,
                        ),
                      ],
                    ),
                  ))),
        ],
      );
    });
  }
}
