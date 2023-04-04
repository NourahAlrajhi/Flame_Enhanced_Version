import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  late String fullName;
  late String phone;
  late String birthDate;
  late String id;
  late String userImage;
  late String status;
  Customer() {
    fullName = "";
    phone = "";
    birthDate = "";
    id = "";
    userImage = "";
    status ="";
  }

  Customer.fromMap(
      Map<String, dynamic> data, DocumentReference documentReference) {
    fullName = data['fullName'];
    phone = data['phone'];
    birthDate = data['birthDate'];
    id = data['id'];
    userImage = data['userImage'];
    status = data['status'];
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['fullName'] = fullName;
    data['phone'] = phone;
    data['birthDate'] = birthDate;
    data['id'] = id;
    data['userImage'] = userImage;
    data['status'] = status;
    return data;
  }
}
