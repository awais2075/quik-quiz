
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterqaapp/bloc/category_page_bloc.dart';
import 'package:flutterqaapp/enums/status.dart';
import 'package:flutterqaapp/models/category.dart';
import 'package:flutterqaapp/models/category_map.dart';
import 'package:flutterqaapp/utils/constants.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _bloc = CategoryPageBloc();


  @override
  void initState() {
    _bloc.loadCategoriesWidgetSink.add(null);
    super.initState();
  }



  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: StreamBuilder(
          stream: _bloc.categoriesWidgetStream,
            builder:
            (BuildContext context, AsyncSnapshot<CategoryMap> snapshot) {
          switch ((snapshot.data)?.status) {
            case STATUS.LOADING:
              return _loadingWidget();
              break;
            case STATUS.SUCCESS:
              return _populateList((snapshot.data).categories);
              break;
            case STATUS.FAIL:
              return _tryAgainWidget();
              break;
            default:
              return _emptyWidget();
              break;
          }
        }));
  }

  Widget _populateList(List<Category> categories) {
    return Column(
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GridView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Card(
                    semanticContainer: true,
                    elevation: 3,
                    child: InkWell(
                      onTap: () {
                        _moveToQuestionPage(categories[index]);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                              child: FadeInImage.assetNetwork(
                                image: '${categories[index].imageUrl}',
                                placeholder: 'assets/gifs/gif_loading.gif',
                                width: 64,
                                height: 64,
                              )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: COLOR_GREY,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  categories[index].name,
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
          ),
        ),
        Visibility(
            visible: false,
            child: Container(
              height: 60,
              color: COLOR_GREEN,
            ))
      ],
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
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
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
              _bloc.loadCategoriesWidgetSink.add(null);
            },
          ),
        ),
      ],
    );
  }

  Widget _loadingWidget() {
    return Column(
      children: <Widget>[
        LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(COLOR_GREEN),
          backgroundColor: COLOR_LIGHT_ORANGE,
        ),
      ],
    );
  }

  Widget _emptyWidget() {
    return SizedBox.shrink();
  }
}
