import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_launcher_icons/ios.dart';

class CategoriesModel {
  String? color;
  String? name;
  List<String>? tags;
  String? selectedTag;

  CategoriesModel({this.color, this.name, this.tags, this.selectedTag});

  CategoriesModel.fromJson(QueryDocumentSnapshot doc) {


    Map<String, dynamic> json = doc.data() as Map<String,dynamic>;


    color = json['color']??"0xFF00000";
    name = json['name']??"NA";
    tags = json['Tags'].cast<String>()??[];
    selectedTag = json['selectedTag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['color'] = this.color;
    data['name'] = this.name;
    data['Tags'] = this.tags;
    data['selectedTag'] = this.selectedTag;
    return data;
  }
}