import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutterqaapp/utils/constants.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isNetworkAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    checkNetworkStatus();
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
              child: Image.asset('assets/icons/icon_logo.png'),
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
            (_isLoading)
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(COLOR_ORANGE),
                    backgroundColor: Colors.white,
                  )
                : (!_isNetworkAvailable)
                    ? RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: COLOR_ORANGE)),
                        color: Colors.white,
                        onPressed: () {
                          checkNetworkStatus();
                        },
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                              color: COLOR_ORANGE, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Text(
                        'Loading Data',
                        style: TextStyle(color: COLOR_ORANGE),
                      ),
          ],
        ));
  }

  void checkNetworkStatus() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 3));

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        _isNetworkAvailable = true;
        _isLoading = false;
        moveToNextPage();
      });
    } else {
      print('network not available');
      setState(() {
        _isNetworkAvailable = false;
        _isLoading = false;
      });
    }
  }

  void moveToNextPage() {
    Navigator.pushReplacementNamed(context, '/category_page');
  }
}
