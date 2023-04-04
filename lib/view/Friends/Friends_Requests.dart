import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/Constants/constants.dart';
import 'package:flame/controller/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../Constants/color.dart';

class DetailsRequist extends StatefulWidget {
  const DetailsRequist({super.key});
  static String id = "requestList";
  @override
  State<DetailsRequist> createState() => _DetailsRequistState();
}

class _DetailsRequistState extends State<DetailsRequist> {
  @override
  void initState() {
    UserCubit.get(context).getRequest(id: uId);
    // TODO: implement initState
    super.initState();
    GetNameandPic();
  }

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
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (State is UpdateRequestCancle) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          )),
                    )
                  ],
                ),
              ),
              centerTitle: true,
              title: const Text(
                'Friends Requests',
                style: TextStyle(color: textColor, fontFamily: 'Tajawal'),
              ),
            ),
            body: UserCubit.get(context).requestFriends.isEmpty
                ? Center(
                    child: Container(
                        margin: const EdgeInsets.all(60),
                        height: 70,
                        width: width * 0.4,
                        child: const Center(
                            child: Text('You have no requests',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                )))),
                  )
                : SizedBox(
                    height: height * 0.3,
                    child: Flexible(
                      child: ListView.separated(
                          itemBuilder: (_, index) {
                            // Uint8List? img = contacts[index].photo;
                            return Container(
                              margin: const EdgeInsets.only(
                                  left: 10, top: 5, right: 5),
                              child: Row(
                                children: [
                                  Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100)),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.white,
                                              spreadRadius: 4),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          UserCubit.get(context).requestFriends[
                                                              index]
                                                          ['FriendsImage'] ==
                                                      null ||
                                                  UserCubit.get(context)
                                                              .Notification[
                                                          index]['SenderPic'] ==
                                                      'null'
                                              ? 'https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2FdefaultProfilePic.png?alt=media&token=cb0d6f13-05c0-41c6-bb5a-d43f741b9adf'
                                              : UserCubit.get(context)
                                                  .requestFriends[index]
                                                      ['FriendsImage']
                                                  .toString(),
                                        ),
                                      )
                                      /*  child: CircleAvatar(
                        
                       // borderRadius: BorderRadius.circular(100),
                     backgroundImage:NetworkImage(
                          UserCubit.get(context).Notification[index]
                                          ['SenderPic'] ==
                                      null ||
                                  UserCubit.get(context).Notification[index]
                                          ['SenderPic'] ==
                                      'null'
                              ? 'https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2FdefaultProfilePic.png?alt=media&token=6b1583e9-76ff-4f24-a518-c2a7062cbb29'
                              : UserCubit.get(context).Notification[index]
                                  ['SenderPic'],
                              ),
                            )*/

                                      ),
                                  const SizedBox(width: 10),
                                  Text(
                                      "${UserCubit.get(context).requestFriends[index]['nameSender']}",
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                      )),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () {
                                      print("object");
                                      UserCubit.get(context)
                                          .updateAcceptRequest(
                                        dateFriend: UserCubit.get(context)
                                                .requestFriends[index]
                                            ['dateSender'],
                                        idFrinds: UserCubit.get(context)
                                            .requestFriends[index]['idSender'],
                                        idPost: UserCubit.get(context)
                                            .requestFriends[index]['idRequest'],
                                        nameFriend: UserCubit.get(context)
                                                .requestFriends[index]
                                            ['nameSender'],
                                        phoneFriend: UserCubit.get(context)
                                                .requestFriends[index]
                                            ['phoneSender'],
                                        FriendsImage: UserCubit.get(context)
                                                .requestFriends[index]
                                            ['FriendsImage'],
                                        SenderPic: userImage!,
                                      );
                                      UserCubit.get(context)
                                          .getRequest(id: uId);

                                      EasyLoading.showSuccess(
                                          "Friend accepted successfully");
                                    },
                                    child:
                                        // Container(
                                        //         margin: const EdgeInsets.only(
                                        //             right: 18, top: 3, bottom: 3),
                                        //         decoration: BoxDecoration(
                                        //             // color: Buttonblue,
                                        //             border: Border.all(
                                        //                 color: Colors.black54,
                                        //                 width: 1),
                                        //             borderRadius:
                                        //                 BorderRadius.circular(10)),
                                        //         width: 70,
                                        //         height: 32,
                                        //         child: const Center(
                                        //             child: const Text(
                                        //               "Accept",
                                        //               style: TextStyle(
                                        //                 fontFamily: 'Tajawal',
                                        //                 color: Buttonblue,
                                        //                 fontWeight: FontWeight.w500,
                                        //               ),
                                        //             ),
                                        //           ),)
                                        Container(
                                      decoration: BoxDecoration(
                                          // color: lightgrey,
                                          border: Border.all(
                                            color: Colors.green,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10)
                                          // shape: BoxShape.rectangle
                                          ),
                                      width: 50,
                                      height: 30,
                                      child: const Icon(
                                        Icons.done,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: width * 0.018,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showAlertDialog(index);
                                    },
                                    child:
                                        // Container(
                                        //         margin: const EdgeInsets.only(
                                        //             right: 18, top: 3, bottom: 3),
                                        //         decoration: BoxDecoration(
                                        //             // color: Colors.red,
                                        //             border: Border.all(
                                        //                 color: Colors.black54,
                                        //                 width: 1),
                                        //             borderRadius:
                                        //                 BorderRadius.circular(10)),
                                        //         width: 70,
                                        //         height: 32,
                                        //         child: const Center(
                                        //             child: const Text(
                                        //               "Reject",
                                        //               style: TextStyle(
                                        //                 fontFamily: 'Tajawal',
                                        //                 color: Colors.red,
                                        //                 fontWeight: FontWeight.w500,
                                        //               ),
                                        //             ),
                                        //           ),)
                                        Container(
                                      decoration: BoxDecoration(
                                        // color: lightgrey,
                                        border: Border.all(
                                          color: Colors.red,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        // shape: BoxShape.circle
                                      ),
                                      width: 50,
                                      height: 30,
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: width * 0.018,
                                  )
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (_, index) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(
                                thickness: 1,
                                color: lightgrey,
                              ),
                            );
                          },
                          itemCount:
                              UserCubit.get(context).requestFriends.length),
                    ),
                  )

            ///////////////////////////////////////
            );
      },
    );
  }

  showAlertDialog(int index) {
    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      title: const Text(""),
      content: Text(
          'Are you sure you want to reject ${UserCubit.get(context).requestFriends[index]['nameSender']}?',
          style: TextStyle(
            fontFamily: 'Tajawal',
          )),
      actions: [
        TextButton(
            onPressed: () {
              UserCubit.get(context).updateCancelRequest(
                  phoneFriend: UserCubit.get(context).requestFriends[index]
                      ['phoneSender'],
                  idFrinds: UserCubit.get(context).requestFriends[index]
                      ['idSender'],
                  idPost: UserCubit.get(context).requestFriends[index]
                      ['idRequest']);
              UserCubit.get(context).getRequest(id: uId);

              EasyLoading.showSuccess("Friend rejected successfully");
            },
            child: const Text(
              'Reject',
              style: TextStyle(color: Colors.red, fontFamily: 'Tajawal'),
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
}
