import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/controller/user_cubit.dart';
import 'package:flame/view/Friends/FriendsList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../Constants/constants.dart';
import '../../Constants/color.dart';

/////height: MediaQuery.of(context).size.height,
class addFriend extends StatefulWidget {
  final String? IDEE;
  addFriend({Key? key, this.IDEE}) : super(key: key);
  static String id = "addFriend";

  @override
  State<addFriend> createState() => _addFriendState();
}

class _addFriendState extends State<addFriend> with TickerProviderStateMixin {
  List<Contact> contacts = [];
  bool _waiting = true;
  late TabController tabController;

  String? userImage;
  Future GetNameandPic() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uId)
        .get()
        .then((value) {
      userImage = value.data()!['userImage'];
    });
    setState(() {
      // userImage = userImage;
      // userName = userName;
    });
  }

  @override
  void initState() {
    GetNameandPic();
    getPhoneData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getPhoneData() async {
    _waiting = true;
    if (await FlutterContacts.requestPermission())
      // ignore: curly_braces_in_flow_control_structures
      await FlutterContacts.getContacts(withProperties: true, withPhoto: false)
          .then((value) {
        setState(() {
          contacts = value;
          _waiting = false;
        });
        UserCubit.get(context).getSearchContacs(contacts, '', context);
        UserCubit.get(context).getAllDone();
        UserCubit.get(context).getAllLoaded();
      });
  }

  void messageFriend(String Recpiant) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      Uri SMSURri = Uri(
          scheme: 'sms',
          path: '$Recpiant',
          queryParameters: <String, String>{
            'body': Uri.encodeComponent('Hi!'),
          });

      String uri = SMSURri.toString().replaceAll('?', '&');
      launchUrlString(uri);
    } else {
      Uri SMSURri = Uri(
          scheme: 'sms',
          path: '$Recpiant',
          queryParameters: <String, String>{
            'body': Uri.encodeComponent(
                'I want to make my circle warmer with your Flames. Tap the Link to download Flame'),
          });

      try {
        launchUrl(SMSURri, mode: LaunchMode.platformDefault);
      } catch (error) {
        print(error);
      }
    }
  }

  showAlertDialog(BuildContext context, String name) {
    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      title: const Text(""),
      content:
          const Text('your friend is not a user, do you want to invite them?',
              style: TextStyle(
                fontFamily: 'Tajawal',
              )),
      actions: [
        TextButton(
            onPressed: () {
              messageFriend(name);
            },
            child: const Text(
              'Invite',
              style: TextStyle(
                fontFamily: 'Tajawal',
              ),
            )),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel',
                style: TextStyle(
                  fontFamily: 'Tajawal',
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

  showAlertDialog2(BuildContext context, VoidCallback fun) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      title: Text(""),
      content: Text('Are you sure you want to delete your friend?',
          style: TextStyle(
            fontFamily: 'Tajawal',
          )),
      actions: [
        TextButton(
            onPressed: fun,
            child: Text('Delete',
                style: TextStyle(fontFamily: 'Tajawal', color: Colors.red))),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel',
                style: TextStyle(
                  fontFamily: 'Tajawal',
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
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var searchController = TextEditingController();

    return BlocConsumer<UserCubit, UserState>(listener: (context, state) {
      if (state is CheckUserError) {
        // print("www ${state.phone}");

        //
        String recipents = state.phone; //${state.phone}
        showAlertDialog(context, recipents);

        ///
        // _sendSMS(message, recipents);
      } else if (state is GetAllFrinds) {
        const CircularProgressIndicator();
        //EasyLoading.showSuccess("Added successfully");
      } else if (state is CheckUserLoaded) {
        const CircularProgressIndicator();
      }
      if (state is deleteFrindDone) {
        EasyLoading.showInfo("Friend deleted successfully!");
      }
    }, builder: (context, state) {
      return Scaffold(
        backgroundColor: background,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: background,
          elevation: 0,
          leadingWidth: 70,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Container(
            width: 250,
            height: 40,
            margin: const EdgeInsets.only(),
            child: Center(
              child: Text(
                'Add friends',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 5),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(5),
                child: TextFormField(
                  controller: searchController,
                  style: const TextStyle(color: textColor),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    hintText: "Search your contact...",
                  ),
                  onChanged: (value) {
                    UserCubit.get(context)
                        .getSearchContacs(contacts, value, context);
                  },
                ),
              ),
              Expanded(
                child: Container(
                    margin: const EdgeInsets.all(2),
                    height: height,
                    child: UserCubit.get(context).search.isEmpty
                        ? Center(
                            child: Container(
                                margin: EdgeInsets.all(70),
                                height: 70,
                                width: width * 0.5,
                                child:
                                    Center(child: CircularProgressIndicator())),
                          )
                        : ListView.separated(
                            itemBuilder: (_, index) {
                              ////can be from the application
                              // Uint8List? img = contacts[index].photo;
                              return Container(
                                margin: const EdgeInsets.only(
                                    top: 5, bottom: 5, left: 10, right: 5),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      child: Image(
                                        image: AssetImage(
                                            'assets/images/defaultProfilePic.png'),
                                        height: 36,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            "${UserCubit.get(context).search[index].fName} ${UserCubit.get(context).search[index].lName}  ",
                                            style: TextStyle(
                                              fontFamily: 'Tajawal',
                                            )),

                                        ///  Text(
                                        //    "${UserCubit.get(context).search[index].phone}"),
                                        // Text(
                                        //   "${UserCubit.get(context).search[index].status}"),
                                      ],
                                    ),
                                    const Spacer(),
                                    UserCubit.get(context).search[index].status ==
                                            "loaded"
                                        ? Container(
                                            margin: const EdgeInsets.only(
                                                right: 18, top: 3, bottom: 3),
                                            decoration: BoxDecoration(
                                                color: background,
                                                // border: Border.all(
                                                //  color: buttonColor),
                                                border: Border.all(
                                                    color: Buttonblue,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            width: 70,
                                            height: 32,
                                            child: InkWell(
                                              highlightColor: primary,
                                              splashColor: primary,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: const Center(
                                                child: const Text(
                                                  "Pending",
                                                  style: TextStyle(
                                                    fontFamily: 'Tajawal',
                                                    color: Buttonblue,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                EasyLoading.showInfo(
                                                    "Waiting for accept!");
                                              },
                                            ))
                                        : UserCubit.get(context)
                                                    .search[index]
                                                    .status ==
                                                "accept"
                                            ? Container(
                                                margin: const EdgeInsets.only(
                                                    right: 18,
                                                    top: 3,
                                                    bottom: 3),
                                                decoration: BoxDecoration(
                                                    color: background,
                                                    // border: Border.all(
                                                    //  color: buttonColor),
                                                    border: Border.all(
                                                        color: Buttonblue,
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                width: 70,
                                                height: 32,
                                                child: InkWell(
                                                  highlightColor: primary,
                                                  splashColor: primary,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: const Center(
                                                    child: const Text(
                                                      "Added",
                                                      style: TextStyle(
                                                        fontFamily: 'Tajawal',
                                                        color: Buttonblue,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    String n =
                                                        UserCubit.get(context)
                                                            .search[index]
                                                            .fName;
                                                    EasyLoading.showInfo(
                                                        "You are already friends with $n!");
                                                  },
                                                ))
                                            : UserCubit.get(context)
                                                        .search[index]
                                                        .status ==
                                                    "normal"
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 18,
                                                            top: 3,
                                                            bottom: 3),
                                                    decoration: BoxDecoration(
                                                        color: Buttonblue,
                                                        // border: Border.all(
                                                        //  color: buttonColor),
                                                        border: Border.all(
                                                            color: Buttonblue,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius.circular(10)),
                                                    width: 70,
                                                    height: 32,
                                                    child: InkWell(
                                                      highlightColor: primary,
                                                      splashColor: primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: const Center(
                                                        child: Text(
                                                          "Add",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Tajawal',
                                                            color: white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        UserCubit.get(context)
                                                            .sendRequest(
                                                                context:
                                                                    context,
                                                                name: UserCubit.get(
                                                                        context)
                                                                    .search[
                                                                        index]
                                                                    .fName,
                                                                phone: UserCubit
                                                                        .get(
                                                                            context)
                                                                    .search[
                                                                        index]
                                                                    .phone,
                                                                SenderPhoto:
                                                                    userImage!);
                                                      },
                                                    ))
                                                : const SizedBox(
                                                    child: Text("Error!",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Tajawal',
                                                            color:
                                                                Colors.black)),
                                                  ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (_, index) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Divider(
                                  color: lightgrey,
                                  thickness: 1,
                                ),
                              );
                            },
                            itemCount: UserCubit.get(context).search.length)),
              ),
            ],
          ),
        ),
      );
    });
  }
}
