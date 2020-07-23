import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutterqaapp/bloc/splash_page_bloc.dart';
import 'package:flutterqaapp/enums/status.dart';
import 'package:flutterqaapp/models/app_info.dart';
import 'package:flutterqaapp/utils/constants.dart';
import 'package:package_info/package_info.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isNetworkAvailable = false;
  bool _isLoading = true;

  final _bloc = SplashPageBloc();

  @override
  void initState() {
    _bloc.tryAgainWidgetSink.add(null);
    super.initState();
  }

  _getPackageInfo() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      AppInfo appInfo = AppInfo();
      appInfo.appName = packageInfo.appName;
      appInfo.buildNumber = packageInfo.buildNumber;
      appInfo.packageName = packageInfo.packageName;
      appInfo.version = packageInfo.version;

      print(packageInfo.packageName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/icons/icon_logo.png',
                width: 256,
                height: 256,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Center(
              child: Text(
                'Version $APP_VERSION',
                style: TextStyle(
                    color: COLOR_ORANGE,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            StreamBuilder(
                stream: _bloc.networkStatusWidgetStream,
                builder:
                    (BuildContext context, AsyncSnapshot<STATUS> snapshot) {
                  switch (snapshot.data) {
                    case STATUS.LOADING:
                      return CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(COLOR_ORANGE),
                        backgroundColor: Colors.white,
                      );
                      break;
                    case STATUS.FAIL:
                      return _tryAgainWidget();
                      break;
                    case STATUS.SUCCESS:
                      Future.delayed(Duration.zero,() {moveToNextPage();});
                      return Text('Loading Data');
                      break;
                    default:
                      return SizedBox.shrink();
                  }
                }),
          ],
        ));
  }


  void moveToNextPage() {
    Navigator.pushReplacementNamed(context, '/category_page');
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  Widget _tryAgainWidget() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: COLOR_ORANGE)),
      color: Colors.white,
      onPressed: () {
        _bloc.tryAgainWidgetSink.add(null);
      },
      child: Text(
        'Try Again',
        style: TextStyle(color: COLOR_ORANGE, fontWeight: FontWeight.bold),
      ),
    );
  }
}
