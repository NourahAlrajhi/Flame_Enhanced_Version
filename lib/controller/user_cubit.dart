import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flame/view/posts/PostRec.dart';
//import 'package:flame/Post/Front/PostRec2.dart';
import 'package:flame/Constants/constants.dart';

import 'package:flame/Constants/constants.dart';
import 'package:flame/model/save_data.dart';
import 'package:flame/model/personal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:flame/Constants/color.dart';

import '../view/Friends/addFriend.dart';
import '../view/users_profile/Profile.dart';
import '../view/home_page.dart';
import 'package:http/http.dart' as http;
part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());
  static UserCubit get(context) => BlocProvider.of(context);
  List<Map<String, dynamic>> searcFrinds = [];
  List<Map<String, dynamic>> searcFrindsLoaded = [];
  List<Map<String, dynamic>> dameg = [];
  List<Map<String, dynamic>> allUser = [];
  String? url;

  var id2 = Uuid().v4();
  sendNotification(
      String title, String token, String UID, BuildContext context) async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate); // 2022-10-24
    FirebaseFirestore.instance.collection('Notification').doc(id2).set({
      ' NotificationId': id2,
      'UserNotification': UID,
      'Title': title,
      'SubTitle': 'wants to be your friend',
      'SenderPic': ImageUser,
      'SenderID': uId,
      'PostDate': formattedDate
    });

    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'message': title,
    };

    try {
      http.Response response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization':
                    'key=AAAA0pGz0Y4:APA91bEN-WcpGkFz0YASrfQ4-zOB6I6zX24ROmsanxmFFwK-Fs-8fbEIz4XH72xrXh20YTSt4amWoNEbWbp7fUVxQzTWEfjZ3Eg_pHNFioamF0PtVWr58ryUrLDCAw0s9plzf5QNo8UN'
              },
              body: jsonEncode(<String, dynamic>{
                'notification': <String, dynamic>{
                  'title': '$title wants to be your friend',
                  'body': 'wants to be your friend'
                },
                'priority': 'high',
                'data': data,
                'to': '$token' //to which user you want to send the notification
              }));

      if (response.statusCode == 200) {
        print("Yeh notificatin is sended");
      } else {
        print("Error");
      }
    } catch (e) {}
  }

  void getAllUser() {
    emit(GetUserLoaded());
    allUser = [];

    FirebaseFirestore.instance.collection("Users").get().then((value) {
      value.docs.forEach((element) {
        if (element.data()['id'] != uId) allUser.add(element.data());
        emit(GetDataUserDone());
      });
      emit(GetDataUserDone());
    });
  }

  void getFrinds() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(uId)
        .collection("Friends")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        for (int i = 0; i < allUser.length; i++) {
          if (element.data()['idFriend'] == allUser[i]['id']) {
            allUser.remove(allUser[i]);
          }
        }
        emit(GetAllFrinds());
      });
    });
  }

  void getRequestedMM() {
    FirebaseFirestore.instance.collection("Request").get().then((value) {
      value.docs.forEach((element) {
        for (int i = 0; i < allUser.length; i++) {
          if (element.data()['status'] == "loaded") {
            if (element.data()['idReseve'] == allUser[i]['id']) {
              allUser.remove(allUser[i]);
            }
          }
        }
        emit(GetAllFrindsRequest());
      });
    });
  }

  void searchFrinds({
    required dynamic phone,
  }) {
    searcFrinds = [];

    emit(SearchLoaded());
    searcFrinds = [];
    var x = phone.toString().replaceFirst("0", "+966");

    searcFrinds = allUser
        .where(
            (element) => element['phone'].toString().toLowerCase().contains(x))
        .toList();
    print(searcFrinds);
    emit(DoneSearch());
  }

  String idFreindes = '';
  String dateFreindes = '';
  List<String> requestedLoaded = [];
  void sendRequest({
    required String name,
    required String phone,
    required BuildContext context,
    required String SenderPhoto,
  }) {
    var id = Uuid().v4();
    emit(CheckUserLoaded());
    FirebaseFirestore.instance
        .collection("Users")
        .where('phone', isEqualTo: '$phone')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        if (value.docs[0].data()['phone'] == null ||
            value.docs[0].data()['phone'] == "null") {
          emit(CheckUserError(phone: phone.toString().replaceAll(" ", "")));

          print("faild");
        } else {
          // sendNotification("Someone follows you!", element.data()['token']);
          print("Done");
          FirebaseFirestore.instance.collection("Request").doc(id).set({
            'idRequest': id,
            'idSender': uId,
            'status': "loaded",
            'nameSender': nameUser,
            'phoneSender': phoneUser,
            'phoneReseve': phone.toString().replaceAll(" ", ""),
            'idReseve': value.docs[0].data()['id'],
            'nameReseve': name,
            'dateResever': value.docs[0].data()['birthDate'],
            'dateSender': dateUser,
            'FriendsImage': SenderPhoto
          }).then((value) {
            emit(GetIdFrindes());
            updatePerson(
                phone: phone.toString().replaceAll(" ", ""),
                x: 0,
                phoneF: phoneUser);
            emit(AddPhoneNumberListDone());
          }).catchError((onError) {
            emit(CheckUserError(phone: phone.toString().replaceAll(" ", "")));
          });
        }
        sendNotification('$nameUser', value.docs[0].data()['token'],
            value.docs[0].data()['id'], context);
        getNotification(id: uId);
      } else {
        emit(CheckUserError(phone: phone.toString().replaceAll(" ", "")));
      }
    }).catchError((onError) {
      emit(CheckUserError(phone: phone.toString().replaceAll(" ", "")));
    });
  }

  void xx(context, idFrinds) {}
  List<Map<String, dynamic>> requestFriends = [];
  void getRequest({required String id}) {
    emit(GetRequestLoaded());
    requestFriends = [];
    FirebaseFirestore.instance
        .collection("Request")
        .where('idReseve', isEqualTo: uId)
        .where('status', isEqualTo: 'loaded')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        requestFriends.add(element.data());
      });
      emit(GetRequestDone());
    });
  }

  List<Map<String, dynamic>> Notification = [];
  void getNotification({required String id}) {
    emit(GetNotificationLoaded());
    Notification = [];
    FirebaseFirestore.instance
        .collection("Notification")
        .orderBy('PostDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (element.data()['UserNotification'] == uId) {
          Notification.add(element.data());
        }
      }
      emit(GetNotificationtDone());
    });
  }

  List<Map<String, dynamic>> UserFriend = [];
  void getUserFriend({required String id}) {
    emit(GetUserFriend());
    UserFriend = [];
    FirebaseFirestore.instance
        .collection("Users")
        .doc(id)
        .collection("Friends")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        UserFriend.add(element.data());
      });
      emit(GetUserFriendtDone());
    });
  }

  List<Map<String, dynamic>> UserFriend2 = [];
  void getUserFriend2({required String id}) {
    emit(GetUserFriend2());
    UserFriend2 = [];
    FirebaseFirestore.instance
        .collection("Users")
        .doc(id)
        .collection("Friends")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        UserFriend2.add(element.data());
      });
      emit(GetUserFriendtDone2());
    });
  }

  void friendsToken({required String idFriend}) {
    var id = Uuid().v4();
    var idDocument = Uuid().v4();

    FirebaseFirestore.instance.collection('Users').doc(uId).get().then((value) {
      String? userToken = value.data()!['token'];
      print('TOKEEEEEEEEEEEEEEN');
      print(userToken);
      FirebaseFirestore.instance
          .collection('Users')
          .doc(idFriend)
          .collection('FriendsTokens')
          .doc(id)
          .set({'token': userToken, 'idDoc': id, 'senderId': uId});
    });
  }

  void deleteTokens({required String idFriend}) {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(idFriend)
        .collection('FriendsTokens')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.data()['senderId'] == uId) {
          FirebaseFirestore.instance
              .collection('Users')
              .doc(idFriend)
              .collection('FriendsTokens')
              .doc(element.data()['idDoc'])
              .delete();
        }
      });
    });
  }

  String? nameUser;

  void getDataUser({required String id}) {
    emit(GetDataMyUserLoaded());
    FirebaseFirestore.instance.collection("Users").doc(id).get().then((value) {
      nameUser = value.data()!['fullName'];
      dateUser = value.data()!['birthDate'];
      phoneUser = value.data()!['phone'];
      uId = value.data()!['id'];
      ImageUser = value.data()!['userImage'];
      print("+++++++++++++++++++++++++++++++++++=");
      print("the id is : $uId");
      print("the name is : $nameUser");
      print("the phone is : $phoneUser");
      print("the date is : $dateUser");
      print("+++++++++++++++++++++++++++++++++++=");

      emit(GetDataMyUserDone());
    });
  }

  List<Map<String, dynamic>> frindesLoaded = [];

  void getAllRequist() {
    emit(GetAllRequestLoaded());
    frindesLoaded = [];
    FirebaseFirestore.instance.collection("Request").get().then((value) {
      value.docs.forEach((element) {
        if (element.data()['status'] == "loaded" &&
            element.data()['idSender'] != uId)
          frindesLoaded.add(element.data());
        emit(GetAllRequestDone());
      });
      print("requested my is : $frindesLoaded");
      emit(GetAllRequestDone());
    });
  }

