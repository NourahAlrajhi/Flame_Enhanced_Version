import 'package:cloud_firestore/cloud_firestore.dart';

class Recommendation {
  late String Uid;
  late String category;
  late String photo;
  late GeoPoint place;
  late String review;
  late String tag;
  late String title;
  late String PostIDDDDD;
  late String number;

  Recommendation(String pic, String rev, String tags, GeoPoint plac,
      String titles, String cat, String PostID, String phonNumber) {
    Uid = "";
    category = cat;
    photo = pic;
    place = plac;
    review = rev;
    tag = tags;
    title = titles;
    PostIDDDDD = PostID;
    number = phonNumber;
  }

  Recommendation.fromMap(Map<String, dynamic> data) {
    Uid = data['Uid'];
    category = data['category'];
    photo = data['photo'];
    place = data['place'];
    review = data['review'];
    tag = data['tag'];
    title = data['title'];
    PostIDDDDD = data['PostIDDDDD'];
    number = data['phone'];
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['Uid'] = Uid;
    data['category'] = category;
    data['photo'] = photo;
    data['place'] = place;
    data['review'] = review;
    data['tag'] = tag;
    data['title'] = title;
    data[PostIDDDDD] = PostIDDDDD;
    data['phone'] = number;

    return data;
  }
}
