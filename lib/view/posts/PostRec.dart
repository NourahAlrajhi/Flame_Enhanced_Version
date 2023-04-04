// ignore_for_file: non_constant_identifier_names, file_names

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/Constants/theme.dart';
import 'package:flame/view/posts/imagePreview.dart';
import 'package:flame/view/posts/search.dart';
import 'package:flame/Constants/constants.dart';
import 'package:flame/model/categoriesModel.dart';
import 'package:flutter/material.dart';
import 'package:flame/Constants/color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_place/google_place.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flame/controller/Storing_DB.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../controller/user_cubit.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';

const kGoogleApiKey = "AIzaSyCNSCKybMgjaxZO_O_uqZWZpGfxKHsJ700";
DetailsResult? startPosition;

class PostRec extends StatefulWidget {
  const PostRec({
    Key? key,
  }) : super(key: key);

  @override
  State<PostRec> createState() => _PostRecState();
}

class _PostRecState extends State<PostRec> {
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  String? loggedInUser2;
  bool click = false;
  DetailsResult? VALUELOCATION;
  String PLACENAME = '';
  String? url;
  String? tag;
  bool? val1;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _descriptionController2 = TextEditingController();
  //DATA is the var for the categories
  String? categoryName;
  double lat = 0.0;
  double lng = 0.0;
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  final _formKey = GlobalKey<FormState>();
  double? h;
  double? w;
  String key = "AIzaSyCNSCKybMgjaxZO_O_uqZWZpGfxKHsJ700";
  List<CategoriesModel> categories = [];
  CategoriesModel? selectedCategory;
  String? selectedtag;

  @override
  void dispose() {
    _descriptionController2.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool validation() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    }
    return false;
  }

  //pickImage func
  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() {
        postImage = imageTemp;
      });
      return imageTemp;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('Failed to pick image: $e');
    }
  }

