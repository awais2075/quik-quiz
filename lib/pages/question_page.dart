import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterqaapp/models/category.dart';
import 'package:flutterqaapp/models/option.dart';
import 'package:flutterqaapp/models/question.dart';
import 'package:flutterqaapp/models/question_result.dart';
import 'package:flutterqaapp/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:random_color/random_color.dart';

class QuestionPage extends StatefulWidget {
  final Category _category;

  QuestionPage(this._category);

  @override
  _QuestionPageState createState() => _QuestionPageState(_category);
}

class _QuestionPageState extends State<QuestionPage> {
  final Category _category;
  List<Question> _questions = new List<Question>();
  bool _isLoading = true;
  int _pageNumber = 1;

  int _questionIndex = 0;

  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.easeIn;

  PageController _pageController;

  int _currentPageView = 0;

  _QuestionPageState(this._category);

  double _value = 1.0;

  @override
  void initState() {
    _pageController =
        PageController(keepPage: true, initialPage: 0, viewportFraction: 1);

    _pageController.addListener(() {
      setState(() {
        _questionIndex = _currentPageView = _pageController.page.toInt();
      });
    });
    _fetchData(_pageNumber);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _isLoading,
      child: Scaffold(
        backgroundColor: COLOR_PALE_ORANGE,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white.withOpacity(0),
            title: Text(
              _category.name,
              style: TextStyle(
                  color: COLOR_DARK_TAN,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: <Widget>[],
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: COLOR_DARK_TAN,
                size: 14,
              ),
            )),
        floatingActionButton: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: _showPreviousButton(),
            ),
            Spacer(),
            (_questions.length - 1 == _currentPageView)
                ? _showLoadMore()
                : _showNextButton(),
          ],
        ),
        body: (_isLoading)
            ? LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(COLOR_GREEN),
                backgroundColor: COLOR_LIGHT_ORANGE,
              )
            : (_questions.isNotEmpty)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(COLOR_GREEN),
                        backgroundColor: COLOR_LIGHT_ORANGE,
                        value: (_value / 10),
                        semanticsLabel: _value.toString(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: '${_currentPageView + 1}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: COLOR_GREEN)),
                              TextSpan(
                                  text: '/${10}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: COLOR_ORANGE))
                            ]))),
                      ),
                      Flexible(flex: 1, child: _populatePageView(_questions)),
                      SizedBox(
                        height: 20,
                      ),
                      Flexible(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: _populateOptionsList(
                                _questions[_currentPageView].options),
                          )),
                      Flexible(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: GestureDetector(
                          onTap: () {
                            print('hello');
                          },
                          child: Visibility(
                            visible: false,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.info,
                                  color: COLOR_DARK_TAN,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Report Question',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: COLOR_DARK_TAN,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ))
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.error,
                        color: Colors.redAccent,
                        size: 96,
                      ),
                      Center(
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: COLOR_GREEN,
                          child: Text('Try Again'),
                          onPressed: () {
                            _fetchData(_pageNumber);
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  _fetchData(int pageNum) async {
    setState(() {
      _isLoading = true;
    });
    var request = '$BASE_URL/questions/c_id/${_category.id}/?page_no=$pageNum';
    print(request);
    await http.get('$request').then((response) {
      QuestionResult result =
          QuestionResult.fromJson(json.decode(response.body));

      setState(() {
        _questions.addAll(result.body);
        Future.delayed(Duration.zero, () {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(_currentPageView);
          }
        });

        Future.delayed(Duration(seconds: 3));
        _isLoading = false;
      });
    }).catchError((error) {
      print(error.message);
      setState(() {
        _isLoading = false;
        _questions.clear();
      });
    });
  }

  Widget _populateOptionsList(List<Option> options) {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: options.length,
        itemBuilder: (context, index) {
          return Card(
            color: (options[index].isTrue ? COLOR_GREEN : COLOR_ORANGE),
            child: ListTile(
              title: Text(
                '${options[index].text}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
              onTap: () {
                print('${options[index].isTrue}');
              },
            ),
          );
        });
  }

  Widget _populatePageView(List<Question> questions) {
    return PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        pageSnapping: true,
        controller: _pageController,
        itemCount: _questions.length,
        onPageChanged: (int index) {},
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            dense: true,
            title: Text(
              'Question ${index + 1}',
              style: TextStyle(
                  color: COLOR_DARK_TAN,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
              textAlign: TextAlign.center,
            ),
            subtitle: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                          text: '${questions[index].text.substring(0, 1)}',
                          style: TextStyle(
                              color: COLOR_DARK_TAN,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          style: TextStyle(
                            fontSize: 18,
                            color: COLOR_DARK_TAN,
                          ),
                          text:
                              '${questions[index].text.substring(1, questions[index].text.length - 1)}'),
                    ])),
          );
        });
  }

  void _moveNext() {
    if (_pageController.hasClients) {
      _pageController.nextPage(duration: _kDuration, curve: _kCurve);
      setState(() {
        _value++;
      });
    }
  }

  void _movePrevious() {
    if (_pageController.hasClients) {
      _pageController.previousPage(duration: _kDuration, curve: _kCurve);

      setState(() {
        _value--;
      });
    }
  }

  Widget _showPreviousButton() {
    return FlatButton(
      textColor: Colors.blue,
      onPressed: (_currentPageView > 0.0) ? () => _movePrevious() : null,
      child: Text(
        'Previous',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: COLOR_GREEN),
      ),
    );
  }

  Widget _showNextButton() {
    return FlatButton(
      textColor: Colors.blue,
      onPressed: (_questions.length - 1 > _currentPageView)
          ? () {
              _moveNext();
            }
          : null,
      child: Text(
        'Next',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: COLOR_GREEN),
      ),
    );
  }

  Widget _showLoadMore() {
    return FlatButton(
      textColor: Colors.blue,
      onPressed: () {
        setState(() {
          _value = 0;
          _pageNumber++;


        });
        _fetchData(_pageNumber);
      },
      child: Text(
        'Load More',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: COLOR_GREEN),
      ),
    );
  }

}
