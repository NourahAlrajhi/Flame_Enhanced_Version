import 'dart:io';

import 'package:flutter/material.dart';

const String google_api_key = "AIzaSyAd4rEAQqf58fCJGABqW99teDP9BcuyN08";
const Color primaryColor = Color(0xFF7B61FF);
const double defaultPadding = 16.0;
dynamic uId = "";
dynamic nameUser = "";
dynamic phoneUser = "";
dynamic dateUser = "";
dynamic STATUS = "Active";
dynamic ImageUser;
dynamic TOKEN;
File? postImage;
Set<String> filterByTag = {''};
Set<String> filteredFriends = {''};
Set<String> filterByFriend = {''};
bool flagFbut = false;
bool isLoading = true;

bool flagbut() {
  return flagFbut;
}

// Colors that we use in profile page
const kPrimaryColor = Color(0xFFF4BA40);
const kPColor = Color(0xFFEF863B);
const kTextColor = Color(0xFF3C4046);
const kBackgroundColor = Color(0xFFFEFEFF);

const double kDefaultPadding = 20.0;
String registered = "registered";