// select image dialog
  _selectImageDialog(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo',
                    style: TextStyle(
                      fontFamily: font,
                    )),
                onPressed: () {
                  pickImage(ImageSource.camera);
                  Navigator.pop(context);
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery',
                    style: TextStyle(
                      fontFamily: font,
                    )),
                onPressed: () {
                  pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text(
                "Cancel",
                style: TextStyle(fontFamily: font, color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  getAllCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("Category").get();
    categories = snapshot.docs.map((e) => CategoriesModel.fromJson(e)).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getAllCategories();
    googlePlace = GooglePlace(key);
    UserCubit.get(context).categories = [];
    getCurrentUser();
    postImage = null;
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        setState(() {
          uId != loggedInUser.uid;
          loggedInUser2 = loggedInUser.uid;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    h = MediaQuery.of(context).size.height;
    w = MediaQuery.of(context).size.width;

    return BlocConsumer<UserCubit, UserState>(builder: (context, state) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 65,
            leading: InkWell(
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(left: 9, top: 17),
                  child: const Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: font,
                        fontWeight: FontWeight.normal,
                        fontSize: 17,
                        color: Buttonblue),
                  ),
                ),
                onTap: () {
                  if (_descriptionController.text.isEmpty &&
                      categoryName == null &&
                      tag == null &&
                      _descriptionController2.text.isEmpty &&
                      postImage == null) {
                    Navigator.pop(context);
                  } else {
                    showEditAlertDialog(context);
                  }
                }),
            title: const Center(
              child: Text(
                'Post a Flame',
                style: TextStyle(
                  fontFamily: font,
                  color: textColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 17,
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  if (_descriptionController.text.isEmpty) {
                    EasyLoading.showError('Please Select a Place!');
                  } else if (categoryName == null) {
                    EasyLoading.showError('Please Select a Tag!');
                  } else if (tag == null) {
                    EasyLoading.showError('Please Select a Sub-Tag!');
                  } else if (_descriptionController2.text.isEmpty) {
                    EasyLoading.showError('Please write a review!');
                  } else if (postImage == null) {
                    EasyLoading.showError('Please Add an Image!');
                  } else {
                    addData(
                      postImage!,
                      categoryName!,
                      _descriptionController.text,
                      lat,
                      lng,
                      _descriptionController2.text,
                      tag!,
                      loggedInUser2!,
                    );

                    //  Navigator.pop(context);
                    //  EasyLoading.showSuccess(
                    //     'Recommendation posted successfully!');
                    Navigator.pop(context);
                    EasyLoading.showSuccess('Flame Posted Successfully!');
                    notifyFriends(
                        id: loggedInUser2!,
                        title: '${UserCubit.get(context).nameUser}');
                  }
                },
                child: const Text(
                  'Post',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: font,
                    color: Buttonblue,
                    fontWeight: FontWeight.normal,
                    fontSize: 17,
                  ),
                ),
              )
            ],
          ),
          backgroundColor: background,
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      right: 5,
                    ),
                  ),

                  //write a review box
                  Container(
                    margin: EdgeInsets.all(w! * 0.015),
                    decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(6),
                        // border: Border.all(color: lightgrey)
                        ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              // borderRadius: BorderRadius.only(topLeft: Radius.circular(6), bottomLeft:Radius.circular(6) ),
                              border: Border.all(color: lightgrey)),
                          width: w! * 0.33,
                          height: h! * 0.2,
                          child: InkWell(
                            onTap: () {
                              postImage == null
                                  ? _selectImageDialog(context)
                                  : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              imagePreview()));
                              setState(() {
                                postImage;
                              });
                            },
                            child: postImage == null
                                ? const Icon(Icons.camera_alt_rounded)
                                : ClipRRect(
                                    // borderRadius: BorderRadius.circular(6.0),
                                    child: Image.file(
                                    postImage!,
                                    fit: BoxFit.fill,
                                  )),
                          ),
                        ),
                        Container(
                            width: w! * 0.606,
                            height: h! * 0.2,
                            // margin: const EdgeInsets.only(top: 10, left: 5),
                            child: TextFormField(
                              key: _formKey,
                              maxLines: 20,
                              maxLength: 200,
                              controller: _descriptionController2,
                              decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: lightgrey),
                                    // borderRadius: BorderRadius.only(topRight: Radius.circular(6), bottomRight:Radius.circular(6) )
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(0))),
                                contentPadding:
                                    EdgeInsets.only(left: 10.0, top: 16.0),
                                hintText: "What do you think about the place?",
                                counterText: "",
                                hintStyle: TextStyle(fontFamily: font),
                                // border: OutlineInputBorder( borderSide: BorderSide(color: Colors.red),
                                //     borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight:Radius.circular(12) )),
                              ),
                            )),
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.all(w! * 0.015),
                      height: 60,
                      width: w!,
                      decoration: BoxDecoration(
                          // borderRadius: BorderRadius.all(Radius.circular(6)),
                          border: Border.all(color: lightgrey)),
                      child: InkWell(
                          onTap: () async {
                            final newLoca = await Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (context) => SearchandPreview(
                                  VALUELOCATION: VALUELOCATION),
                            ));
                            setState(() {
                              PLACENAME = newLoca!.name!;
                              _descriptionController.text = newLoca!.name!;
                              lat = newLoca.geometry!.location.lat;
                              lng = newLoca.geometry!.location.lng;
                            });
                          },
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: [
                              Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  child: const Icon(Icons.location_history)),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: PLACENAME == ''
                                    ? const Text(
                                        'Add loaction',
                                        style: TextStyle(
                                            fontFamily: font, fontSize: 16),
                                      )
                                    : Text(
                                        PLACENAME,
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: font,
                                            fontSize: 16),
                                      ),
                              ),
                            ]),
                          ))),

                  Container(
                    margin: EdgeInsets.only(left: 5, top: h! * 0.005),
                    child: const Text(
                      'Select a tag ',
                      style: TextStyle(
                          fontFamily: font,
                          fontSize: 16,
                          color: textColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    //should be retrived from the database
                    margin: const EdgeInsets.only(top: 5),
                    width: MediaQuery.of(context).size.width,
                    height: 160,
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 3.75,
                                crossAxisSpacing: 0.8,
                                mainAxisSpacing: 0.8),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                              child: Container(
                            margin: const EdgeInsets.all(4),
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
                  UserCubit.get(context).categories.isEmpty
                      ? const SizedBox(
                          height: 2,
                        )
                      : selectedCategory == null
                          ? const SizedBox()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 5, top: 10),
                                  child: const Text(
                                    'Select a sub-tag ',
                                    style: TextStyle(
                                        fontFamily: font,
                                        fontSize: 16,
                                        color: textColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(4),
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: DropdownSearch<String>(
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                          isCollapsed: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 14, horizontal: 8),
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.only(
                                                left: w! * 0.02,
                                                top: 10,
                                                bottom: 10),
                                            child: SvgPicture.asset(
                                              'assets/icons/subtag.svg',
                                              height: 0.5,
                                              width: 0.5,
                                              color: Color(int.parse(
                                                  selectedCategory!.color!
                                                      .replaceAll('#', '0x'))),
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          hintText: 'select sub-tag'),
                                    ),
                                    popupProps: PopupProps.bottomSheet(
                                      showSelectedItems: true,
                                      showSearchBox: true,
                                      searchFieldProps: TextFieldProps(
                                          cursorColor: Buttonblue),
                                    ),
                                    items: selectedCategory!.tags!,
                                    onChanged: (s) {
                                      setState(() {
                                        tag = s;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                ],
              ),
            ),
          ),
        ),
      );
    }, listener: (context, state) {
      if (state is Updateimg) {
        setState(() {
          postImage;
        });
      }
    });
  }

