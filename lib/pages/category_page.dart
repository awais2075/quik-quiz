import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterqaapp/models/category.dart';
import 'package:flutterqaapp/models/category_result.dart';
import 'package:flutterqaapp/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int _counter = 0;
  bool _isLoading = false;
  List<Category> _categories = List<Category>();

  _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    await http.get('$BASE_URL/categories').then((response) {
      //print(response.body);

      CategoryResult result =
          CategoryResult.fromJson(json.decode(response.body));
      setState(() {
        _categories = result.body;
        _counter++;
        _isLoading = false;
      });
    }).catchError((error) {
      print(error.message);
      setState(() {
        _isLoading = false;
        _categories.clear();
      });
    });
  }

  _getSharedPrefData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 5));

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = false;
      _counter = sharedPreferences.getInt('counter') ?? 0;
    });
  }

  _setSharedPrefData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 5));

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = false;
      _counter++;
      sharedPreferences.setInt('counter', _counter);
    });
  }

  @override
  Future<void> initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _isLoading,
      child: Scaffold(
        backgroundColor: COLOR_PALE_ORANGE,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.share,
                color: COLOR_GREEN,
              ),
              onPressed: () {
                _shareWidget();
              },
            ),
            IconButton(

                onPressed: () {
                  showAboutDialog(
                      context: context,
                      applicationIcon: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: COLOR_ORANGE, width: 2),
                            borderRadius: BorderRadius.circular(16.0)),
                        child: Image.asset(
                          'assets/icons/icon_logo.png',
                          width: 96,
                          height: 96,
                        ),
                      ),
                      applicationName: APP_TITLE,
                      applicationVersion: APP_VERSION,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text('Thanks to the Following ',
                            style: TextStyle(color: COLOR_ORANGE)),
                        SizedBox(
                          height: 10,
                        ),
                        _get3rdPartyWebLink(
                            '1. Icon Finder', 'https://www.iconfinder.com/'),
                        _get3rdPartyWebLink(
                            '2. FreePik', 'https://www.freepik.com/'),
                        _get3rdPartyWebLink(
                            '3. Loading.IO', 'https://loading.io/'),
                        _get3rdPartyWebLink(
                            '4. Canva', 'https://www.canva.com/')
                      ]);
                },
                tooltip: 'Info',
                icon: Icon(Icons.info_outline, color: COLOR_GREEN)),

          ],
          elevation: 0,
          backgroundColor: Colors.white.withOpacity(0),
          title: Text(
            'Categories',
            style: TextStyle(
                color: COLOR_GREEN,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 0.5),
          ),
        ),
        body: (_isLoading)
            ? Column(
                children: <Widget>[
                  LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(COLOR_GREEN),
                    backgroundColor: COLOR_LIGHT_ORANGE,
                  ),
                ],
              )
            : (_categories.isNotEmpty)
                ? _populateList()
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
                            _fetchData();
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _populateList() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
          shrinkWrap: true,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            return Card(
              semanticContainer: true,
              elevation: 3,
              child: InkWell(
                onTap: () {
//                  Crashlytics.instance.crash();
                  _moveToQuestionPage(_categories[index]);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                        child: FadeInImage.assetNetwork(
                          image: '${_categories[index].imageUrl}',
                          placeholder: 'assets/gifs/gif_loading.gif',
                          width: 64,
                          height: 64,
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: COLOR_GREY,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: ListTile(
                          dense: true,
                          title: Text(
                            _categories[index].name,
                            style: TextStyle(
                                color: COLOR_ORANGE,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  void _moveToQuestionPage(Category category) {
    print(category.id);
    Navigator.pushNamed(context, '/question_page', arguments: category);
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _get3rdPartyWebLink(String title, String webUrl) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          _launchURL(webUrl);
        },
        child: Text(
          title,
          style: TextStyle(color: COLOR_ORANGE, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  _shareWidget() {
    final RenderBox box = context.findRenderObject();
    Share.share(APP_LINK,
        subject: APP_TITLE,
        sharePositionOrigin:
        box.localToGlobal(Offset.zero) &
        box.size);

  }
}
