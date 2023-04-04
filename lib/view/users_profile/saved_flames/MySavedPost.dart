// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/Constants/color.dart';
import 'package:flame/Constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../Constants/constants.dart';
import '../../../controller/user_cubit.dart';
import '../../../model/categoriesModel.dart';
import 'SavedPostDetails.dart';

class MySavedPost extends StatefulWidget {
  const MySavedPost({super.key});

  @override
  State<MySavedPost> createState() => _MySavedPostState();
}

class _MySavedPostState extends State<MySavedPost> {
  ///to display each post with it is category
  List<CategoriesModel> categories = [];
  CategoriesModel? selectedCategory;
  var formatter = new DateFormat('yyyy-MM-dd');
  DateTime today = new DateTime.now();
  DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
  getAllCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("Category").get();
    categories = snapshot.docs.map((e) => CategoriesModel.fromJson(e)).toList();
    setState(() {});
  }

  Color getPostColor({required String categoryyyy}) {
    Color? categColor;

    for (int i = 0; i < categories.length; i++) {
      if (categories[i].name == categoryyyy) {
        categColor =
            Color(int.parse(categories[i].color!.replaceAll('#', '0x')));
      }
    }
    return categColor!;
  }

  showAlertDialog(BuildContext context, VoidCallback fun) {
    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      title: const Text(""),
      content: const Text('Are you sure you want to delete your Saved Post ?',
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

  @override
  void initState() {
    UserCubit.get(context).getUserSavedPost(USERID: uId);
    getAllCategories();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(listener: (context, state) {
      if (state is deleteSavedPostDone) {}
    }, builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 65,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          // ignore: prefer_const_constructors
          title: Text(
            'Saved Flames',
            style: const TextStyle(
              color: textColor,
              fontFamily: font,
            ),
          ),
          centerTitle: true,
        ),
        body: state
                is deletePostDone //////////////////Must changgggggggggggggge
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 10, top: 25),
                child: UserCubit.get(context).UserSavedPost.isEmpty
                    ? const Center(
                        child: Text('You have no saved posts yet',
                            style: TextStyle(
                              fontFamily: font,
                            )),
                      )
                    : ListView.separated(
                        itemBuilder: (_, index) {
                          return Slidable(
                            actionPane: const SlidableStrechActionPane(),
                            actionExtentRatio: 0.25,
                            child: ListTile(
                                leading: Container(
                                    width: 50,
                                    height: 50,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        '${UserCubit.get(context).UserSavedPost[index]['photo']}',
                                        fit: BoxFit.fill,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
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
                                    )),
                                title: Text(
                                  "${UserCubit.get(context).UserSavedPost[index]['placeName']}",
                                  style: const TextStyle(
                                      fontFamily: font, color: kTextColor),
                                ),
                                subtitle: Text(
                                    "${UserCubit.get(context).UserSavedPost[index]['PostDate'] == formatter.format(today) ? "Today" : UserCubit.get(context).UserSavedPost[index]['PostDate'] == formatter.format(yesterday) ? "Yesterday" : UserCubit.get(context).UserSavedPost[index]['PostDate']}",
                                    style: const TextStyle(
                                      fontFamily: font,
                                    )),
                                //trailing: ,
                                onTap: () {
                                  showCupertinoModalBottomSheet(
                                    context: context,
                                    // expand: true,
                                    isDismissible: true,
                                    topRadius: const Radius.circular(20),
                                    builder: (context) => SavedPostDetails(
                                        Pic: UserCubit.get(context).UserSavedPost[index]
                                            ['photo'],
                                        review: UserCubit.get(context).UserSavedPost[index]
                                            ['review'],
                                        placeName: UserCubit.get(context)
                                            .UserSavedPost[index]['placeName'],
                                        tag: UserCubit.get(context).UserSavedPost[index]
                                            ['tag'],
                                        category: UserCubit.get(context)
                                            .UserSavedPost[index]['category'],
                                        POSTID: UserCubit.get(context).UserSavedPost[index]
                                            ['PostID'],
                                        TagColor: getPostColor(
                                            categoryyyy: UserCubit.get(context)
                                                .UserSavedPost[index]['category']),
                                        Date: UserCubit.get(context).UserSavedPost[index]['PostDate'] == formatter.format(today)
                                            ? "Today"
                                            : UserCubit.get(context).UserSavedPost[index]['PostDate'] == formatter.format(yesterday)
                                                ? "Yesterday"
                                                : UserCubit.get(context).UserSavedPost[index]['PostDate']),
                                    backgroundColor: Colors.transparent,
                                  );
                                },
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      "assets/icons/subtag.svg",
                                      color: getPostColor(
                                          categoryyyy: UserCubit.get(context)
                                                  .UserSavedPost[index]
                                              ['category']),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.025,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      UserCubit.get(context)
                                          .UserSavedPost[index]['tag'],
                                      style: const TextStyle(
                                          fontFamily: font, fontSize: 14),
                                    ),
                                  ],
                                )),
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                  caption: 'Remove',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () async {
                                    showAlertDialog(
                                      context,
                                      () {
                                        UserCubit.get(context)
                                            .deletUserSavedPost(
                                                IDPost: UserCubit.get(context)
                                                        .UserSavedPost[index]
                                                    ['PostID'],
                                                USERID: uId);
                                        Navigator.pop(context);
                                      },
                                    );
                                  }),
                            ],
                          );
                          /*  return Slidable(
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                  caption: 'Remove',
                                  color: Colors.red,
                                  icon: Icons.remove,
                                  onTap: () async {
                                    showAlertDialog(
                                      context,
                                      () {
                                        UserCubit.get(context)
                                            .deletUserSavedPost(
                                                IDPost: UserCubit.get(context)
                                                        .UserSavedPost[index]
                                                    ['PostID'],
                                                USERID: uId);
                                        Navigator.pop(context);
                                      },
                                    );
                                  }),
                            ],
                            actionPane: const SlidableStrechActionPane(),
                            actionExtentRatio: 0.25,
                            child: InkWell(
                                onTap: (() {
                                  showCupertinoModalBottomSheet(
                                    context: context,
                                    // expand: true,
                                    isDismissible: true,
                                    topRadius: const Radius.circular(20),
                                    builder: (context) => SavedPostDetails(
                                        Pic: UserCubit.get(context).UserSavedPost[index]
                                            ['photo'],
                                        review: UserCubit.get(context).UserSavedPost[index]
                                            ['review'],
                                        placeName: UserCubit.get(context)
                                            .UserSavedPost[index]['placeName'],
                                        tag: UserCubit.get(context).UserSavedPost[index]
                                            ['tag'],
                                        category: UserCubit.get(context)
                                            .UserSavedPost[index]['category'],
                                        POSTID: UserCubit.get(context).UserSavedPost[index]
                                            ['PostID'],
                                        TagColor: getPostColor(
                                            categoryyyy: UserCubit.get(context)
                                                .UserSavedPost[index]['category']),
                                        Date: UserCubit.get(context).UserSavedPost[index]['PostDate'] == formatter.format(today)
                                            ? "Today"
                                            : UserCubit.get(context).UserSavedPost[index]['PostDate'] == formatter.format(yesterday)
                                                ? "Yesterday"
                                                : UserCubit.get(context).UserSavedPost[index]['PostDate']),
                                    backgroundColor: Colors.transparent,
                                  );
                                }),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),


                                    Expanded(
                                      child: Text(
                                        UserCubit.get(context)
                                            .UserSavedPost[index]['placeName'],
                                        style: const TextStyle(
                                          fontFamily: font,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: 25,
                                          // decoration: BoxDecoration(
                                          //   border: Border.all(
                                          //       color: getPostColor(
                                          //           categoryyyy: UserCubit.get(
                                          //                       context)
                                          //                   .UserSavedPost[
                                          //               index]['category'])),
                                          //   borderRadius:
                                          //       BorderRadius.circular(10),
                                          // ),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                SvgPicture.asset(
                                                  "assets/icons/subtag.svg",
                                                  color: getPostColor(
                                                      categoryyyy: UserCubit
                                                                  .get(context)
                                                              .UserSavedPost[
                                                          index]['category']),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.025,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  UserCubit.get(context)
                                                          .UserSavedPost[index]
                                                      ['tag'],
                                                  style: const TextStyle(
                                                      fontFamily: font,
                                                      fontSize: 14),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                              ]),
                                        ),
                                        // This might be done when pressing on saved button( selectedMarker!.PostIDDDDD,)
                                        const SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                )),
                          );*/
                        },
                        separatorBuilder: (_, index) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Divider(
                              thickness: 1,
                              color: Color.fromARGB(255, 212, 210, 210),
                            ),
                          );
                        },
                        itemCount: UserCubit.get(context).UserSavedPost.length,
                      ),
              ),
      );
    });
  }
}
