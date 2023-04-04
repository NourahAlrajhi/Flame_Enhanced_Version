import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controller/user_cubit.dart';
import '../../../Constants/color.dart';
import '../../../Constants/constants.dart';
import '../Nav.dart';

class FilterByFriend extends StatefulWidget {
  const FilterByFriend({super.key});

  @override
  State<FilterByFriend> createState() => _FilterState();
}

class _FilterState extends State<FilterByFriend> {
  Timer? timer;

  @override
  void initState() {
    UserCubit.get(context).getUserFriend(id: uId);
    super.initState();
    filteredFriends = {''};
    filterByFriend.forEach((element) {
      filteredFriends.add(element);
    });
    flagFbut = false;
    timer = Timer.periodic(Duration(milliseconds: 50), (Timer t) {
      flagbut();
      setState(() {
        flagFbut = flagbut();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {},
        builder: (context, state) {
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
                        'Friends',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          color: textColor,
                        ),
                      ),
                      centerTitle: true,
                      actions: [
                        InkWell(
                          onTap: filteredFriends.length <= 1
                              ? null
                              : () {
                                  setState(() {
                                    flagFbut = true;
                                    filteredFriends = {''};
                                  });
                                },
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: width * 0.05, top: height * 0.028),
                            child: Text(
                              "Clear",
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                color: filteredFriends.length <= 1
                                    ? Colors.grey
                                    : Buttonblue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    body: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: UserCubit.get(context).UserFriend.isEmpty
                              ? const Center(
                                  child: Text('You have no frineds yet',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                      )),
                                )
                              : Container(
                                  height: 280,
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    child: ListView.separated(
                                      itemBuilder: (_, index) {
                                        return Container(
                                          margin: EdgeInsets.only(top: 5),
                                          child: ListTile(
                                            leading: Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(100)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color:
                                                            Color(0xffCBCBCB),
                                                        spreadRadius: 2.5),
                                                  ],
                                                ),
                                                child: CircleAvatar(
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                    UserCubit.get(context).UserFriend[
                                                                        index][
                                                                    'FriendsImage'] ==
                                                                null ||
                                                            UserCubit.get(context)
                                                                            .UserFriend[
                                                                        index][
                                                                    'FriendsImage'] ==
                                                                'null'
                                                        ? 'https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2FdefaultProfilePic.png?alt=media&token=6b1583e9-76ff-4f24-a518-c2a7062cbb29'
                                                        : UserCubit.get(context)
                                                            .UserFriend[index]
                                                                ['FriendsImage']
                                                            .toString(),
                                                  ),
                                                )),
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "${UserCubit.get(context).UserFriend[index]['nameFriend']}",
                                                  style: TextStyle(
                                                      fontFamily: 'Tajawal',
                                                      color: kTextColor),
                                                ),
                                                checkboxFriend(
                                                    FRIENDID:
                                                        '${UserCubit.get(context).UserFriend[index]['idFriend']}')
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (_, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Divider(
                                            thickness: 1,
                                            color: Color.fromARGB(
                                                255, 212, 210, 210),
                                          ),
                                        );
                                      },
                                      itemCount: UserCubit.get(context)
                                          .UserFriend
                                          .length,
                                    ),
                                  ),
                                ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                              color:
                                  flagbut() == false ? Colors.grey : Buttonblue,
                              border: Border.all(
                                  color: flagbut() == false
                                      ? Colors.grey
                                      : Buttonblue),
                              borderRadius: BorderRadius.circular(10)),
                          width: MediaQuery.of(context).size.width * .7,
                          height: MediaQuery.of(context).size.height * .07,
                          child: Center(
                              child: InkWell(
                            onTap: flagbut() == false
                                ? null
                                : () {
                                    filteredFriends.forEach((element) {
                                      filterByFriend.add(element);
                                    });
                                    filterByTag = {''};

                                    Navigator.pushAndRemoveUntil<void>(
                                      context,
                                      MaterialPageRoute<void>(
                                          builder: (BuildContext context) =>
                                              Nav()),
                                      ModalRoute.withName(Nav.id),
                                    );
                                  },
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
                      ],
                    ),
                  )));
        });
  }
}

class checkboxFriend extends StatefulWidget {
  final String? FRIENDID;

  const checkboxFriend({super.key, this.FRIENDID});

  @override
  State<checkboxFriend> createState() => _checkboxFriendState();
}

class _checkboxFriendState extends State<checkboxFriend> {
  bool flag = false;
  @override
  Widget build(BuildContext context) {
    if (filteredFriends.contains(widget.FRIENDID)) {
      flag = true;
    }
    return Checkbox(
      value: flag,
      side: BorderSide(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      checkColor: Colors.white,
      activeColor: Buttonblue,
      onChanged: ((value) {
        setState(() {
          flag = value!;
          flagFbut = true;
        });
        if (filteredFriends.contains(widget.FRIENDID)) {
          filteredFriends.remove(widget.FRIENDID!);
        } else {
          filteredFriends.add(widget.FRIENDID!);
        }
        print('--------------MY FRIEND----------------');
        print(filteredFriends);
      }),
    );
  }
}
