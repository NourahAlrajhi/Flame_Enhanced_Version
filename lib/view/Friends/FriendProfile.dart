import 'package:cached_network_image/cached_network_image.dart';
import 'package:flame/view/Friends/FriendRec.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../controller/user_cubit.dart';
import '../../Constants/color.dart';
import '../../Constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendProfile extends StatefulWidget {
  final String? Pic;
  final String? name;
  final String? phone;
  final String? FRIENDID;

  const FriendProfile(
      {super.key, this.Pic, this.name, this.phone, this.FRIENDID});

  @override
  State<FriendProfile> createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {
  @override
  showAlertDialog(BuildContext context, VoidCallback fun) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      title: Text(""),
      content: Text('Are you sure you want to delete your friend ?',
          style: TextStyle(
            fontFamily: 'Tajawal',
          )),
      actions: [
        TextButton(
            onPressed: fun,
            child: Text(
              'Delete',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.red),
            )),
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

  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;
    return BlocConsumer<UserCubit, UserState>(listener: (context, state) {
      // TODO: implement listener
    }, builder: (context, state) {
      return Container(
          height: height * 0.66,
          color: Colors.white,
          child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
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
                      SizedBox(
                        height: 25,
                      )
                    ],
                  ),
                  // const Icon(Icons.more_horiz_outlined ,color: Colors.black54,),
                  centerTitle: true,
                  // leading: IconButton(
                  //   icon: const Icon(
                  //     Icons.close,
                  //     color: Colors.black,
                  //   ),
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: height * 0.065,
                        ),
                        Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xffC2DDC6),
                                    spreadRadius: 2.5),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                widget.Pic! == null || widget.Pic! == 'null'
                                    ? 'https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2FdefaultProfilePic.png?alt=media&token=6b1583e9-76ff-4f24-a518-c2a7062cbb29'
                                    : widget.Pic!.toString(),
                              ),
                            )),
                        SizedBox(
                          height: height * 0.021,
                        ),
                        Text(
                          // "${UserCubit.get(context).UserFriend[0]['nameFriend']}",
                          "${widget.name!}",
                          style: TextStyle(
                              color: kTextColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Tajawal'),
                        ),
                        Text(
                          // "${UserCubit.get(context).UserFriend[2]['phone']}",
                          // "+966547282899",
                          "${widget.phone!}",
                          style: TextStyle(
                              color: kTextColor, fontFamily: 'Tajawal'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.05,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              messageFriend(widget.phone!, widget.name!);
                              // here dana message other friend in general
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  SvgPicture.asset(
                                    "assets/icons/message-2.svg",
                                    height: height * 0.032,
                                  ),
                                  SizedBox(
                                    width: width * 0.014,
                                  ),
                                  Text("Message",
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                      )),
                                ]),
                                Icon(Icons.arrow_forward_ios_outlined)
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(
                              thickness: 0.5,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FriendRec(
                                        FRIENDUID: widget.FRIENDID,
                                        NAMEFRIEND: widget.name)),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  SvgPicture.asset(
                                    'assets/icons/codicon_flame.svg',
                                    width: 0.38 * width,
                                    height: height * 0.038,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: width * 0.012,
                                  ),
                                  Text("View flames",
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                      )),
                                ]),
                                Icon(Icons.arrow_forward_ios_outlined)
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(
                              thickness: 0.5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Icon(Icons.notifications_active_outlined,
                                    color: Colors.black),
                                SizedBox(
                                  width: width * 0.016,
                                ),
                                Text("Enable notifications",
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                    )),
                              ]),
                              SwitchScreen(FRIENDID: widget.FRIENDID!),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(
                              thickness: 0.5,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              showAlertDialog(
                                context,
                                () {
                                  UserCubit.get(context).deleteFriends(
                                      idFriend: widget.FRIENDID!);
                                  Navigator.pop(context);
                                },
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white10,
                                  ),
                                  SizedBox(
                                    width: width * 0.016,
                                  ),
                                  Text(
                                    "Remove friend",
                                    style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ]),
                                // Icon(Icons.arrow_forward_ios_outlined, color: Colors.red,)
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height * 0.025,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )));
    });
  }

  void messageFriend(String Recpiant, String Friendname) {
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
                'Hey $Friendname\nor should I say my twin flame!!'),
          });

      try {
        launchUrl(SMSURri, mode: LaunchMode.platformDefault);
      } catch (error) {
        print(error);
      }
    }
  }
}

class SwitchScreen extends StatefulWidget {
  final String? FRIENDID;

  const SwitchScreen({super.key, this.FRIENDID});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  final switchData = GetStorage();
  bool isSwitched = false;
  bool flag = false;

  void isMyFriendHere({required String idFriend}) {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(idFriend)
        .collection('FriendsTokens')
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (element.data()['senderId'] == uId) {
          setState(() {
            flag = true;
          });
        } else {
          continue;
        }
      }
    });
  }

  void initState() {
    super.initState();
    isMyFriendHere(idFriend: widget.FRIENDID!);
    if (switchData.read('isSwitched') != null) {
      setState(() {
        isSwitched = switchData.read('isSwitched');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
        scale: 1.2,
        child: Switch(
          value: flag,
          onChanged: (value1) {
            // isMyFriendHere(idFriend: widget.FRIENDID!);
            print('---------------FRIEND-----------');
            print(flag);
            // if (flag) {
            setState(() {
              flag = value1;

              switchData.write('isSwitched', isSwitched);
            });
            // }

            if (value1) {
              UserCubit.get(context).friendsToken(idFriend: widget.FRIENDID!);
            } else if (!value1) {
              UserCubit.get(context).deleteTokens(idFriend: widget.FRIENDID!);
            }
          },
          activeColor: Buttonblue,
          // activeTrackColor: Colors.grey,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Color.fromARGB(255, 198, 198, 198),
        ));
  }
}
