import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutterqaapp/enums/status.dart';
import 'package:flutterqaapp/models/category.dart';
import 'package:flutterqaapp/models/progress.dart';
import 'package:flutterqaapp/models/ques_map.dart';
import 'package:flutterqaapp/models/question_result.dart';
import 'package:flutterqaapp/utils/constants.dart';
import 'package:http/http.dart' as http;

class QuestionPageBloc {
  final _questionWidgetController = StreamController<QuesMap>.broadcast();

  Stream<QuesMap> get questionWidgetStream => _questionWidgetController.stream;

  final _nextQuestionWidgetController = StreamController.broadcast();

  StreamSink get nextQuestionWidgetSink => _nextQuestionWidgetController.sink;

  final _previousQuestionWidgetController = StreamController.broadcast();

  StreamSink get previousQuestionWidgetSink =>
      _previousQuestionWidgetController.sink;

  final _nextPageWidgetController = StreamController<String>.broadcast();

  StreamSink<String> get nextPageWidgetSink => _nextPageWidgetController.sink;

  final _previousPageWidgetController = StreamController.broadcast();

  StreamSink get previousPageWidgetSink => _previousPageWidgetController.sink;

  final _specificPageController = StreamController.broadcast();

  StreamSink get specificPageSink => _specificPageController.sink;

  final _progressWidgetController = StreamController<Progress>.broadcast();

  Stream<Progress> get progressWidgetStream => _progressWidgetController.stream;

  final _progress = Progress();
  Category _category;

  QuestionPageBloc(this._category) {
    _nextQuestionWidgetController.stream.listen((_) {
      _progress.currentQuestion++;
      _progressWidgetController.add(_progress);
    });

    _previousQuestionWidgetController.stream.listen((_) {
      _progress.currentQuestion--;
      _progressWidgetController.add(_progress);
    });

    _nextPageWidgetController.stream.listen((categoryId) {
      _loadQuestions(categoryId, ++_progress.currentPage);
    });

    _previousPageWidgetController.stream.listen((categoryId) {
      _loadQuestions(categoryId, --_progress.currentPage);
    });

    _specificPageController.stream.listen((currentPage) {
      _loadQuestions(_category.id, _progress.currentPage = currentPage);
    });
  }

  void dispose() {
    _questionWidgetController.close();

    _nextQuestionWidgetController.close();
    _previousQuestionWidgetController.close();

    _nextPageWidgetController.close();
    _previousPageWidgetController.close();


    _specificPageController.close();

    _progressWidgetController.close();
  }

  _loadQuestions(String categoryId, int pageNum) async {
    _questionWidgetController.add(QuesMap(STATUS.LOADING, null, 0));

    var request = '$BASE_URL/questions/c_id/$categoryId/?page_no=$pageNum';

    debugPrint(request);
    await http.get(request).timeout(Duration(seconds: 10)).then((response) {
      QuestionResult result =
          QuestionResult.fromJson(json.decode(response.body));


      Future.delayed(Duration.zero, (){
        _progress.currentPage = pageNum;
        _progress.totalPages = (result.count / 10).ceil();

        _progress.currentQuestion = 1;
        _progress.totalQuestions = result.body.length;

        _progressWidgetController.add(_progress);
      });

      _questionWidgetController.add(QuesMap(STATUS.SUCCESS, result.body, pageNum));

    }).catchError((error) {
      _questionWidgetController.add(QuesMap(STATUS.FAIL, null, 0));
    });
  }
}
