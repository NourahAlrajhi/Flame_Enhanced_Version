import 'package:cached_network_image/cached_network_image.dart';
import 'package:flame/view/Filter/FilterByFriend.dart';
import 'package:flame/view/Nav.dart';
import 'package:flame/view/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../controller/user_cubit.dart';
import '../../../Constants/color.dart';
import '../../../Constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/categoriesModel.dart';

class FilterByTag extends StatefulWidget {
  const FilterByTag({super.key});

  @override
  State<FilterByTag> createState() => _FilterState();
}

class _FilterState extends State<FilterByTag> {
  String? categoryName;
  bool click = false;
  double? height;
  double? width;
  bool tagChosen = false;
  Set<String> filteration = {''};
  bool flag = false;

  @override
  void initState() {
    UserCubit.get(context).getUserFriend(id: uId);
    // TODO: implement initState
    getAllCategories();
    filterByTag.forEach((element) {
      filteration.add(element);
    });
    super.initState();
  }

  List<CategoriesModel> categories =
      []; // To store the List fetched from Firebase
  CategoriesModel? selectedCategory; // points to current selected Category

  getAllCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("Category").get();
    categories = snapshot.docs.map((e) => CategoriesModel.fromJson(e)).toList();
    setState(() {});
  }

////category buttons
  catButton({CategoriesModel? category, String? cat, String? color}) {
    Color? colrs2 = Color(int.parse(color!.replaceAll('#', '0x')));
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height! * 0.06,
      width: width! * 0.45,
      child: ElevatedButton(
          onPressed: () async {
            UserCubit.get(context).SubCategories(subtag: cat);

            setState(() {
              flag = true;
              categoryName = cat;
              filteration.add(cat);
              print(filterByTag);
              print(filteration);
              //  click = true;
            });
          },
          style: ElevatedButton.styleFrom(
              side: BorderSide(color: colrs2),
              elevation: 0.5,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              backgroundColor: filteration == null
                  ? background
                  : filteration.contains(cat)
                      ? colrs2
                      : background),
          child: Row(children: <Widget>[
            SizedBox(
              width: width! * 0.01,
            ),
            Expanded(
              child: Center(
                child: Text(
                  cat!,
                  style: TextStyle(
                      fontSize: width! * 0.045,
                      color: textColor,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SizedBox(
              width: width! * 0.01,
            ),
            for (int i = 0; i < filteration.length; i++)
              if (filteration.elementAt(i) == cat)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          flag = true;
                        });
                        filteration.remove(cat);
                      },
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: textColor,
                      ),
                    ),
                    SizedBox(
                      width: width! * 0.01,
                    ),
                  ],
                )
          ])),
    );
  }

//Function to read the values from server ;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(listener: (context, state) {
      //   if (state is deletePostDone) {
      //  EasyLoading.showSuccess("Post deleted successfully!");
      //  Navigator.pop(context);
      // }
    }, builder: (context, state) {
      final height = MediaQuery.of(context).size.height * 1;
      final width = MediaQuery.of(context).size.width * 1;
      return Container(
          height: height * 0.6,
          color: Colors.white,
          child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leadingWidth: 65,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: Text(
                      'Tags',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: textColor,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      InkWell(
                        onTap: filteration.length <= 1
                            ? null
                            : () {
                                setState(() {
                                  filteration = {''};
                                  flag = true;
                                });
                              },
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: width * 0.05, top: height * 0.028),
                          child: Text(
                            "Clear",
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              color: filteration.length <= 1
                                  ? Colors.grey
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  body: Column(children: [
                    Container(
                      //should be retrived from the database
                      margin: EdgeInsets.only(
                        top: width * 0.05,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: height * 0.35,
                      child: Container(
                        child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: width * 0.5,
                                    childAspectRatio: width * 0.008,
                                    crossAxisSpacing: width * 0.02,
                                    mainAxisSpacing: width * 0.009),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                  child: Container(
                                margin: EdgeInsets.only(left: width * 0.02),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Row(children: [
                                    catButton(
                                        category: categories[index],
                                        cat: categories[index].name,
                                        color: categories[index].color),
                                  ]),
                                ),
                              ));
                            }),
                      ),
                    ),
                    InkWell(
                      onTap: flag == false
                          ? null
                          : () {
                              filteration.forEach((element) {
                                filterByTag.add(element);
                              });
                              filterByFriend = {''};
                              Navigator.pushAndRemoveUntil<void>(
                                context,
                                MaterialPageRoute<void>(
                                    builder: (BuildContext context) => Nav()),
                                ModalRoute.withName(Nav.id),
                              );
                            },
                      child: Container(
                          decoration: BoxDecoration(
                              color: flag == false ? Colors.grey : Buttonblue,
                              border: Border.all(
                                  color: flag == false
                                      ? Colors.grey
                                      : const Color(0xff0D6EF8)),
                              borderRadius: BorderRadius.circular(10)),
                          width: MediaQuery.of(context).size.width * .7,
                          height: MediaQuery.of(context).size.height * .07,
                          child: Center(
                            child: Text('Apply',
                                style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.055,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white)),
                          )),
                    ),
                  ]))));
    });
  }
}
