import 'package:flutterqaapp/models/question.dart';

class QuestionResult {
  int _status;
  List<Question> _body;

  QuestionResult({int status, List<Question> body}) {
    this._status = status;
    this._body = body;
  }

  int get status => _status;

  set status(int status) => _status = status;

  List<Question> get body => _body;

  set body(List<Question> body) => _body = body;

  QuestionResult.fromJson(Map<String, dynamic> json) {
    _status = json['status'];
    if (json['body'] != null) {
      _body = new List<Question>();
      json['body'].forEach((v) {
        _body.add(new Question.fromJson(v));
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