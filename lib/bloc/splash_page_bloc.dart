import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutterqaapp/enums/status.dart';

class SplashPageBloc {
  final _networkStatusWidgetController = StreamController<STATUS>.broadcast();


  Stream<STATUS> get networkStatusWidgetStream =>
      _networkStatusWidgetController.stream;

  StreamSink<STATUS> get _networkStatusWidgetSink =>
      _networkStatusWidgetController.sink;

  final _tryAgainWidgetController = StreamController<STATUS>.broadcast();

  StreamSink<STATUS> get tryAgainWidgetSink => _tryAgainWidgetController.sink;

  SplashPageBloc() {
    _tryAgainWidgetController.stream.listen(getData);
  }

  Future<void> getData(STATUS event) async {
    _networkStatusWidgetSink.add(STATUS.LOADING);
    await Future.delayed(Duration(seconds: 3));

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      _networkStatusWidgetSink.add(STATUS.SUCCESS);


    } else {
      print('network not available');
      _networkStatusWidgetSink.add(STATUS.FAIL);
    }
  }



  void dispose() {
    _tryAgainWidgetController.close();
    _networkStatusWidgetController.close();
  }
}
