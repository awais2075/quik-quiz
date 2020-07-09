import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutterqaapp/models/question_map.dart';
import 'package:flutterqaapp/models/category.dart';
import 'package:flutterqaapp/models/option.dart';
import 'package:flutterqaapp/models/question.dart';
import 'package:flutterqaapp/models/question_result.dart';
import 'package:flutterqaapp/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class QuestionPage extends StatefulWidget {
  final Category _category;

  QuestionPage(this._category);

  @override
  _QuestionPageState createState() => _QuestionPageState(_category);
}

class _QuestionPageState extends State<QuestionPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Category _category;
  List<Question> _currentPageQuestions = new List<Question>();

//  Map<int, List<Question>> _questions;
  Map<int, List<Question>> _questions = Map<int, List<Question>>();
  bool _isLoading = true;
  int _pageView = 0;

  int _pageNumber = 1;

  int _questionLimit = 0;
  int _questionNumber = 0;
  int _totalPages = 0;

  double itemSize = 50;
  static final int TOTAL_QUESTIONS_PER_PAGE = 10;
  static const _kDuration = const Duration(milliseconds: 500);
  static const _kCurve = Curves.easeIn;

  PageController _pageController;
  ItemScrollController _itemScrollController;

  ScrollController _scrollController;

  _QuestionPageState(this._category);

  double _value = 1.0;

  @override
  void initState() {
    _fetchData(_pageNumber);

    _initScrollController();

    _initItemScrollController();
    _initPageController();

    _initAnimation();

    super.initState();
  }

  _initPageController() {
    _pageController =
        PageController(keepPage: true, initialPage: 0, viewportFraction: 1);
  }

  _initItemScrollController() {
    _itemScrollController = ItemScrollController();
  }

  _initScrollController() {
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.verified_user,
                color: COLOR_GREEN,
              ),
              onPressed: () =>
                  Tooltip(key: _scaffoldKey, message: 'Current Page'),
              tooltip: 'Current Page',
            ),
            IconButton(
              icon: Icon(
                Icons.verified_user,
                color: COLOR_ORANGE,
              ),
              onPressed: () => null,
              tooltip: 'Visited Pages',
            ),
          ],
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
      floatingActionButton: (_isLoading)
          ? _emptyWidget()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: (_pageView > 0)
                        ? _previousQuestionWidget()
                        : (_pageNumber > 1)
                            ? _previousPageWidget()
                            : _emptyWidget()),
                Spacer(),
                (_pageView < _questionLimit - 1)
                    ? _nextQuestionWidget()
                    : (_pageNumber < _totalPages)
                        ? _nextPageWidget()
                        : _emptyWidget()
              ],
            ),
      body: (_isLoading)
          ? _progressWidget()
          : (_currentPageQuestions.isNotEmpty)
              ? _questionBodyWidget()
              : _reloadWidget(),
    );
  }

  Widget _progressWidget() {
    return LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(COLOR_GREEN),
      backgroundColor: COLOR_LIGHT_ORANGE,
    );
  }

  Widget _reloadWidget() {
    return Column(
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
    );
  }

  Widget _questionBodyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _pageProgressWidget(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: '${_pageView + 1}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: COLOR_GREEN)),
                TextSpan(
                    text: '/${_questionLimit}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: COLOR_ORANGE))
              ]))),
        ),
        _pagingWidget(),
        Flexible(flex: 1, child: _questionWidget(_currentPageQuestions)),
        /*Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: _optionsWidget(_currentPageQuestions[_pageView].options),
            )),*/
        /*Flexible(
            child: Padding(
          padding: const EdgeInsets.only(left: 30, top: 10),
          child: Visibility(visible: true, child: _reportQuestionWidget()),
        )),*/
      ],
    );
  }

  Widget _pageProgressWidget() {
    return LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(COLOR_GREEN),
      backgroundColor: COLOR_LIGHT_ORANGE,
      value: (_value / _questionLimit),
      semanticsLabel: _value.toString(),
    );
  }

  Widget _reportQuestionWidget(Question question, int index) {
    String questionText =
        (question.isReported) ? 'Question Reported' : 'Report Question';
    Color color = (question.isReported) ? COLOR_ORANGE : COLOR_DARK_TAN;
    return FlatButton.icon(
        icon: Icon(
          Icons.info,
          color: color,
        ),
        label: Text(
          questionText,
          style: TextStyle(color: color),
        ),
        onPressed: (question.isReported)
            ? null
            : () => _reportQuestion(question, index));
  }

  _fetchData(int pageNum) async {
    setState(() {
      _isLoading = true;
    });
    var request = '$BASE_URL/questions/c_id/${_category.id}/?page_no=$pageNum';
    print(request);

    await http.get(request).then((response) {
      QuestionResult result =
          QuestionResult.fromJson(json.decode(response.body));

      setState(() {
        //start from beginning

        _pageNumber = pageNum;
        _pageView = 0;
        _value = 1.0;
        _questionNumber = (_pageNumber - 1) * TOTAL_QUESTIONS_PER_PAGE + 1;

        _questions[pageNum] = result.body;


        (QuestionMap().map[_category.id])[pageNum] = _questions[pageNum];
        _currentPageQuestions = List.from(_questions[pageNum]);
        _questionLimit = _currentPageQuestions.length;

        _totalPages = (result.count / TOTAL_QUESTIONS_PER_PAGE).ceil();

        _pageNumber = pageNum;

        _isLoading = false;

        Future.delayed(Duration(seconds: 1), () {
//          _itemScrollController.scrollTo(index: _pageNumber-1, duration: Duration(seconds: 1));

          _itemScrollController.jumpTo(index: _pageNumber - 1);
        });
      });
    }).catchError((error) {
      print(error.message);
      setState(() {
        if (_currentPageQuestions.isEmpty) {
          _isLoading = false;
          _pageView = 0;
          _currentPageQuestions.clear();
        } else {
          _isLoading = false;

          Future.delayed(Duration.zero, () {
            _scaffoldKey.currentState
                .showSnackBar(_snackBarWidget('Failed to Load Data'));
          });
        }
      });
    });
  }

  _reportQuestion(Question question, int index) async {
    question.isReported = true;

    var url = '$BASE_URL/questions/report/question?_id=${question.id}';

    await http.put(url,
        body: jsonEncode(question),
        headers: {"Content-Type": "application/json"}).then((response) {
      setState(() {
        _scaffoldKey.currentState
            .showSnackBar(_snackBarWidget('Question has been Reported'));
      });
    }).catchError((error) {
      setState(() {
        question.isReported = false;
      });
      _scaffoldKey.currentState
          .showSnackBar(_snackBarWidget('Error Reporting...'));
    });
  }

  Widget _optionsWidget(List<Option> options) {
    return ListView.builder(
        shrinkWrap: true,
        controller: _scrollController,
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

  Widget _questionWidget(List<Question> questions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: PageView.builder(
          physics: NeverScrollableScrollPhysics(),
          pageSnapping: true,
          controller: _pageController,
          itemCount: questions.length,
          onPageChanged: (int index) {
            print('onpage changed : $index');
          },
          itemBuilder: (BuildContext context, int index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  dense: true,
                  title: Text(
                    'Question $_questionNumber',
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
                                text:
                                    '${questions[index].text.substring(0, 1)}',
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
                ),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(20.0),
                  child: _optionsWidget(questions[index].options),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _reportQuestionWidget(questions[index], index),
                )
              ],
            );
          }),
    );
  }

  Widget _previousQuestionWidget() {
    return FlatButton(
      textColor: Colors.blue,
      onPressed:
          (_questionNumber % 10 >= 0) ? () => _loadPreviousQuestion() : null,
      child: Text(
        'Previous',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: COLOR_GREEN),
      ),
    );
  }

  void _loadPreviousQuestion() {
    if (_pageController.hasClients) {
      _pageController.previousPage(duration: _kDuration, curve: _kCurve);
    }
    setState(() {
      _pageView--;
      _questionNumber--;
      _value--;
    });
  }

  Widget _nextQuestionWidget() {
    return FlatButton(
      textColor: Colors.blue,
      onPressed: () => _loadNextQuestion(),
      child: Text(
        'Next',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: COLOR_GREEN),
      ),
    );
  }

  void _loadNextQuestion() {
    if (_pageController.hasClients) {
      _pageController.nextPage(duration: _kDuration, curve: _kCurve);
    }
    setState(() {
      _value++;
      _questionNumber++;
      _pageView++;

      print('$_pageView');
    });
  }

  Widget _nextPageWidget() {
    return FlatButton(
      textColor: Colors.blue,
      onPressed: () => _loadNextPage(),
      child: Text(
        'Next Page',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: COLOR_GREEN),
      ),
    );
  }

  Widget _previousPageWidget() {
    return FlatButton(
      textColor: Colors.blue,
      onPressed: () {
        int pageNum = _pageNumber;
        _loadPage(--pageNum);
      },
      child: Text(
        'Previous Page',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: COLOR_GREEN),
      ),
    );
  }

  _loadPreviousPage() {
    setState(() {
      _animationController.forward(from: 0.0);

      _pageNumber--;

      _currentPageQuestions = _questions[_pageNumber];

      _questionLimit = _currentPageQuestions.length;
      _value = _questionLimit + 0.0;

      _pageView = 9;
      _pageController.jumpToPage(_pageView);
      _questionNumber = _pageNumber * TOTAL_QUESTIONS_PER_PAGE;
    });
  }

  _loadNextPage() {
    int pageNum = _pageNumber;
    _loadPage(++pageNum);
  }

  _loadPrevPage() {
    int pageNum = _pageNumber;

    print('pageNum $pageNum');
    _loadPage(--pageNum);
  }

  _loadPage(int pageNum) {
    setState(() {
      print('loadPage $pageNum');
      if (_questions[pageNum] != null) {
        _currentPageQuestions = List.from(_questions[pageNum]);

        _questionLimit = _currentPageQuestions.length;
        _value = 1;

        _pageView = 0;
        _pageController.jumpToPage(_pageView);

        _pageNumber = pageNum;
        _questionNumber = (_pageNumber - 1) * TOTAL_QUESTIONS_PER_PAGE + 1;

        Future.delayed(Duration.zero, () {
          _itemScrollController.scrollTo(
              index: _pageNumber - 1, duration: Duration(seconds: 1));
        });
      } else {
        _fetchData(pageNum);
      }
    });
  }

  Widget _pagingWidget() {
    return Container(
      height: 40,
      child: ScrollablePositionedList.builder(
        scrollDirection: Axis.horizontal,
        itemScrollController: _itemScrollController,
        itemCount: _totalPages,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () =>
                (index + 1 == _pageNumber) ? null : _loadPage(index + 1),
            child: Card(
              color: (index + 1 == _pageNumber)
                  ? COLOR_GREEN
                  : (_questions.containsKey(index + 1)
                      ? COLOR_ORANGE
                      : null),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(
                  '${index + 1}',
                  style: TextStyle(
                      color: (index + 1 == _pageNumber ||
                              _questions.containsKey(index + 1))
                          ? Colors.white
                          : null),
                )),
              ),
            ),
          );
        },
      ),
    );
    return Container(
      height: 50,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: _totalPages,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () =>
                  (index + 1 == _pageNumber) ? null : _loadPage(index + 1),
              child: Container(
                width: 50,
                child: Card(
                  color: (index + 1 == _pageNumber)
                      ? COLOR_GREEN
                      : (_questions.containsKey(index + 1)
                          ? COLOR_ORANGE
                          : null),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                      '${index + 1}',
                      style: TextStyle(
                          color: (index + 1 == _pageNumber ||
                                  _questions.containsKey(index + 1))
                              ? Colors.white
                              : null),
                    )),
                  ),
                ),
              ),
            );
          }),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        (_pageNumber == 1)
            ? _emptyWidget()
            : Container(
                width: 30,
                height: 30,
                child: FloatingActionButton(
                  heroTag: 'loadPreviousPage',
                  onPressed: () {
                    _loadPrevPage();
                  },
                  backgroundColor: Colors.grey,
                  child: Text(
                    '${_pageNumber - 1}',
                    style: TextStyle(fontSize: 8),
                  ),
                ),
              ),
        SizedBox(
          width: 10,
        ),
        Container(
          width: 45,
          height: 45,
          child: ScaleTransition(
            scale: _animation,
            alignment: Alignment.center,
            child: FloatingActionButton(
              heroTag: 'currentPage',
              backgroundColor: COLOR_GREEN,
              child: Text(
                '$_pageNumber',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        (_pageNumber == _totalPages)
            ? _emptyWidget()
            : Container(
                width: 30,
                height: 30,
                child: FloatingActionButton(
                  heroTag: 'loadNextPage',
                  onPressed: () {
                    int pageNum = _pageNumber;
                    _loadPage(++pageNum);
                  },
                  backgroundColor: Colors.grey,
                  child: Text(
                    '${_pageNumber + 1}',
                    style: TextStyle(fontSize: 8),
                  ),
                ),
              ),
      ],
    );
  }

  double initValue = 1.0;

  AnimationController _animationController;
  Animation<double> _animation;

  _initAnimation() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this, value: 0.1);

    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutExpo);

    _animationController.forward();
  }

  Widget _emptyWidget() {
    return SizedBox.shrink();
  }

  Widget _snackBarWidget(String text) {
    return SnackBar(
      content: Text('$text'),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          _scaffoldKey.currentState.hideCurrentSnackBar();
        },
      ),
    );
  }
}
