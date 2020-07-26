import 'package:flutterqaapp/enums/status.dart';
import 'package:flutterqaapp/models/question.dart';

class QuesMap {

  STATUS _status;
  List<Question> _questions;
  int _pageNumber;


  QuesMap(this._status, this._questions, this._pageNumber);

  List<Question> get questions => _questions;

  set questions(List<Question> value) {
    _questions = value;
  }

  STATUS get status => _status;

  set status(STATUS value) {
    _status = value;
  }

  int get pageNumber => _pageNumber;

  set pageNumber(int value) {
    _pageNumber = value;
  }
}