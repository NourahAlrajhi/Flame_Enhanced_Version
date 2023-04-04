// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flame/Constants/theme.dart';
import 'package:flame/view/Friends/Friends_Requests.dart';
import 'package:flame/Constants/color.dart';
import 'package:flutter/material.dart';
import 'package:flame/controller/user_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../Constants/constants.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  var formatter = new DateFormat('yyyy-MM-dd');
  DateTime today = new DateTime.now();
  DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
  @override
  void initState() {
    UserCubit.get(context).getNotification(id: uId);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return BlocConsumer<UserCubit, UserState>(listener: (context, state) {
      if (state is DeletnotificationDone) {
        //   EasyLoading.showSuccess("Friend deleted successfully!");
        // Navigator.pop(context);
      }
    }, builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Notifications',
              style: TextStyle(fontFamily: font, color: Colors.black)),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          backgroundColor: const Color.fromARGB(0, 237, 76, 13),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              height: 60,
              width: width,
              decoration: BoxDecoration(border: Border.all(color: lightgrey)),
              child: InkWell(
                onTap: () {
                  UserCubit.get(context).requestFriends = [];
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DetailsRequist()));
                },
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: const Text(
                        'Friends Requests',
                        style: TextStyle(fontFamily: font, fontSize: 16),
                      ),
                    ),
                    const Spacer(),
                    Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: const Icon(Icons.arrow_forward_ios)),
                  ],
                ),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 20, bottom: 5, top: 10),
                child: const Text(
                  'Activties',
                  style: TextStyle(fontFamily: font, fontSize: 25),
                )),
            Expanded(
              child: UserCubit.get(context).Notification.isEmpty
                  ? const Center(
                      child: Text('You have no notifications yet',
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
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.white, spreadRadius: 4),
                                  ],
                                ),
                                child: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                    UserCubit.get(context).Notification[index]
                                                    ['SenderPic'] ==
                                                null ||
                                            UserCubit.get(context)
                                                        .Notification[index]
                                                    ['SenderPic'] ==
                                                'null'
                                        ? 'https://firebasestorage.googleapis.com/v0/b/flame-49dfd.appspot.com/o/images%2FdefaultProfilePic.png?alt=media&token=cb0d6f13-05c0-41c6-bb5a-d43f741b9adf'
                                        : UserCubit.get(context)
                                            .Notification[index]['SenderPic']
                                            .toString(),
                                  ),
                                )),
                            title: Text(
                              "${UserCubit.get(context).Notification[index]['Title']}",
                              style: const TextStyle(
                                  fontFamily: font, color: kTextColor),
                            ),
                            subtitle: Text(
                                "${UserCubit.get(context).Notification[index]['SubTitle']}",
                                style: const TextStyle(
                                  fontFamily: font,
                                )),
                            trailing: Text(
                                "${UserCubit.get(context).Notification[index]['PostDate'] == formatter.format(today) ? "Today" : UserCubit.get(context).Notification[index]['PostDate'] == formatter.format(yesterday) ? "Yesterday" : UserCubit.get(context).Notification[index]['PostDate']}",
                                style: const TextStyle(
                                    fontFamily: font, color: kTextColor)),
                            onTap: () {
                              //   UserCubit.get(context).getNotification(id: uId);
                            },
                          ),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                                caption: 'Delete',
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () async {
                                  print("----------------------------11");

                                  UserCubit.get(context).DELETENOTIFICATION(
                                      notificationID: UserCubit.get(context)
                                              .Notification[index]
                                          [' NotificationId']);
                                  print("----------------------------22");
                                }),
                          ],
                        );
                      },
                      separatorBuilder: (_, index) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Divider(
                              thickness: 1,
                              color: Color.fromARGB(255, 212, 210, 210)),
                        );
                      },
                      itemCount: UserCubit.get(context).Notification.length,
                    ),
            ),
          ],
        ),
      );
    });
  }
}
