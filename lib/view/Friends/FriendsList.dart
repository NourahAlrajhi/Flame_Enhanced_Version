import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flame/view/Friends/FriendProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../users_profile/Notifications.dart';
import 'addFriend.dart';
import '../../Constants/color.dart';
import '../../Constants/constants.dart';
import '../../controller/user_cubit.dart';

class friendsRequests extends StatefulWidget {
  final String? IDEE;
  const friendsRequests({super.key, this.IDEE});

  @override
  State<friendsRequests> createState() => _friendsRequestsState();
}

class _friendsRequestsState extends State<friendsRequests> {
  @override
  void initState() {
    UserCubit.get(context).getUserFriend(id: widget.IDEE!);
    super.initState();
  }

  showAlertDialog(BuildContext context, VoidCallback fun) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      title: Text(""),
      content: Text('Are you sure you want to remove your friend ?',
          style: TextStyle(
            fontFamily: 'Tajawal',
          )),
      actions: [
        TextButton(
            onPressed: fun,
            child: Text(
              'Remove',
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(listener: (context, state) {
      if (state is deleteFrindDone) {
        EasyLoading.showSuccess("Friend removed successfully!");
        Navigator.pop(context);
      }
    }, builder: (context, state) {
      return Scaffold(
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
            title: Center(
              child: Center(
                child: Text(
                  'Friends List',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: textColor,
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.person_add,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => addFriend()));
                },
              ),
            ]),
        body: state is deleteFrindLoaded
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 10, top: 25),
                child: UserCubit.get(context).UserFriend.isEmpty
                    ? const Center(
                        child: Text('You have no frineds yet',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                            )),
                      )
                    : ListView.separated(
                        //  physics: ClampingScrollPhysics(),
                        //  padding: EdgeInsets.zero,
                        //   itemCount: UserCubit.get(context).Notification.length,
                        itemBuilder: (_, index) {
                          return Slidable(
                              actionPane: SlidableStrechActionPane(),
                              actionExtentRatio: 0.25,
                              child: Container(
                                child: ListTile(
                                  leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100)),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color(0xffC2DDC6),
                                              spreadRadius: 2.5),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          UserCubit.get(context)
                                                              .UserFriend[index]
                                                          ['FriendsImage'] ==
                                                      null ||
                                                  UserCubit.get(context)
                                                              .UserFriend[index]
                                                          ['FriendsImage'] ==
                                                      'null'
                                              ? 'https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2FdefaultProfilePic.png?alt=media&token=cb0d6f13-05c0-41c6-bb5a-d43f741b9adf'
                                              : UserCubit.get(context)
                                                  .UserFriend[index]
                                                      ['FriendsImage']
                                                  .toString(),
                                        ),
                                      )),

                                  title: Text(
                                    "${UserCubit.get(context).UserFriend[index]['nameFriend']}",
                                    style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        color: kTextColor),
                                  ),
                                  // subtitle: Text(
                                  //   "${UserCubit.get(context).Notification[index]['SubTitle']}"),
                                  onTap: () {
                                    // showModalBottomSheet(
                                    //   context: context,
                                    //   enableDrag: false,
                                    //   isDismissible: false,
                                    //   isScrollControlled: true,
                                    //   shape: RoundedRectangleBorder(
                                    //     borderRadius: BorderRadius.vertical(
                                    //       top: Radius.circular(30),
                                    //     ),
                                    //   ),
                                    //   builder: (context) =>
                                    //       FriendProfile(),
                                    //   backgroundColor: Colors.transparent,
                                    // );
                                    showCupertinoModalBottomSheet(
                                      context: context,
                                      // expand: true,
                                      isDismissible: true,
                                      topRadius: Radius.circular(20),
                                      builder: (context) => FriendProfile(
                                          Pic: UserCubit.get(context)
                                                  .UserFriend[index]
                                              ['FriendsImage'],
                                          name: UserCubit.get(context)
                                              .UserFriend[index]['nameFriend'],
                                          phone: UserCubit.get(context)
                                              .UserFriend[index]['phoneFriend'],
                                          FRIENDID: UserCubit.get(context)
                                              .UserFriend[index]['idFriend']),
                                      backgroundColor: Colors.transparent,
                                    );
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => Profile_(
                                    //             ID: UserCubit.get(context)
                                    //                 .UserFriend[index]['idFriend'],
                                    //           )),
                                    // );

                                    //   UserCubit.get(context).getNotification(id: uId);
                                  },
                                ),
                              ),
                              secondaryActions: <Widget>[
                                IconSlideAction(
                                  caption: 'Remove',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () async {
                                    showAlertDialog(
                                      context,
                                      () {
                                        UserCubit.get(context).deleteFriends(
                                            idFriend: UserCubit.get(context)
                                                .UserFriend[index]['idFriend']);
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ]);
/*Dismissible(
                    key: Key("${UserCubit.get(context).UserFriend[index]['nameFriend']}"),
                    background: Container(
                      alignment: AlignmentDirectional.centerEnd,
                      color: Colors.red,
                      child: Icon(Icons.delete,color: Colors.white,),
                    ),
                    onDismissed:(direction){
setState(() {
 UserCubit.get(context).UserFriend.removeAt(index);
});
                    } ,
                    direction: DismissDirection.endToStart,*/
                          /* child: ListTile(
                      leading: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                            boxShadow: [
                              BoxShadow(color: Colors.white, spreadRadius: 4),
                            ],
                            image: DecorationImage(
                                image: AssetImage(UserCubit.get(context)
                                            .UserFriend[index]['FriendsImage'] ==
                                        null
                                    ? 'assets/images/defaultProfilePic.png'
                                    : UserCubit.get(context).UserFriend[index]
                                        ['FriendsImage']),
                                fit: BoxFit.cover)),
                      ),
                      title: Text(
                        "${UserCubit.get(context).UserFriend[index]['nameFriend']}",
                        style: TextStyle(color: kTextColor),
                      ),
                      // subtitle: Text(
                      //   "${UserCubit.get(context).Notification[index]['SubTitle']}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profile_(
                                    ID: UserCubit.get(context).UserFriend[index]
                                        ['idFriend'],
                                  )),
                        );
                  
                        //   UserCubit.get(context).getNotification(id: uId);
                      },
                    ),*/
                          //);
                        },

                        separatorBuilder: (_, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(
                              thickness: 1,
                              color: Color.fromARGB(255, 212, 210, 210),
                            ),
                          );
                        },
                        itemCount: UserCubit.get(context).UserFriend.length,
                      ),
              ),
      );
    });
  }
}