/*  List<Map<String, dynamic>> requested = [];
  void getAllRequistTalap() {
    emit(GetAllRequestLoaded());
    requested = [];
    FirebaseFirestore.instance
        .collection("Users")
        .doc(uId)
        .collection("Request")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.data()['status'] == "loaded") requested.add(element.data());
      });
      emit(GetAllRequesTalaptDone());
    });
  }*/

  void updateCancelRequest(
      {required String idFrinds,
      required String idPost,
      required String phoneFriend}) {
    emit(UpdateRequestCancleLoaded());

    FirebaseFirestore.instance
        .collection("Request")
        .doc(idPost)
        .update({'status': "cancel"}).then((value) {
      getRequest(id: uId);
      updatePerson(
          phone: phoneFriend.toString().replaceAll(" ", ""),
          x: 2,
          phoneF: phoneUser);

      emit(UpdateRequestCancle());
    });
  }

  void updateAcceptRequest(
      {required String idFrinds,
      required String idPost,
      required String nameFriend,
      required String phoneFriend,
      required String dateFriend,
      required dynamic FriendsImage,
      required String SenderPic}) {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate); // 2022-10-24
    var id = Uuid().v4();
    print(dateFriend);
    print(idFrinds);
    print(idPost);
    print(nameFriend);
    print(phoneFriend);
    print(dateFriend);
    emit(UpdateRequestCancleLoaded());

    FirebaseFirestore.instance
        .collection("Request")
        .doc(idPost)
        .update({'status': "accept"}).then((value) {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(uId) //also the other friend
          .collection("Friends")
          .doc(id)
          .set({
        'ID': id,
        'idFriend': idFrinds,
        'nameFriend': nameFriend,
        'phoneFriend': phoneFriend,
        'dateFriend': dateFriend,
        'FriendsImage': FriendsImage
      });
      FirebaseFirestore.instance
          .collection("Users")
          .doc(idFrinds) //also the other friend
          .collection("Friends")
          .doc(id)
          .set({
        'ID': id,
        'idFriend': uId,
        'nameFriend': nameUser,
        'phoneFriend': phoneUser,
        'dateFriend': dateUser,
        'FriendsImage': SenderPic,
      }).then((value) {
        emit(UpdateRR());
        updatePerson(
            phone: phoneFriend.toString().replaceAll(" ", ""),
            x: 1,
            phoneF: phoneUser);
        getFrinds();
        getAllFriends(ID: uId);
        getAllFriends2(ID: uId);
        getUserFriend(id: uId);
        getMyPost(ID: uId);
        FirebaseFirestore.instance
            .collection("Users")
            .doc(uId)
            .collection("MyPost")
            .get()
            .then((value) {
          value.docs.forEach((element) {
            FirebaseFirestore.instance
                .collection("Users")
                .doc(idFrinds)
                .collection("FriendsPost")
                .doc(element.data()['PostID'])
                .set({
              "Uid": element.data()['Uid'],
              "category": element.data()['category'],
              "photo": element.data()['photo'],
              "placeName": element.data()['placeName'],
              "place": element.data()['place'],
              //place
              "review": element.data()['review'],
              "tag": element.data()['tag'],
              "UserPic": element.data()['UserPic'],
              'PostID': element.data()['PostID'],
              'phone': element.data()['phone'],
              'PostDate': element.data()['PostDate']
            });
          });
        });

        FirebaseFirestore.instance
            .collection("Users")
            .doc(idFrinds)
            .collection("MyPost")
            .get()
            .then((value2) {
          value2.docs.forEach((element2) {
            FirebaseFirestore.instance
                .collection("Users")
                .doc(uId)
                .collection("FriendsPost")
                .doc(element2.data()['PostID'])
                .set({
              "Uid": element2.data()['Uid'],
              "category": element2.data()['category'],
              "photo": element2.data()['photo'],
              "placeName": element2.data()['placeName'],
              "place": element2.data()['place'],
              //place
              "review": element2.data()['review'],
              "tag": element2.data()['tag'],
              "UserPic": element2.data()['UserPic'],
              'PostID': element2.data()['PostID'],
              'phone': element2.data()['phone'],
              'PostDate': element2.data()['PostDate']
            });
          });
        }); //also the other friend
      });
    });
  }

  List<Widget> screen = [const HomePage(), PostRec(), const Profile_()];
  var currentIndex = 0;
  void changeBottomNav(index, ID) {
    if (currentIndex == 1) {
      // uId =await    SaveData.getData(key: 'idUser');
      print(uId);
      getAllFriends(ID: ID);
      getMyPost(ID: ID);
      getAllFriends2(ID: ID);
      getMyPost2(ID: ID);
    }
    currentIndex = index;
    emit(ChangeCurrentIndex());
  }

  List<Map<String, dynamic>> request = [];
  void getAllRequestMy() {
    request = [];
    FirebaseFirestore.instance.collection("Request").get().then((value) {
      value.docs.forEach((element) {
        if (element.data()['status'] == "loaded") {
          request.add(element.data());
        }
      });

      emit(GetAllRequestedDone());
      print(
          "+**********************************************************************************************+==");
      print(dameg);
    });
  }

  List<Personal> person = [];
  List<Personal> search = [];
  void getSearchContacs(
      List<Contact> contacts, String phone, BuildContext context) {
    UserCubit.get(context).getAllLoaded();
    person = [];
    search = [];
    person.clear();
    var x = phone.toString().replaceFirst("0", "+966");

    for (int i = 0; i < contacts.length; i++) {
      if (contacts[i].phones.isNotEmpty) {
        Personal p = Personal(
          fName: contacts[i].name.first,
          lName: contacts[i].name.last,
          phone: contacts[i].phones[0].number.toString().replaceAll(" ", ""),
          status: "normal",
        );
        person.add(p);
      }
      emit(AddContacts());
    }

    search = person
        .where((element) => element.fName
            .toString()
            .toLowerCase()
            .replaceAll(" ", "")
            .contains(x))
        .toList();
    emit(SearchConcats());

    // print(search[0].phone);
  }

  List<Map<String, dynamic>> loadedF = [];

  void updatePerson(
      {required String phone, required int x, required String phoneF}) {
    loadedF = [];
    for (int i = 0; i < person.length; i++) {
      if (person[i].phone.toString().replaceAll(" ", "") ==
              phone.toString().replaceAll(" ", "") &&
          person[i].status == "normal") {
        person[i].status = "loaded";
        emit(UpdateStatusDone());
        getAllLoaded();

        break;
      } else if (person[i].phone.toString().replaceAll(" ", "") ==
              phone.toString().replaceAll(" ", "") &&
          person[i].status == "loaded") {
        switch (x) {
          case 1:
            person[i].status = "accept";
            emit(UpdateStatusDone());
            getAllLoaded();
            break;
          case 2:
            person[i].status = "normal";
            emit(UpdateStatusDone());
            getAllLoaded();
            break;
          default:
            person[i].status = "loaded";
            emit(UpdateStatusDone());
            getAllLoaded();
            break;
        }

        break;
      }
    }
  }

  void updatePersonDone({required String phone}) {
    for (int i = 0; i < person.length; i++) {
      if (person[i].phone.toString().replaceAll(" ", "") ==
          phone.toString().replaceAll(" ", "")) {
        person[i].status = "accept";
        emit(UpdateStatusDoneAccept());

        getAllDone();

        break;
      }
    }
  }

  void getAllLoaded() {
    print("Loaded");
    FirebaseFirestore.instance.collection("Request").get().then((value) {
      value.docs.forEach((element) {
        for (int i = 0; i < person.length; i++) {
          if (element.data()['status'] == "loaded") {
            for (int i = 0; i < person.length; i++) {
              /* if (person[i].phone.toString().replaceAll(" ", "") ==
                    element.data()['phoneReseve']||person[i].phone.toString().replaceAll(" ", "") ==
                    element.data()['phoneSender']) {*/
              if (element.data()['phoneReseve'] ==
                      person[i].phone.replaceAll(" ", "") ||
                  element.data()['phoneSender'] ==
                      person[i].phone.replaceAll(" ", "")) {
                if (element.data()['idReseve'] == uId ||
                    element.data()['idSender'] == uId)
                  person[i].status = "loaded";
                emit(UpdateStatusDoneLoaded());
              }
            }
          } else if (element.data()['status'] == "accept") {
            for (int i = 0; i < person.length; i++) {
              if (element.data()['phoneReseve'] ==
                      person[i].phone.replaceAll(" ", "") ||
                  element.data()['phoneSender'] ==
                      person[i].phone.replaceAll(" ", "")) {
                if (element.data()['idReseve'] == uId ||
                    element.data()['idSender'] == uId)
                  person[i].status = "accept";
                emit(UpdateStatusDoneLoaded());
              }
            }
          } else {
            for (int i = 0; i < person.length; i++) {
              if (person[i].phone.toString().replaceAll(" ", "") ==
                      element.data()['phoneReseve'] ||
                  person[i].phone.toString().replaceAll(" ", "") ==
                      element.data()['phoneSender']) {
                person[i].status = "normal";
                emit(UpdateStatusDoneLoaded());
              }
            }
          }
        }
      });
    });
  }

  void getAllDone() {
    print("get all done");
    FirebaseFirestore.instance.collection("Request").get().then((value) {
      value.docs.forEach((element) {
        if (element.data()['idSender'] == uId) {
          if (element.data()['status'] == "accept") {
            for (int j = 0; j < person.length; j++) {
              if (person[j].phone.toString().replaceAll(" ", "") ==
                  element.data()['phoneReseve']) {
                person[j].status = "accept";
                emit(UpdateStatusDoneDone());
                break;
              }
            }
          }
        }
      });
      print(person);
    });
  }

  List<Map<String, dynamic>> myFriends = [];
  void getAllFriends({required String ID}) {
    emit(GetAllFriendsLoaded());

    myFriends = [];
    FirebaseFirestore.instance
        .collection("Users")
        .doc(ID)
        .collection("Friends")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        myFriends.add(element.data());
        emit(GetAllFriendsDone());
      });
      emit(GetAllFriendsDone());
    });
  }

  List<Map<String, dynamic>> myPost = [];
  void getMyPost({required String ID}) {
    emit(GetAllPostLoaded());
    print("myPost = []; {value.docs.length}");
    myPost = [];
    FirebaseFirestore.instance.collection("Post").get().then((value) {
      value.docs.forEach((element) {
        if (element.data()['Uid'] == ID) {
          myPost.add(element.data());
        }
      });
      emit(GetAllPostDone());
    });
  }

  List<Map<String, dynamic>> myFriends2 = [];
  void getAllFriends2({required String ID}) {
    emit(GetAllFriendsLoaded2());

    myFriends2 = [];
    FirebaseFirestore.instance
        .collection("Users")
        .doc(ID)
        .collection("Friends")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        myFriends2.add(element.data());
        emit(GetAllFriendsDone());
      });
      emit(GetAllFriendsDone2());
    });
  }

  List<Map<String, dynamic>> myPost2 = [];
  void getMyPost2({required String ID}) {
    emit(GetAllPostLoaded2());
    print("myPost = []; {value.docs.length}");
    myPost2 = [];
    FirebaseFirestore.instance.collection("Post").get().then((value) {
      value.docs.forEach((element) {
        if (element.data()['Uid'] == ID) {
          myPost2.add(element.data());
        }
      });
      emit(GetAllPostDone2());
    });
  }

  List<Map<String, dynamic>> categories = [];
  void SubCategories({required String subtag}) {
    emit(GetAllcategoriesLoaded2());

    categories = [];
    FirebaseFirestore.instance
        .collection("Category")
        .doc(subtag)
        .get()
        .then((value) {
      categories.add(value.data()!);
      // categories.add(element.data()['CATEGORY']);

      emit(GetAllcategoriesDone2());
      print("the category is ++++++++++++++++++++ ${categories}");
    });
  }

  /*void UpdateFriendsPic() {
    FirebaseFirestore.instance.collection("Users").get().then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(element.data()['id'])
            .collection("Friends")
            .get()
            .then((value2) {
          value.docs.forEach((element2) {
            if (element2.data()['idFriend'] == uId) {
////حطي كود ابديت الي سويتيه هنا بس انتبهي لاسم الفيلد حق الصوره بكولكشن فريند

            }
          });
        });
      });
    });

    FirebaseFirestore.instance.collection("Notification").get().then((value) {
      value.docs.forEach((element3) {
        if (element3.data()['UserNotification'] == uId) {
////حطي كود ابديت الي سويتيه هنا بس انتبهي لاسم الفيلد حق الصوره بكولكشن نوتفكيشين

        }
      });
    });
  }*/

  void deleteFriends({required String idFriend}) {
    emit(deleteFrindLoaded());
    FirebaseFirestore.instance
        .collection("Users")
        .doc(uId)
        .collection("Friends")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.data()['idFriend'] == idFriend) {
          FirebaseFirestore.instance
              .collection("Users")
              .doc(uId)
              .collection("Friends")
              .doc(element.data()['ID'])
              .delete()
              .then((value) {
            FirebaseFirestore.instance
                .collection("Users")
                .doc(idFriend)
                .collection("Friends")
                .get()
                .then((value2) {
              value2.docs.forEach((element2) {
                if (element2.data()['idFriend'] == uId) {
                  FirebaseFirestore.instance
                      .collection("Users")
                      .doc(idFriend)
                      .collection("Friends")
                      .doc(element2.data()['ID'])
                      .delete()
                      .then((value) {
                    emit(deleteFrindDone());
                    getFrinds();
                    getAllFriends(ID: uId);
                    getAllFriends2(ID: uId);
                    getUserFriend(id: uId);

                    getMyPost(ID: uId);

                    FirebaseFirestore.instance
                        .collection("Request")
                        .get()
                        .then((value3) {
                      value3.docs.forEach((element3) {
                        if (element3.data()['idSender'] == uId &&
                                element3.data()['idReseve'] == idFriend ||
                            element3.data()['idSender'] == idFriend &&
                                element3.data()['idReseve'] == uId) {
                          FirebaseFirestore.instance
                              .collection("Request")
                              .doc(element3.data()['idRequest'])
                              .delete()
                              .then((value4) {
                            updatePerson(
                              x: 2,
                              phone: element3.data()['phoneReseve'],
                              phoneF: "null",
                            );
                          });
                        }
                      });
                    });

//////delet postsssssss
                    FirebaseFirestore.instance
                        .collection("Users")
                        .doc(uId)
                        .get()
                        .then((value4) {
                      print("enter DeleteFriendwithMyFriendPostStart 1");
                      FirebaseFirestore.instance
                          .collection("Users")
                          .doc(uId)
                          .collection("FriendsPost")
                          .get()
                          .then((value5) {
                        value5.docs.forEach((element5) {
                          if (element5.data()['Uid'] == idFriend) {
                            print("enter DeleteFriendwithMyFriendPostStart 2");

                            FirebaseFirestore.instance
                                .collection('Users')
                                .doc(uId)
                                .collection('FriendsPost')
                                .doc(element5.data()['PostID'])
                                .delete()
                                .then((value6) {
                              FirebaseFirestore.instance
                                  .collection("Users")
                                  .doc(idFriend)
                                  .collection("FriendsPost")
                                  .get()
                                  .then((value7) {
                                value7.docs.forEach((element6) {
                                  if (element6.data()['Uid'] == uId) {
                                    print(
                                        "enter DeleteFriendwithMyFriendPostStart 3");

                                    FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(idFriend)
                                        .collection('FriendsPost')
                                        .doc(element6.data()['PostID'])
                                        .delete();
                                    // .then((value8) {
//delete saved post
                                    FirebaseFirestore.instance
                                        .collection("Users")
                                        .doc(uId)
                                        .collection("MySavedPost")
                                        .get()
                                        .then((value9) {
                                      value9.docs.forEach((element7) {
                                        if (element7.data()['Uid'] ==
                                            idFriend) {
                                          print(
                                              "enter DeleteFriendwithMySavedPostStart 1");
                                          FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(uId)
                                              .collection('MySavedPost')
                                              .doc(element7.data()['PostID'])
                                              .delete()
                                              .then((value10) {
                                            getUserSavedPost(USERID: uId);
                                          });
                                        }
                                        FirebaseFirestore.instance
                                            .collection("Users")
                                            .doc(idFriend)
                                            .collection("MySavedPost")
                                            .get()
                                            .then((value11) {
                                          value11.docs.forEach((element8) {
                                            if (element8.data()['Uid'] == uId) {
                                              print(
                                                  "enter DeleteFriendwithMySavedPostStart 2");

                                              FirebaseFirestore.instance
                                                  .collection('Users')
                                                  .doc(idFriend)
                                                  .collection('MySavedPost')
                                                  .doc(
                                                      element8.data()['PostID'])
                                                  .delete()
                                                  .then((value12) =>
                                                      getUserSavedPost(
                                                          USERID: idFriend));
                                            }
                                            ;
                                          });
                                        });
                                        print(
                                            "enter updateMyFriendPostStart 5");
                                      });
                                    });
                                    //});
                                    emit(updateMyFriendPostEnd());
                                  }
                                });
                              });
                            });
                          }
                          ;
                        });
                      });
                    });
                  });
                }
                ;
              });
            });
          });
        }
      });
    });
  }

  void deleteTag({required String Category}) {
    emit(deleteFrindLoaded());
    FirebaseFirestore.instance
        .collection("Category")
        .doc(Category)
        .get()
        .then((value) {
      if (value.data()!['name'] == Category) {
        FirebaseFirestore.instance
            .collection("Category")
            .doc(Category)
            .delete()
            .then((value2) {
          //we want to disappear directly from the user side and admin side
        });
      }
    });
  }

