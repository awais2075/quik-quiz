import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterqaapp/pages/question_page.dart';
import 'package:flutterqaapp/pages/splash_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutterqaapp/utils/constants.dart';
import 'pages/category_page.dart';

void main() {
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZoned(() {
    runApp(Main());
  }, onError: Crashlytics.instance.recordError);
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: APP_TITLE,
      builder: (context, child) {
        return MediaQuery(
          child: child,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
        );
      },
      themeMode: ThemeMode.light,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        print('build route for ${settings.name}');
        var routes = <String, WidgetBuilder>{
          '/': (context) => SplashPage(),
          '/category_page': (context) => CategoryPage(),
          '/question_page': (context) => QuestionPage(settings.arguments),
        };
        WidgetBuilder builder = routes[settings.name];
        return MaterialPageRoute(builder: (ctx) => builder(ctx));
      },
      /*routes: {
        '/': (context) => SplashPage(),
        '/category_page': (context) => CategoryPage(),
        '/question_page': (context) => QuestionPage(),
      },*/
    );
  }
}