////category buttons
  catButton({CategoriesModel? category, String? cat, String? color}) {
    Color? colrs2 = Color(int.parse(color!.replaceAll('#', '0x')));
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height * 0.06,
      width: width * 0.45,
      child: ElevatedButton(
          onPressed: selectedCategory == null
              ? () async {
                  UserCubit.get(context).SubCategories(subtag: cat!);
                  //   getNameDoc(nameCal: 'Rtag');

                  // ignore: prefer_conditional_assignment
                  if (selectedCategory == null) {
                    selectedCategory = category;
                  }
                  setState(() {
                    categoryName = cat;
                    click = true;
                  });
                }
              : () {},
          style: ElevatedButton.styleFrom(
              side: BorderSide(
                  color: selectedCategory == category
                      ? colrs2
                      : selectedCategory == null
                          ? colrs2
                          : inActiveColor),
              elevation: 0.5,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              backgroundColor: selectedCategory == category
                  ? colrs2
                  : selectedCategory == null
                      ? background
                      : inActiveColor),
          child: Row(children: <Widget>[
            SizedBox(
              width: width * 0.01,
            ),
            Expanded(
              child: Center(
                child: Text(
                  cat!,
                  style: TextStyle(
                      fontSize: width * 0.045,
                      color: textColor,
                      fontFamily: font,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SizedBox(
              width: width * 0.01,
            ),
            if (selectedCategory == category)
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      selectedCategory = null;
                      setState(() {});
                    },
                    child: const Icon(
                      Icons.close,
                      size: 24,
                      color: textColor,
                    ),
                  ),
                  SizedBox(
                    width: width * 0.01,
                  ),
                ],
              ),
          ])),
    );
  }

  bool isItemDisabled(String s) {
    if (s.startsWith('I')) {
      return true;
    } else {
      return false;
    }
  }

  itemSelectionChanged(String s) {
    selectedtag = s;
  }

  notifyFriends({required String id, required String title}) {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    var id2 = const Uuid().v4();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .collection('FriendsTokens')
        .get()
        .then((value) {
      for (var element in value.docs) {
        FirebaseFirestore.instance.collection('Notification').doc(id2).set({
          ' NotificationId': id2,
          'UserNotification': element.data()['senderId'],
          'Title': title,
          'SubTitle': 'posted a new flame!',
          'SenderPic': ImageUser,
          'SenderID': uId,
          'PostDate': formattedDate
        });

        const endpoint = "https://fcm.googleapis.com/fcm/send";

        final header = {
          'Authorization':
              'key=AAAA0pGz0Y4:APA91bEN-WcpGkFz0YASrfQ4-zOB6I6zX24ROmsanxmFFwK-Fs-8fbEIz4XH72xrXh20YTSt4amWoNEbWbp7fUVxQzTWEfjZ3Eg_pHNFioamF0PtVWr58ryUrLDCAw0s9plzf5QNo8UN',
          'Content-Type': 'application/json'
        };

        http.post(Uri.parse(endpoint),
            headers: header,
            body: jsonEncode(<String, dynamic>{
              "to": element.data()['token'], // topic name
              "notification": <String, dynamic>{
                // "body": "$title posted a new flame",
                "title": "$title posted a new flame",
                'priority': 'high',
                //   "sound": "default",
              },

              "data": {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'id': '1',
                'status': 'done',
                // 'message': "$title posted a new flame",
              }
            }));
      }
    });
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
      child: const Text(
        "Discard",
        style: TextStyle(
          color: Colors.red,
          fontFamily: font,
        ),
      ),
      onPressed: () {
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: const Text("Are you sure you want to discard your post?",
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
}