//************** copy this */
  void updateProfileImage(String img) async {
    emit(profilePicUpdate());
    // String fileName = basename(img.path);
    // FirebaseStorage firebaseStorageRef = FirebaseStorage.instance;
    // Reference ref = firebaseStorageRef.ref().child('images/$fileName');
    // UploadTask uploadTask = ref.putFile(img);
    // final TaskSnapshot downloadUrl = (await uploadTask);
    // url = await downloadUrl.ref.getDownloadURL();

    FirebaseFirestore.instance
        .collection('Users')
        .doc(uId)
        .update({'userImage': img}).then((value) {
      updateNotifictaionsPic(uid: uId, URL: img);
      updatePicFriends(uid: uId, URL: img);
      updatePicPost(uid: uId, URL: img);
      updateSavedPostPic(uid: uId, URL: img);
      updateMyPostPic(uid: uId, URL: img);
      updateMyFriendPostPic(uid: uId, URL: img);
      getDataUser(id: uId);
      emit(profilePicUpdateDone());
    });
  }

  Future<void> updatePicPost(
      {required dynamic uid, required dynamic URL}) async {
    emit(updatePostStart());
    print("enter updatePostpic 1");
    QuerySnapshot qr =
        await FirebaseFirestore.instance.collection("Post").get();
    for (int i = 0; i < qr.docs.length; i++) {
      if (qr.docs[i].get("Uid") == uid) {
        print("enter updatePostpic 2 ${URL}");
        FirebaseFirestore.instance
            .collection("Post")
            .doc(qr.docs[i].id)
            .update({'UserPic': URL});
      }
    }
    emit(updatePostEnd());
    /* FirebaseFirestore.instance.collection("Post").get().then((value) {
      print("enter updatePostpic 1");
      value.docs.forEach((element3) {
        if (element3.data()['Uid'] == uid) {
          print("enter updatePostpic 2");

          FirebaseFirestore.instance
              .collection("Post")
              .doc(element3.data()['PostID'])
              .update({'UserPic': URL});
          print("enter updatePostpic 3");
        }
      });
      emit(updatePostEnd());
    });*/
  }

  Future<void> updatePicRecuest(
      {required String name, required dynamic uid}) async {
    emit(updateRecStart());
    print("enter updatePicRecuest 1");
    QuerySnapshot qr =
        await FirebaseFirestore.instance.collection("Request").get();
    for (int i = 0; i < qr.docs.length; i++) {
      if (qr.docs[i].get("idSender") == uid &&
          qr.docs[i].get("status") == 'loaded') {
        print("enter updatePicRecuest 2 ${name}");
        FirebaseFirestore.instance
            .collection("Request")
            .doc(qr.docs[i].id)
            .update({'nameSender': name});
      }
    }
    emit(updateRecEnd());
    /* FirebaseFirestore.instance.collection("Post").get().then((value) {
      print("enter updatePostpic 1");
      value.docs.forEach((element3) {
        if (element3.data()['Uid'] == uid) {
          print("enter updatePostpic 2");

          FirebaseFirestore.instance
              .collection("Post")
              .doc(element3.data()['PostID'])
              .update({'UserPic': URL});
          print("enter updatePostpic 3");
        }
      });
      emit(updatePostEnd());
    });*/
  }

  Future<void> updateNotifictaionsPic(
      {required dynamic uid, required dynamic URL}) async {
    emit(updateNotifictaionsStart());
    print("enter updatenotificationpic 1");
    QuerySnapshot qr =
        await FirebaseFirestore.instance.collection("Notification").get();
    for (int i = 0; i < qr.docs.length; i++) {
      if (qr.docs[i].get("SenderID") == uid) {
        print("enter updatePostpic 2 ${URL}");
        FirebaseFirestore.instance
            .collection("Notification")
            .doc(qr.docs[i].id)
            .update({'SenderPic': URL});
      }
    }
    emit(updateNotifictaionsEnd());
    /*/FirebaseFirestore.instance.collection("Notification").get().then((value) {
      print("enter updatenotificationpic 1");
      value.docs.forEach((element3) {
        if (element3.data()['SenderID'] == uid) {
          print("enter updatenotificationpic 2");

          FirebaseFirestore.instance
              .collection("Notification")
              .doc(element3.data()['NotificationId'])
              .update({'SenderPic': URL});
          print("enter updatenotificationpic 3");
        }
      });
      emit(updateNotifictaionsEnd());
    });*/
  }

  Future<void> updateSavedPostPic(
      {required dynamic uid, required dynamic URL}) async {
    emit(updateSavedPostStart());
    print("enter updateSavedPostStart 1");
    FirebaseFirestore.instance.collection("Users").get().then((value) {
      print("enter updateSavedPostStart 2");

      value.docs.forEach((element) {
        print("enter updateSavedPostStart 3");
        FirebaseFirestore.instance
            .collection("Users")
            .doc(element.data()['id'])
            .collection("MySavedPost")
            .get()
            .then((value2) {
          value2.docs.forEach((element2) {
            if (element2.data()['Uid'] == uid) {
              print("enter updateSavedPostStart 4");

              FirebaseFirestore.instance
                  .collection('Users')
                  .doc(element.data()['id'])
                  .collection('MySavedPost')
                  .doc(element2.data()['PostID'])
                  .update({'UserPic': URL});
              print("enter updateSavedPostStart 5");
            }
          });
        });
      });
      emit(updateSavedPostEnd());
    });
    /* QuerySnapshot qr = await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .collection("MySavedPost")
        .get();
    for (int i = 0; i < qr.docs.length; i++) {
      if (qr.docs[i].get("Uid") == uid) {
        print("enter updateSavedPostStart 2 ${URL}");
        FirebaseFirestore.instance
            .collection("Users")
            .doc(uid)
            .collection("MySavedPost")
            .doc(qr.docs[i].id)
            .update({'UserPic': URL});
      }
    }
    emit(updateSavedPostEnd());*/
    /*/FirebaseFirestore.instance.collection("Notification").get().then((value) {
      print("enter updatenotificationpic 1");
      value.docs.forEach((element3) {
        if (element3.data()['SenderID'] == uid) {
          print("enter updatenotificationpic 2");

          FirebaseFirestore.instance
              .collection("Notification")
              .doc(element3.data()['NotificationId'])
              .update({'SenderPic': URL});
          print("enter updatenotificationpic 3");
        }
      });
      emit(updateNotifictaionsEnd());
    });*/
  }

  Future<void> updateMyFriendPostPic(
      {required dynamic uid, required dynamic URL}) async {
    emit(updateMyFriendPostStart());
    print("enter updateMyFriendPostStart 1");
    FirebaseFirestore.instance.collection("Users").get().then((value) {
      print("enter updateMyFriendPostStart 2");

      value.docs.forEach((element) {
        print("enter updateMyFriendPostStart 3");
        FirebaseFirestore.instance
            .collection("Users")
            .doc(element.data()['id'])
            .collection("FriendsPost")
            .get()
            .then((value2) {
          value2.docs.forEach((element2) {
            if (element2.data()['Uid'] == uid) {
              print("enter updateMyFriendPostStart 4");

              FirebaseFirestore.instance
                  .collection('Users')
                  .doc(element.data()['id'])
                  .collection('FriendsPost')
                  .doc(element2.data()['PostID'])
                  .update({'UserPic': URL});
              print("enter updateMyFriendPostStart 5");
            }
          });
        });
      });
      emit(updateMyFriendPostEnd());
    });
  }

  Future<void> updateMyPostPic(
      {required dynamic uid, required dynamic URL}) async {
    emit(updateMyPostStart());
    print("enter updateMyPostStart 1");
    QuerySnapshot qr = await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .collection("MyPost")
        .get();
    for (int i = 0; i < qr.docs.length; i++) {
      if (qr.docs[i].get("Uid") == uid) {
        print("enter updateMyPostStart 2 ${URL}");
        FirebaseFirestore.instance
            .collection("Users")
            .doc(uid)
            .collection("MyPost")
            .doc(qr.docs[i].id)
            .update({'UserPic': URL});
      }
    }
    emit(updateMyPostEnd());
    /*/FirebaseFirestore.instance.collection("Notification").get().then((value) {
      print("enter updatenotificationpic 1");
      value.docs.forEach((element3) {
        if (element3.data()['SenderID'] == uid) {
          print("enter updatenotificationpic 2");

          FirebaseFirestore.instance
              .collection("Notification")
              .doc(element3.data()['NotificationId'])
              .update({'SenderPic': URL});
          print("enter updatenotificationpic 3");
        }
      });
      emit(updateNotifictaionsEnd());
    });*/
  }

  void updatePicFriends({required dynamic uid, required dynamic URL}) {
    emit(updatePicFriendsStart());

    FirebaseFirestore.instance.collection("Users").get().then((value) {
      print("enter updatefriend 1");

      value.docs.forEach((element) {
        print("enter updatefriend 2");
        FirebaseFirestore.instance
            .collection("Users")
            .doc(element.data()['id'])
            .collection("Friends")
            .get()
            .then((value2) {
          value2.docs.forEach((element2) {
            if (element2.data()['idFriend'] == uid) {
              print("enter updatefriend 3");

              FirebaseFirestore.instance
                  .collection('Users')
                  .doc(element.data()['id'])
                  .collection('Friends')
                  .doc(element2.data()['ID'])
                  .update({'FriendsImage': URL});
              print("enter updatefriend 4");
            }
          });
        });
      });
      emit(updatePicFriendsEnd());
    });
  }

  void updateDisplayName(String name) async {
    print("enter updateDisplayName 1");

    emit(DiaplayNameUpdate());

    if (name.isNotEmpty) {
      print("enter updateDisplayName 2");

      FirebaseFirestore.instance
          .collection('Users')
          .doc(uId)
          .update({'fullName': name}).then((value) {
        getDataUser(id: uId);
        updateNotifictaionsUserName(uid: uId, name: name);
        updateNameFriends(uid: uId, name: name);
        updatePicRecuest(uid: uId, name: name);
        emit(DiaplayNameDone());

        print("enter updateDisplayName 3");
      });
    }
  }

  Future<void> updateNotifictaionsUserName(
      {required String name, required dynamic uid}) async {
    emit(updateNotifictaionsNameStart());

    print("enter updatenotificationname 1");
    QuerySnapshot qr =
        await FirebaseFirestore.instance.collection("Notification").get();
    for (int i = 0; i < qr.docs.length; i++) {
      if (qr.docs[i].get("SenderID") == uid) {
        print("enter updatePostpic 2 ${name}");
        FirebaseFirestore.instance
            .collection("Notification")
            .doc(qr.docs[i].id)
            .update({
          'SubTitle': '$name wants to be your friend',
          'Title': '$name'
        });
        print("enter updatenotificationname 2");
      }
    }
    emit(updateNotifictaionsNameEnd());
    /* FirebaseFirestore.instance.collection("Notification").get().then((value) {
      print("enter updatenotificationname 1");
      value.docs.forEach((element3) {
        if (element3.data()['SenderID'] == uid) {
          print("enter updatenotificationname 2");

          FirebaseFirestore.instance
              .collection("Notification")
              .doc(element3.data()['NotificationId'])
              .update({'SubTitle': '$name wants to be your friend'});
          print("enter updatenotificationname 3");
        }
      });
      emit(updateNotifictaionsNameEnd());
    });*/
  }

  void updateNameFriends({required String name, required dynamic uid}) {
    emit(updateNameFriendsStart());

    FirebaseFirestore.instance.collection("Users").get().then((value) {
      print("enter updateNamefriend 1");

      value.docs.forEach((element) {
        print("enter updateNamefriend 2");
        FirebaseFirestore.instance
            .collection("Users")
            .doc(element.data()['id'])
            .collection("Friends")
            .get()
            .then((value2) {
          value2.docs.forEach((element2) {
            if (element2.data()['idFriend'] == uid) {
              print("enter updateNamefriend 2");

              FirebaseFirestore.instance
                  .collection('Users')
                  .doc(element.data()['id'])
                  .collection('Friends')
                  .doc(element2.data()['ID'])
                  .update({'nameFriend': name});
              print("enter updateNamefriend 3");
            }
          });
        });
      });
      emit(updateNameFriendsEnd());
    });
  }

  List<Map<String, dynamic>> UserPost = [];
  void getUserPost({required String USERID}) {
    emit(ViewUserPost());
    UserPost = [];

    FirebaseFirestore.instance
        .collection("Users")
        .doc(USERID)
        .collection("MyPost")
        .orderBy('PostDate', descending: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        UserPost.add(element.data());
        emit(ViewUserPostDone());
      });
      emit(ViewUserPostDone2());
      // print("the category is ++++++++++++++++++++ ${UserPost}");
    });
  }

  void deletUserPost({required String UserPost, required String USERID}) {
    emit(DELETPOSTLOADED());
    FirebaseFirestore.instance
        .collection("Users")
        .doc(USERID)
        .collection("MyPost")
        .doc(UserPost)
        .delete()
        .then((value) {
      emit(deletePostDone());
      getUserPost(USERID: uId);
      getUserSavedPost(USERID: uId);
      FirebaseFirestore.instance
          .collection("Post")
          .doc(UserPost)
          .delete()
          .then((value8) {
        FirebaseFirestore.instance.collection("Users").get().then((value2) {
          print("enter DeleteSavedPostStart 1");

          value2.docs.forEach((element) {
            print("enter DeleteSavedPostStart 2");
            FirebaseFirestore.instance
                .collection("Users")
                .doc(element.data()['id'])
                .collection("MySavedPost")
                .get()
                .then((value3) {
              value3.docs.forEach((element2) {
                if (element2.data()['PostID'] == UserPost) {
                  print("enter DeleteSavedPostStart 3");

                  FirebaseFirestore.instance
                      .collection('Users')
                      .doc(element.data()['id'])
                      .collection('MySavedPost')
                      .doc(element2.data()['PostID'])
                      .delete()
                      .then((value4) {
                    getUserSavedPost(USERID: element.data()['id']);
                    print("enter DeleteSavedPostStart 4");
                  });
                }
                ;
                ////////////delete in friends post
                FirebaseFirestore.instance
                    .collection("Users")
                    .get()
                    .then((value5) {
                  print("enter DeletMyFriendPostStart 1");

                  value5.docs.forEach((element3) {
                    print("enter DeletMyFriendPostStart 2");
                    FirebaseFirestore.instance
                        .collection("Users")
                        .doc(element3.data()['id'])
                        .collection("FriendsPost")
                        .get()
                        .then((value6) {
                      value6.docs.forEach((element4) {
                        if (element4.data()['PostID'] == UserPost) {
                          print("enter DeletMyFriendPostStart 3");

                          FirebaseFirestore.instance
                              .collection('Users')
                              .doc(element3.data()['id'])
                              .collection('FriendsPost')
                              .doc(element4.data()['PostID'])
                              .delete()
                              .then((value7) => getUserSavedPost(
                                  USERID: element3.data()['id']));
                          print("enter DeletMyFriendPostStart 4");
                        }
                      });
                    });
                  });
                  emit(updateMyFriendPostEnd());
                });
              });
            });
          });
          emit(updateSavedPostEnd());
        });
      });
    });
  }

  void GetSavedPost({required String POSTID}) {
    emit(SavePOSTLOADED());
    FirebaseFirestore.instance
        .collection("Post")
        .doc(POSTID)
        .get()
        .then((value) {
      var id111 = Uuid().v4();
      /* Adding the post to sub collection in  user doc*/
      FirebaseFirestore.instance
          .collection('Users')
          .doc(uId)
          .get()
          .then((value2) {
        FirebaseFirestore.instance
            .collection('Users')
            .doc(uId)
            .collection('MySavedPost')
            .doc(POSTID)
            .set({
          "Uid": value.data()!['Uid'],
          "category": value.data()!['category'],
          "photo": value.data()!['photo'],
          "placeName": value.data()!['placeName'],
          "place": value.data()!['place'],
          //place
          "review": value.data()!['review'],
          "tag": value.data()!['tag'],
          "UserPic": value.data()!['UserPic'],
          'PostID': POSTID,
          'phone': value.data()!['phone'],
          'PostDate': value.data()!['PostDate']
        }).then((value) {
          getUserSavedPost(USERID: uId);
        });
      });
    });
    emit(SavePOSTDone());
  }

  void deletUserSavedPost({required String IDPost, required String USERID}) {
    emit(DELETSavedPOSTLOADED());
    FirebaseFirestore.instance
        .collection("Users")
        .doc(USERID)
        .collection("MySavedPost")
        .doc(IDPost)
        .delete()
        .then((value) {
      emit(deleteSavedPostDone());
      getUserSavedPost(USERID: USERID);
    });
  }

  List<Map<String, dynamic>> UserSavedPost = [];
  void getUserSavedPost({required String USERID}) {
    emit(ViewUserSavedPost());
    UserSavedPost = [];

    FirebaseFirestore.instance
        .collection("Users")
        .doc(USERID)
        .collection("MySavedPost")
        .orderBy('PostDate', descending: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        UserSavedPost.add(element.data());
        emit(ViewUserSavedPostDone());
      });
      emit(ViewUserSavedPostDone2());
      //   print("the Savedcategory is ++++++++++++++++++++ ${UserSavedPost}");
    });
  }

  void editReview({required String newRev, required String Pid}) {
    emit(EditReviewloaded());

////edit in my posts
    FirebaseFirestore.instance
        .collection('Users')
        .doc(uId)
        .collection("MyPost")
        .doc(Pid)
        .update({'review': newRev});
    Getreview(Pid);
    ////edit in posts
    FirebaseFirestore.instance
        .collection('Post')
        .doc(Pid)
        .update({'review': newRev});
    ////edit in my saved posts of friends
    FirebaseFirestore.instance.collection("Users").get().then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(element.data()['id'])
            .collection("MySavedPost")
            .doc(Pid)
            .update({'review': newRev});
        ////edit in my friends posts of friends
        FirebaseFirestore.instance.collection("Users").get().then((value) {
          value.docs.forEach((element) {
            FirebaseFirestore.instance
                .collection("Users")
                .doc(element.data()['id'])
                .collection("FriendsPost")
                .doc(Pid)
                .update({'review': newRev});
          });
        });
      });
    });

    emit(EditReviewdone());
  }

  String? review;
  Getreview(String PId) {
    emit(GetRevload());
    FirebaseFirestore.instance
        .collection('Users')
        .doc(uId)
        .collection("MyPost")
        .doc(PId)
        .get()
        .then((value) => review = value.data()!['review']);
    emit(GetRevDone());
  }

  updateImg() {
    emit(notupdated());
    emit(Updateimg());
  }
