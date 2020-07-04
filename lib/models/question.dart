import 'option.dart';

class Question {
  String _id;
  String _text;
  List<Option> _options;
  String _categoryId;

  Question({String id, String text, List<Option> options, String categoryId}) {
    this._id = id;
    this._text = text;
    this._options = options;
    this._categoryId = categoryId;
  }

  String get id => _id;

  set id(String id) => _id = id;

  String get text => _text;

  set text(String text) => _text = text;

  List<Option> get options => _options;

  set options(List<Option> options) => _options = options;

  String get categoryId => _categoryId;

  set categoryId(String categoryId) => _categoryId = categoryId;

  Question.fromJson(Map<String, dynamic> json) {
    _id = json['_id'];
    _text = json['text'];
    if (json['options'] != null) {
      _options = new List<Option>();
      json['options'].forEach((v) {
        _options.add(new Option.fromJson(v));
      });
    }
    _categoryId = json['category_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._id;
    data['text'] = this._text;
    if (this._options != null) {
      data['options'] = this._options.map((v) => v.toJson()).toList();
    }
    data['category_id'] = this._categoryId;
    return data;
  }
}
