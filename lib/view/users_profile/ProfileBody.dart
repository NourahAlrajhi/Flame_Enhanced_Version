import 'package:flame/Constants/color.dart';
import 'package:flame/Constants/constants.dart';
import 'package:flame/Constants/theme.dart';
import 'package:flame/view/users_profile/my_flames/MyPost.dart';
import 'package:flame/view/editprofile/EditProfilePage.dart';
import 'package:flame/view/Friends/FriendsList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../controller/user_cubit.dart';
import 'saved_flames/MySavedPost.dart';

class ProfileBody1 extends StatelessWidget {
  const ProfileBody1({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height * 0.19,
          ),
          Center(
            child: OutlinedButton.icon(
              // <-- OutlinedButton
              onPressed: () {
                // showModalBottomSheet(
                //   isScrollControlled: true,
                // );
                showModalBottomSheet(
                  context: context,
                  enableDrag: false,
                  isDismissible: false,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  builder: (context) => const EditProfilePage(),
                  backgroundColor: Colors.transparent,
                );
              },

              label: Text(
                'Edit Profile',
                style: TextStyle(
                  fontFamily: font,
                  color: Buttonblue,
                  fontSize: 0.02 * height,
                ),
              ),
              icon: Icon(Icons.edit, size: 0.03 * height, color: Buttonblue),
              style: OutlinedButton.styleFrom(
                fixedSize: Size(width * 0.4, height * 0.04),
              ),
            ),
          ), //remove this when merging
          Container(
            margin: EdgeInsets.only(
                right: 20, left: 20, top: height * 0.01, bottom: height * 0.01),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        UserCubit.get(context).search = [];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => friendsRequests(
                                    IDEE: uId,
                                  )),
                        );
                      },
                      child: Container(
                        height: height * .17,
                        width: 90,
                        decoration: BoxDecoration(
                            image: const DecorationImage(
                                image:
                                    AssetImage("assets/images/smoothGreen.png"),
                                fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: width * 0.018,
                              right: width * 0.018,
                              bottom: height * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${UserCubit.get(context).myFriends.length}',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 0.03 * height,
                                        fontFamily: font),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text('My friends',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 0.02 * height,
                                          fontFamily: font)),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/la_user-friends.svg',
                                    height: height * 0.05,
                                    width: width * 0.05,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MySavedPost()),
                        );
                      },
                      child: Container(
                        height: height * .08,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                              image: AssetImage("assets/images/smoothBlue.png"),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 0.018 * width,
                              right: 0.014 * width,
                              top: 0.009 * height),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${UserCubit.get(context).UserSavedPost.length}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 0.022 * height,
                                          fontFamily: font)),
                                  Text('Saved flames',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 0.018 * height,
                                          fontFamily: font)),
                                ],
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_bookmark-check.svg',
                                    width: 0.3 * width,
                                    height: 0.03 * height,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder:
                                  (context) => /*addFriend(IDEE: uId)*/ MyPost()),
                        );
                      },
                      child: Container(
                        height: height * .08,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                              image: AssetImage("assets/images/smoothPink.png"),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 0.018 * width,
                              right: 0.008 * width,
                              top: 0.004 * height),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${UserCubit.get(context).UserPost.length}',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 0.022 * height,
                                        fontFamily: font),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text('My flames',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 0.018 * height,
                                          fontFamily: font),
                                      textAlign: TextAlign.center)
                                ],
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/codicon_flame.svg',
                                    width: 0.35 * width,
                                    height: height * 0.035,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