/* 


String FilledSave = "assets/icons/save-filled.png";
  String UnFilledSave = "assets/icons/save.png";
  Future<String> CheckIfExist({required String POSTID, required String USERID})async {
      String flag = UnFilledSave;
     emit(updateStatusStart());
    print("enter $flag");
  
   QuerySnapshot qr =
        await FirebaseFirestore.instance
        .collection("Users")
        .doc(USERID)
        .collection("MySavedPost")
        .get();
       // .then((value) {
          for (int i = 0; i < qr.docs.length; i++) {
      if (qr.docs[i].get("PostID") == USERID) {
         flag = FilledSave;
    //  value.docs.forEach((element) {
      //  if (element.data()["PostID"] == POSTID) {
          flag = FilledSave;
          print('enter $flag');
        }
        
      };
      return flag;
    }
*/

  void DELETENOTIFICATION({required String notificationID}) {
    emit(Deletnotificationstart());
    FirebaseFirestore.instance
        .collection('Notification')
        .doc(notificationID)
        .delete()
        .then((value) {
      getNotification(id: uId);
    });
    emit(DeletnotificationDone());
  }

  List<Map<String, dynamic>> UserFriendPost = [];
  void GETUSERRECOMMENDATION({required String uid}) {
    emit(GETUSERRECOMMENDATIONstart());
    UserFriendPost = [];

    FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .collection("MyPost")
        .orderBy('PostDate', descending: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        UserFriendPost.add(element.data());
        emit(GETUSERRECOMMENDATIONstartDone());
      });
    });
  }
}
