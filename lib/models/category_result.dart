import 'package:flutterqaapp/models/category.dart';

class CategoryResult {
  int _status;
  List<Category> _body;

  CategoryResult({int status, List<Category> body}) {
    this._status = status;
    this._body = body;
  }

  int get status => _status;

  set status(int status) => _status = status;

  List<Category> get body => _body;

  set body(List<Category> body) => _body = body;

  CategoryResult.fromJson(Map<String, dynamic> json) {
    _status = json['status'];
    if (json['body'] != null) {
      _body = new List<Category>();
      json['body'].forEach((v) {
        _body.add(Category.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this._status;
    if (this._body != null) {
      data['body'] = this._body.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
