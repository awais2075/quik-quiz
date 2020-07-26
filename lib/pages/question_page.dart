import 'dart:convert';
import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutterqaapp/bloc/question_page_bloc.dart';
import 'package:flutterqaapp/enums/status.dart';
import 'package:flutterqaapp/models/progress.dart';
import 'package:flutterqaapp/models/ques_map.dart';
import 'package:flutterqaapp/models/question_map.dart';
import 'package:flutterqaapp/models/category.dart';
import 'package:flutterqaapp/models/option.dart';
import 'package:flutterqaapp/models/question.dart';
import 'package:flutterqaapp/models/question_result.dart';
import 'package:flutterqaapp/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:toast/toast.dart';

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


  bool _isReporting = false;
  int _pageView = 0;

  int _pageNumber = 1;

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

  QuestionPageBloc _bloc;

  @override
  void initState() {
    _bloc = QuestionPageBloc(_category);
    _bloc.nextPageWidgetSink.add(_category.id);

//    _fetchData(1);
    _initScrollController();

    _initItemScrollController();
    _initPageController();

    _initAnimation();

    super.initState();
  }

  _initPageController() {
    _pageController =
        PageController(keepPage: false, initialPage: 0, viewportFraction: 1);
  }

  _initItemScrollController() {
    _itemScrollController = ItemScrollController();
  }

  _initScrollController() {
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init();
    return IgnorePointer(
      ignoring: _isReporting,
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: COLOR_PALE_ORANGE,
          appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0),
              title: Text(
                _category.name,
                style: TextStyle(
                    color: COLOR_DARK_TAN,
                    fontSize: ScreenUtil().setSp(48),
                    fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.verified_user,
                    color: COLOR_GREEN,
                  ),
                  onPressed: () {
                    _showToast(context, 'Current Page', gravity: Toast.BOTTOM);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.verified_user,
                    color: COLOR_ORANGE,
                  ),
                  onPressed: () {
                    _showToast(context, 'Visited Pages', gravity: Toast.BOTTOM);
                  },
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
          floatingActionButton: StreamBuilder(
              stream: _bloc.progressWidgetStream,
              builder:
                  (BuildContext context, AsyncSnapshot<Progress> snapshot) {
                debugPrint('${snapshot.connectionState}');
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(80)),
                            child: (snapshot.data.currentQuestion == 1 &&
                                    snapshot.data.currentPage > 1)
                                ? _previousPageWidget()
                                : (snapshot.data.currentQuestion > 1)
                                    ? _previousQuestionWidget()
                                    : _emptyWidget()),
                        Spacer(),
                        (snapshot.data.currentQuestion ==
                                    snapshot.data.totalQuestions &&
                                snapshot.data.currentPage <
                                    snapshot.data.totalPages)
                            ? _nextPageWidget()
                            : (snapshot.data.currentQuestion <
                                    snapshot.data.totalQuestions)
                                ? _nextQuestionWidget()
                                : _emptyWidget(),
                      ],
                    );
                  default:
                    return _emptyWidget();
                }
              }),
          body: StreamBuilder(
              stream: _bloc.questionWidgetStream,
              builder: (BuildContext context, AsyncSnapshot<QuesMap> snapshot) {
                debugPrint('questionWidget ${snapshot.connectionState}');
                switch ((snapshot.data)?.status) {
                  case STATUS.LOADING:
                    return _loadingWidget();
                  case STATUS.SUCCESS:
                    return _questionBodyWidget(
                        snapshot.data.questions, snapshot.data.pageNumber);
                  case STATUS.FAIL:
                    return _tryAgainWidget();
                  default:
                    return _emptyWidget();
                }
              })),
    );
  }

  Widget _loadingWidget({bool isCircular = false}) {
    return (isCircular)
        ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(COLOR_GREEN),
            backgroundColor: COLOR_LIGHT_ORANGE,
          )
        : LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(COLOR_GREEN),
            backgroundColor: COLOR_LIGHT_ORANGE,
          );
  }

  Widget _tryAgainWidget() {
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
              _bloc.nextPageWidgetSink.add(_category.id);
            },
          ),
        ),
      ],
    );
  }

  Widget _questionBodyWidget(List<Question> questions, int pageNumber) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Flexible(
          flex: 2,
          child: StreamBuilder(
              stream: _bloc.progressWidgetStream,
              builder:
                  (BuildContext context, AsyncSnapshot<Progress> snapshot) {
                if(snapshot.hasData) {
                  return _progressAndPagingWidget(snapshot.data);
                }else {
                  return _emptyWidget();
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                    return _progressAndPagingWidget(snapshot.data);
                  default:
                    return _emptyWidget();
                }
              }),
        ),
        Flexible(flex: 12, child: _questionWidget(questions, pageNumber)),
      ],
    );
  }

  Widget _progressAndPagingWidget(Progress progress) {
    return Column(
      children: <Widget>[
        _progressWidget(progress),
        _pagingWidget(progress)
      ],
    );
  }

  Widget _progressWidget(Progress progress) {
    debugPrint('progress : ${progress.totalQuestions}');
    return Column(
      children: <Widget>[
        _numericalProgressWidget(progress),
        _graphicalProgressWidget(progress),
      ],
    );
  }

  Widget _numericalProgressWidget(Progress progress) {
    return LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(COLOR_GREEN),
      backgroundColor: COLOR_LIGHT_ORANGE,
      value: (progress.currentQuestion / progress.totalQuestions),
//      semanticsLabel: _value.toString(),
    );
  }

  Widget _graphicalProgressWidget(Progress progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
          child: Align(
              alignment: Alignment.topLeft,
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: '${progress.currentQuestion}',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: COLOR_GREEN)),
                TextSpan(
                    text: '/${progress.totalQuestions}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: COLOR_ORANGE))
              ]))),
        ),
      ],
    );
  }

  Widget _reportQuestionWidget(Question question) {
    String questionText =
        (question?.isReported) ? 'Question Reported' : 'Report Question';
    Color color = (question.isReported) ? COLOR_ORANGE : COLOR_DARK_TAN;
    return FlatButton.icon(
        icon: Icon(
          Icons.bug_report,
          color: color,
        ),
        label: Text(
          questionText,
          style: TextStyle(color: color),
        ),
        onPressed:
            (question.isReported) ? null : () => _reportQuestion(question));
  }



  _reportQuestion(Question question) async {
    question.isReported = true;
    setState(() {
      _isReporting = true;
    });
    var url = '$BASE_URL/questions/report/question?_id=${question.id}';

    await http.put(url,
        body: jsonEncode(question),
        headers: {"Content-Type": "application/json"}).then((response) {
      setState(() {
        _isReporting = false;
        _showToast(context, 'Question has been Reported',
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//        _scaffoldKey.currentState.showSnackBar(_snackBarWidget('Question has been Reported'));
      });
    }).catchError((error) {
      setState(() {
        _isReporting = false;
        question.isReported = false;
      });
      _showToast(context, 'Error Reporting...',
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//      _scaffoldKey.currentState.showSnackBar(_snackBarWidget('Error Reporting...'));
    });
  }

  Widget _optionsWidget(List<Option> options) {
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
                    color: Colors.white, fontWeight: FontWeight.normal),
              ),
            ),
          );
        });
  }

  Widget _questionWidget(List<Question> questions, int pageNumber) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(60),
          vertical: ScreenUtil().setWidth(30)),
      child: PageView.builder(
          physics: NeverScrollableScrollPhysics(),
          pageSnapping: true,
          controller: _pageController,
          itemCount: questions.length,
          onPageChanged: (int index) {},
          itemBuilder: (BuildContext context, int index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  dense: true,
                  title: Text(
                    'Question ${(pageNumber - 1) * 10 + (index + 1)}',
                    style: TextStyle(
                        color: COLOR_DARK_TAN,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  subtitle: AutoSizeText(
                    '${questions[index].text}',
                    style: TextStyle(fontSize: 20, color: COLOR_DARK_TAN),
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    maxFontSize: 18,
                    minFontSize: 14,
                  ) /*RichText(
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
                          ]))*/
                  ,
                ),
                Container(
                  height: ScreenUtil().setHeight(750),
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(30), vertical: 20),
                  child: _optionsWidget(questions[index].options),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(60),
                      vertical: ScreenUtil().setWidth(10)),
                  child: (_isReporting)
                      ? Center(child: _loadingWidget(isCircular: true))
                      : _emptyWidget(),
                )
              ],
            );
          }),
    );
  }

  Widget _previousQuestionWidget() {
    return FlatButton(
      textColor: Colors.blue,
      onPressed: () {
        _loadPreviousQuestion();
        _bloc.previousQuestionWidgetSink.add(null);
      },
      child: Text(
        'Previous',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: COLOR_GREEN),
      ),
    );
  }

  void _loadPreviousQuestion() {
    if (_pageController.hasClients) {
      _pageController.previousPage(duration: _kDuration, curve: _kCurve);
    }
  }

  Widget _nextQuestionWidget() {
    return FlatButton(
      textColor: Colors.blue,
      onPressed: () {
        _loadNextQuestion();
        _bloc.nextQuestionWidgetSink.add(null);
      },
      child: Text(
        'Next',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: COLOR_GREEN),
      ),
    );
  }

  void _loadNextQuestion() {
    if (_pageController.hasClients) {
      _pageController.nextPage(duration: _kDuration, curve: _kCurve);
    }
  }

  Widget _nextPageWidget() {
    return FlatButton(
      textColor: Colors.blue,
      onPressed: () => _bloc.nextPageWidgetSink.add(_category.id),
      child: Text(
        'Next Page',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: COLOR_GREEN),
      ),
    );
  }

  Widget _previousPageWidget() {
    return FlatButton(
      textColor: Colors.blue,
      onPressed: () => _bloc.previousPageWidgetSink.add(_category.id),
      child: Text(
        'Previous Page',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: COLOR_GREEN),
      ),
    );
  }




  Widget _pagingWidget(Progress progress) {
    return Container(
      height: ScreenUtil().setHeight(100),
      child: ScrollablePositionedList.builder(
        scrollDirection: Axis.horizontal,
        itemScrollController: _itemScrollController,
        itemCount: progress.totalPages,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () =>
                (index + 1 == progress.currentPage) ? null : _bloc.specificPageSink.add(index+1),
            child: Card(
              color: (index + 1 == progress.currentPage)
                  ? COLOR_GREEN
                  : null,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
                child: Center(
                    child: Text(
                  '${index + 1}',
                  style: TextStyle(
                      color: (index+1 == progress.currentPage)?Colors.white:null
                     ),
                )),
              ),
            ),
          );
        },
      ),
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

  _showToast(BuildContext context, String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
