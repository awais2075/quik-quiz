import 'package:flutter/foundation.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter/foundation.dart';

class Category {
  String _id;
  String _name;
  String _imageUrl;

  Category({String id, String name, String imageUrl}) {
    this._id = id;
    this._name = name;
    this._imageUrl = imageUrl;
  }

  String get id => _id;

  set id(String id) => _id = id;

  String get name => _name;

  set name(String name) => _name = name;

  String get imageUrl => _imageUrl;

  set imageUrl(String imageUrl) => _imageUrl = imageUrl;

  Category.fromJson(Map<String, dynamic> json) {
    _id = json['_id'];
    _name = json['name'];
    _imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._id;
    data['name'] = this._name;
    data['image_url'] = this._imageUrl;
    return data;
  }
}
/*class Category {
  String _id;
  String _name;

  Category({String id, String name}) {
    this._id = id;
    this._name = name;
  }

  String get id => _id;

  set id(String id) => _id = id;

  String get name => _name;

  set name(String name) => _name = name;

  Category.fromJson(Map<String, dynamic> json) {
    _id = json['_id'];
    _name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._id;
    data['name'] = this._name;
    return data;
  }
}*/
